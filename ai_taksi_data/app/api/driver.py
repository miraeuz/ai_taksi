from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from app.deps import Db, allow_roles
from app.models import DriverAvailability, DriverPrice, DriverProfile, Route, User
from app.models.enums import UserRole, DriverStatus
from app.schemas import AvailabilityIn, AvailabilityOut, PriceIn, PriceOut

router = APIRouter(prefix='/driver', tags=['Driver'], dependencies=[Depends(allow_roles(UserRole.DRIVER))])

def ensure_driver(user: User, db: Db):
    profile = db.get(DriverProfile, user.id)
    if profile is None or profile.status != DriverStatus.ACTIVE:
        raise HTTPException(403, 'Driver verification required')

@router.get('/availability', response_model=list[AvailabilityOut])
def list_availability(db: Db, user: User = Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user, db)
    return db.scalars(select(DriverAvailability).where(DriverAvailability.driver_id == user.id).order_by(DriverAvailability.weekday, DriverAvailability.from_time)).all()

@router.post('/availability', response_model=AvailabilityOut, status_code=201)
def add_availability(data: AvailabilityIn, db: Db, user: User = Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user, db)
    if data.from_time >= data.to_time: raise HTTPException(422, 'End time must be after start time')
    if not db.get(Route, data.route_id): raise HTTPException(404, 'Route not found')
    previous = db.scalars(select(DriverAvailability).where(DriverAvailability.driver_id==user.id, DriverAvailability.route_id==data.route_id,
                         DriverAvailability.weekday==data.weekday, DriverAvailability.from_time < data.to_time, DriverAvailability.to_time > data.from_time)).first()
    if previous: raise HTTPException(409, 'Overlapping availability window')
    row = DriverAvailability(driver_id=user.id, **data.model_dump())
    db.add(row); db.commit(); db.refresh(row)
    return row

@router.delete('/availability/{availability_id}', status_code=204)
def delete_availability(availability_id: int, db: Db, user: User = Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user, db)
    row = db.get(DriverAvailability, availability_id)
    if not row or row.driver_id != user.id: raise HTTPException(404, 'Availability not found')
    db.delete(row); db.commit()

@router.get('/prices', response_model=list[PriceOut])
def list_prices(db: Db, user: User = Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user, db)
    return db.scalars(select(DriverPrice).where(DriverPrice.driver_id == user.id).order_by(DriverPrice.route_id, DriverPrice.min_riders)).all()

@router.put('/prices', response_model=PriceOut)
def set_price(data: PriceIn, db: Db, user: User = Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user, db)
    if data.min_riders > data.max_riders: raise HTTPException(422, 'Invalid passenger range')
    if not db.get(Route, data.route_id): raise HTTPException(404, 'Route not found')
    overlap = db.scalar(select(DriverPrice).where(DriverPrice.driver_id == user.id, DriverPrice.route_id == data.route_id,
                        DriverPrice.min_riders <= data.max_riders, DriverPrice.max_riders >= data.min_riders))
    if overlap:
        if overlap.min_riders != data.min_riders or overlap.max_riders != data.max_riders:
            raise HTTPException(409, 'Price bands may not overlap')
        overlap.price_per_person = data.price_per_person
        row = overlap
    else:
        row = DriverPrice(driver_id=user.id, **data.model_dump())
        db.add(row)
    db.commit(); db.refresh(row)
    return row

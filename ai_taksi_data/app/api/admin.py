from datetime import date
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from app.deps import Db, allow_roles
from app.models import User, DriverProfile, Vehicle
from app.models.enums import UserRole, DriverStatus
from app.schemas import DriverCreate, DriverCreated

router = APIRouter(prefix='/admin', tags=['Admin'], dependencies=[Depends(allow_roles(UserRole.ADMIN, UserRole.SUPER_ADMIN))])

@router.post('/drivers', response_model=DriverCreated, status_code=201)
def create_driver(data: DriverCreate, db: Db, admin: User = Depends(allow_roles(UserRole.ADMIN, UserRole.SUPER_ADMIN))):
    if data.license_expiry <= date.today(): raise HTTPException(422, 'License has expired')
    if db.scalar(select(User.id).where(User.phone == data.phone)):
        raise HTTPException(409, 'Phone already registered')
    user = User(phone=data.phone, name=data.name, role=UserRole.DRIVER)
    db.add(user)
    db.flush()
    profile = DriverProfile(user_id=user.id, license_no=data.license_no, license_expiry=data.license_expiry,
                            last_doc_check=date.today(), created_by_admin_id=admin.id,
                            status=DriverStatus.PENDING)
    db.add(profile)
    db.flush()
    vehicle = Vehicle(driver_id=user.id, type=data.vehicle_type, model=data.vehicle_model,
                      color=data.vehicle_color, plate=data.vehicle_plate, seats=data.seats, photos=[])
    db.add(vehicle)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, 'Driver or vehicle information already exists')
    db.refresh(vehicle)
    return DriverCreated(id=user.id, name=user.name, role=user.role, vehicle_id=vehicle.id, vehicle_plate=vehicle.plate)

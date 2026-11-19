from datetime import date, datetime, timezone
from zoneinfo import ZoneInfo
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from app.config import settings
from app.deps import Db, allow_roles
from app.models import RiderSchedule, PickupPoint, Route, DailyConfirmation, User
from app.models.enums import UserRole, ConfirmationStatus
from app.schemas import ScheduleIn, ScheduleOut, ConfirmationIn, ConfirmationOut

router = APIRouter(prefix='/rider', tags=['Rider'], dependencies=[Depends(allow_roles(UserRole.RIDER))])

@router.get('/schedules', response_model=list[ScheduleOut])
def schedules(db: Db, user: User = Depends(allow_roles(UserRole.RIDER))):
    return db.scalars(select(RiderSchedule).where(RiderSchedule.rider_id == user.id).order_by(RiderSchedule.weekday)).all()

@router.post('/schedules', response_model=ScheduleOut, status_code=201)
def create_schedule(data: ScheduleIn, db: Db, user: User = Depends(allow_roles(UserRole.RIDER))):
    route = db.get(Route, data.route_id)
    stop = db.get(PickupPoint, data.pickup_point_id)
    if not route or not route.active or not stop or stop.route_id != route.id or not stop.verified:
        raise HTTPException(422, 'Active route and verified pickup point required')
    exists = db.scalar(select(RiderSchedule.id).where(RiderSchedule.rider_id==user.id, RiderSchedule.route_id==route.id,
                    RiderSchedule.weekday==data.weekday, RiderSchedule.arrive_by_time==data.arrive_by_time, RiderSchedule.direction==data.direction))
    if exists: raise HTTPException(409, 'Schedule already exists')
    row = RiderSchedule(rider_id=user.id, **data.model_dump())
    db.add(row); db.commit(); db.refresh(row)
    return row

@router.delete('/schedules/{schedule_id}', status_code=204)
def delete_schedule(schedule_id: int, db: Db, user: User = Depends(allow_roles(UserRole.RIDER))):
    row = db.get(RiderSchedule, schedule_id)
    if not row or row.rider_id != user.id: raise HTTPException(404, 'Schedule not found')
    # Soft disable to preserve referential integrity and previous confirmations.
    row.active = False; db.commit()

def today_local() -> date:
    return datetime.now(ZoneInfo(settings.timezone)).date()

@router.get('/confirmations/today', response_model=list[ConfirmationOut])
def today_confirmations(db: Db, user: User = Depends(allow_roles(UserRole.RIDER))):
    day = today_local()
    schedules = db.scalars(select(RiderSchedule).where(RiderSchedule.rider_id == user.id, RiderSchedule.active.is_(True), RiderSchedule.weekday == day.weekday())).all()
    existing = {r.schedule_id: r for r in db.scalars(select(DailyConfirmation).where(
        DailyConfirmation.rider_id == user.id, DailyConfirmation.date == day)).all()}
    results = []
    for schedule in schedules:
        row = existing.get(schedule.id)
        if row is None:
            row = DailyConfirmation(rider_id=user.id, schedule_id=schedule.id, date=day,
                                    status=ConfirmationStatus.NO_ANSWER)
            db.add(row)
        results.append(row)
    db.commit()
    return results

@router.get('/confirmations/tomorrow', response_model=list[ConfirmationOut])
def tomorrow_confirmations(db: Db, user: User = Depends(allow_roles(UserRole.RIDER))):
    from datetime import timedelta
    day=today_local()+timedelta(days=1)
    # Scope fallback creation to the authenticated rider; never create global rows on GET.
    schedules = db.scalars(select(RiderSchedule).where(
        RiderSchedule.rider_id == user.id, RiderSchedule.weekday == day.weekday(),
        RiderSchedule.active.is_(True))).all()
    present = set(db.scalars(select(DailyConfirmation.schedule_id).where(
        DailyConfirmation.rider_id == user.id, DailyConfirmation.date == day)).all())
    for schedule in schedules:
        if schedule.id not in present:
            db.add(DailyConfirmation(rider_id=user.id, schedule_id=schedule.id,
                                     date=day, status=ConfirmationStatus.NO_ANSWER))
    db.commit()
    return db.scalars(select(DailyConfirmation).where(DailyConfirmation.rider_id==user.id,
                 DailyConfirmation.date==day).order_by(DailyConfirmation.id)).all()

@router.post('/confirmations/{confirmation_id}', response_model=ConfirmationOut)
def answer_confirmation(confirmation_id: int, data: ConfirmationIn, db: Db, user: User = Depends(allow_roles(UserRole.RIDER))):
    from datetime import timedelta
    from app.models import TripGroup
    row = db.get(DailyConfirmation, confirmation_id)
    today=today_local()
    if not row or row.rider_id != user.id or row.date not in (today,today+timedelta(days=1)):
        raise HTTPException(404, 'Current confirmation not found')
    now=datetime.now(ZoneInfo(settings.timezone))
    if row.date==today+timedelta(days=1) and now.time()>=__import__('datetime').time(20,0):
        raise HTTPException(409,'Tomorrow confirmation closed at 20:00')
    if db.scalar(select(TripGroup.id).where(TripGroup.date==row.date)):
        raise HTTPException(409,'Grouping already started')
    row.status = ConfirmationStatus(data.status)
    row.answered_at = datetime.now(timezone.utc)
    db.commit(); db.refresh(row)
    return row

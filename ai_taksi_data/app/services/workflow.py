"""Transactional orchestration for the Phase-1 matching rules.

All functions accept a SQLAlchemy session; HTTP routes and Celery tasks are thin wrappers.
Runs must be serialized per day/route (Celery worker concurrency=1 for scheduling queue).
"""
from collections import defaultdict
from datetime import date, datetime, timedelta, time, timezone
from decimal import Decimal
from zoneinfo import ZoneInfo
from sqlalchemy import select, func
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.config import settings
from app.models import (User, DriverProfile, Vehicle, Route, PickupPoint, RiderSchedule, DailyConfirmation,
    DriverAvailability, DriverPrice, TripGroup, Trip, TripMember, GroupRider, DriverOffer)
from app.models.enums import (UserRole, DriverStatus, UserStatus, ConfirmationStatus, Direction,
                              GroupStatus, TripStatus, MemberStatus)
from app.services.matching import (RiderRequest, CandidateGroup, DriverCandidate, PriceBand,
                                   group_confirmed, merge_or_cancel, car_type_for, rank_drivers)

OFFER_TTL = timedelta(hours=1)
LOCAL_ZONE = ZoneInfo(settings.timezone)


def questions_for_day(db: Session, day: date) -> int:
    """Create tomorrow's confirmation requests (push notifications are integration hooks)."""
    schedules=db.scalars(select(RiderSchedule).join(User,User.id==RiderSchedule.rider_id)
        .where(RiderSchedule.weekday==day.weekday(),RiderSchedule.active.is_(True),User.status==UserStatus.ACTIVE,
               User.role==UserRole.RIDER)).all()
    existing=set(db.scalars(select(DailyConfirmation.schedule_id).where(DailyConfirmation.date==day)).all())
    made=0
    for s in schedules:
        if s.id not in existing:
            db.add(DailyConfirmation(rider_id=s.rider_id,schedule_id=s.id,date=day,status=ConfirmationStatus.NO_ANSWER))
            made+=1
    db.flush()
    return made


def close_confirmations(db: Session, day: date) -> dict:
    """Existing unanswered rows remain no_answer; no automatic YES. API enforces cutoff."""
    yes=db.scalars(select(DailyConfirmation).where(DailyConfirmation.date==day,DailyConfirmation.status==ConfirmationStatus.YES)).all()
    all_rows=db.scalars(select(DailyConfirmation).where(DailyConfirmation.date==day)).all()
    return {'confirmed':len(yes),'no_answer':sum(x.status==ConfirmationStatus.NO_ANSWER for x in all_rows),'total':len(all_rows)}


def create_groups(db: Session, day: date, *, minimum: int = 3) -> dict:
    """Idempotent day grouping; only confirmed schedule entries, ordered pickup points."""
    if db.scalar(select(TripGroup.id).where(TripGroup.date==day)):
        return {'created':0,'cancelled':0,'already_grouped':True}
    confirmations=db.execute(select(DailyConfirmation,RiderSchedule,PickupPoint).join(
        RiderSchedule,RiderSchedule.id==DailyConfirmation.schedule_id).join(
        PickupPoint,PickupPoint.id==RiderSchedule.pickup_point_id).join(
        User,User.id==DailyConfirmation.rider_id).where(
        DailyConfirmation.date==day,DailyConfirmation.status==ConfirmationStatus.YES,
        RiderSchedule.active.is_(True),RiderSchedule.weekday==day.weekday(),
        RiderSchedule.direction==Direction.OUTBOUND,PickupPoint.verified.is_(True),
        User.status==UserStatus.ACTIVE)).all()
    requests=[]; pickup_by_rider={}
    seen=set()
    for confirmation, schedule, pickup in confirmations:
        # one seat per rider per route/day, never double-book concurrent schedules
        key=(confirmation.rider_id,schedule.route_id)
        if key in seen: continue
        seen.add(key)
        requests.append(RiderRequest(confirmation.rider_id,schedule.route_id,pickup.id,
                    schedule.arrive_by_time.hour*60+schedule.arrive_by_time.minute,pickup.order_index))
        pickup_by_rider[confirmation.rider_id]=pickup.id
    groups, cancelled=merge_or_cancel(group_confirmed(requests),minimum=minimum)
    for g in groups+cancelled:
        row=TripGroup(route_id=g.route_id,date=day,time_slot=time(g.minute//60,g.minute%60),
             status=GroupStatus.FORMING if g in groups else GroupStatus.CANCELLED,
             suggested_car_type=car_type_for(len(g.rider_ids)))
        db.add(row);db.flush()
        db.add_all(GroupRider(group_id=row.id,rider_id=r,pickup_point_id=pickup_by_rider[r]) for r in g.rider_ids)
    db.flush()
    return {'created':len(groups),'cancelled':len(cancelled),'confirmed_riders':len(requests)}


def _eligible_drivers(db: Session, route_id: int, day: date, arrival: time):
    rows=db.execute(select(DriverProfile, Vehicle, User).join(Vehicle,Vehicle.driver_id==DriverProfile.user_id)
            .join(User,User.id==DriverProfile.user_id).where(DriverProfile.status==DriverStatus.ACTIVE,
                User.status==UserStatus.ACTIVE)).all()
    availability=db.scalars(select(DriverAvailability).where(DriverAvailability.route_id==route_id,
                                             DriverAvailability.weekday==day.weekday())).all()
    by_driver=defaultdict(list)
    for a in availability:by_driver[a.driver_id].append(a)
    results=[]
    route=db.get(Route,route_id)
    for d,v,u in rows:
        # Missing availability is NOT implicit permission: driver must explicitly be available.
        # A driver may need ~duration+15min to reach destination before arrive-by time.
        arrival_minutes=arrival.hour*60+arrival.minute
        depart_minutes=arrival_minutes-(route.duration_min+15)
        if depart_minutes < 0: continue
        depart=time(depart_minutes//60,depart_minutes%60)
        if not any(a.from_time<=depart and a.to_time>=arrival for a in by_driver[d.user_id]): continue
        results.append(DriverCandidate(d.user_id,v.id,v.type,v.seats,float(d.rating),0.0,
                                       float(u.reliability_score)/100,True))
    return results


def _bands(db: Session, driver_ids: list[int],route_id: int):
    if not driver_ids:return {}
    rows=db.scalars(select(DriverPrice).where(DriverPrice.route_id==route_id,
                                                     DriverPrice.driver_id.in_(driver_ids))).all()
    result=defaultdict(list)
    for p in rows:result[p.driver_id].append(PriceBand(p.min_riders,p.max_riders,p.price_per_person))
    return result


def _activate_next(db: Session, trip: Trip, now: datetime) -> DriverOffer | None:
    upcoming=db.scalars(select(DriverOffer).where(DriverOffer.trip_id==trip.id,
                      DriverOffer.status=='queued').order_by(DriverOffer.rank)).all()
    for offer in upcoming:
        # Don't issue duplicate active offers to driver for same arrival slot/day.
        busy=db.scalar(select(Trip.id).where(Trip.date==trip.date,Trip.driver_id==offer.driver_id,
                  Trip.id!=trip.id,Trip.start_time==trip.start_time,
                  Trip.status.in_([TripStatus.OFFERED,TripStatus.ACCEPTED,TripStatus.CONFIRMED,TripStatus.IN_PROGRESS])))
        if busy: offer.status='declined';continue
        group=db.get(TripGroup,trip.group_id)
        count=db.scalar(select(func.count()).select_from(GroupRider)
                        .where(GroupRider.group_id==group.id))
        vehicle=db.scalar(select(Vehicle).where(Vehicle.driver_id==offer.driver_id,
                                                Vehicle.type==group.suggested_car_type,Vehicle.seats>=count))
        fare=next((p.price_per_person for p in db.scalars(select(DriverPrice).where(
            DriverPrice.driver_id==offer.driver_id,DriverPrice.route_id==group.route_id,
            DriverPrice.min_riders<=count,DriverPrice.max_riders>=count))),None)
        if vehicle is None or fare is None:offer.status='declined';continue
        trip.driver_id=offer.driver_id;trip.vehicle_id=vehicle.id;trip.price_per_person=fare
        for member in trip.members: member.amount=fare
        offer.status='offered';offer.expires_at=now+OFFER_TTL
        db.flush()
        return offer
    trip.status=TripStatus.CANCELLED
    db.get(TripGroup,trip.group_id).status=GroupStatus.CANCELLED
    for member in trip.members:member.status=MemberStatus.CANCELLED
    db.flush()
    return None


def match_groups(db:Session, day:date, now:datetime | None=None)->dict:
    now=now or datetime.now(timezone.utc)
    new=[];unmatched=[]
    groups=db.scalars(select(TripGroup).where(TripGroup.date==day,TripGroup.status==GroupStatus.FORMING)
                          .order_by(TripGroup.route_id,TripGroup.time_slot,TripGroup.id)).all()
    for group in groups:
        allocations=db.scalars(select(GroupRider).where(GroupRider.group_id==group.id)).all()
        if not allocations:continue
        candidate=CandidateGroup(group.route_id,group.time_slot.hour*60+group.time_slot.minute,
                  tuple(a.rider_id for a in allocations),tuple(sorted({a.pickup_point_id for a in allocations})),0)
        drivers=_eligible_drivers(db,group.route_id,day,group.time_slot)
        ranks=rank_drivers(candidate,drivers,_bands(db,[d.driver_id for d in drivers],group.route_id))
        if not ranks:
            group.status=GroupStatus.CANCELLED;unmatched.append(group.id);continue
        route=db.get(Route,group.route_id)
        depart_minutes=candidate.minute-route.duration_min-15
        if depart_minutes < 0:group.status=GroupStatus.CANCELLED;unmatched.append(group.id);continue
        trip=Trip(group_id=group.id,driver_id=ranks[0][0].driver_id,vehicle_id=ranks[0][0].vehicle_id,
                  date=day,start_time=time(depart_minutes//60,depart_minutes%60),
                  price_per_person=ranks[0][1],status=TripStatus.OFFERED)
        db.add(trip);db.flush()
        for a in allocations:
            trip.members.append(TripMember(rider_id=a.rider_id,pickup_point_id=a.pickup_point_id,
                                          amount=ranks[0][1],status=MemberStatus.CONFIRMED,paid=False))
        db.flush()
        for i,(d,price,score) in enumerate(ranks):
            db.add(DriverOffer(trip_id=trip.id,driver_id=d.driver_id,rank=i,status='queued'))
        db.flush()
        first=_activate_next(db,trip,now)
        if first:group.status=GroupStatus.MATCHED;new.append(trip.id)
        else:unmatched.append(group.id)
    db.flush()
    return {'trips_offered':len(new),'unmatched_groups':len(unmatched),'trip_ids':new,'unmatched_ids':unmatched}


def expire_offers(db: Session, now: datetime | None=None)->dict:
    now=now or datetime.now(timezone.utc)
    offers=db.scalars(select(DriverOffer).where(DriverOffer.status=='offered',DriverOffer.expires_at<=now)).all()
    for offer in offers:
        offer.status='expired';offer.responded_at=now
        trip=db.get(Trip,offer.trip_id)
        if trip.status==TripStatus.OFFERED:_activate_next(db,trip,now)
    db.flush()
    return {'expired':len(offers)}


def respond_to_offer(db:Session,driver_id:int,offer_id:int,accept:bool,now:datetime | None=None):
    now=now or datetime.now(timezone.utc)
    offer=db.get(DriverOffer,offer_id)
    if offer is None or offer.driver_id!=driver_id:raise HTTPException(404,'Offer not found')
    if offer.status!='offered':raise HTTPException(409,'Offer is not pending')
    if (offer.expires_at.replace(tzinfo=timezone.utc) if offer.expires_at.tzinfo is None else offer.expires_at)<=now:
        # Hourly worker advances expired offers; don't mutate and then raise (rollback).
        raise HTTPException(409,'Offer has expired')
    trip=db.get(Trip,offer.trip_id)
    if trip.status!=TripStatus.OFFERED:raise HTTPException(409,'Trip is no longer offered')
    offer.status='accepted' if accept else 'declined';offer.responded_at=now
    if accept:trip.status=TripStatus.ACCEPTED
    else:_activate_next(db,trip,now)
    db.flush()
    return offer


def confirm_trip(db:Session,rider_id:int,trip_id:int):
    trip=db.get(Trip,trip_id)
    if trip is None:raise HTTPException(404,'Trip not found')
    member=db.scalar(select(TripMember).where(TripMember.trip_id==trip_id,TripMember.rider_id==rider_id))
    if not member:raise HTTPException(404,'Trip not found')
    if trip.status not in (TripStatus.ACCEPTED,TripStatus.CONFIRMED):raise HTTPException(409,'Driver has not accepted')
    if member.status==MemberStatus.CANCELLED:raise HTTPException(409,'Membership cancelled')
    # Existing status CONFIRMED means seat pre-allocated; idempotent confirmation, not a new state.
    # All seats are reserved by confirmed daily YES responses.
    trip.status=TripStatus.CONFIRMED
    db.flush()
    return trip


def list_offers(db:Session,driver_id:int):
    return db.scalars(select(DriverOffer).where(DriverOffer.driver_id==driver_id,
                 DriverOffer.status=='offered').order_by(DriverOffer.expires_at)).all()

from datetime import date, datetime, time, timedelta, timezone
from decimal import Decimal
import json
from sqlalchemy import select
from app.models import (User, DriverProfile, Vehicle, Route, PickupPoint, RiderSchedule,
    DailyConfirmation, DriverPrice, DriverAvailability, Trip, TripMember, DriverOffer, TripGroup,GroupRider)
from app.models.enums import UserRole, DriverStatus, VehicleType,Direction,ConfirmationStatus,TripStatus
from app.services.matching import (RiderRequest,CandidateGroup,PriceBand,DriverCandidate,
    group_confirmed,car_type_for,score_driver,price_for_group,merge_or_cancel,rank_drivers)
from app.services.workflow import (questions_for_day,create_groups,close_confirmations,match_groups,
                                   expire_offers, respond_to_offer,confirm_trip)
from app.services.security import make_token
from app.db import SessionLocal
from tests.test_api import auth, access

DAY=date(2026,11,23)

def test_grouping_time_window_pickup_capacity():
    requests=[RiderRequest(1,1,1,12*60),RiderRequest(2,1,1,12*60+10),
              RiderRequest(3,1,1,12*60+11),RiderRequest(4,1,2,12*60+5),
              RiderRequest(5,2,1,12*60)]
    groups=group_confirmed(requests)
    assert {g.rider_ids for g in groups}=={(1,2),(3,),(4,),(5,)}
    assert car_type_for(3)==VehicleType.YENGIL
    assert car_type_for(4)==VehicleType.DAMAS
    assert car_type_for(9)==VehicleType.AVTOBUS


def test_scoring_and_pricing():
    assert score_driver(1,1,1,1,1)==1
    assert score_driver(1,0,0,0,0)==.35
    bands=[PriceBand(1,3,Decimal(30000)),PriceBand(4,8,Decimal(20000))]
    assert price_for_group(bands,7)==20000
    assert price_for_group(bands,9) is None
    group=CandidateGroup(1,720,(1,2,3,4),(1,),1)
    drivers=[DriverCandidate(4,10,VehicleType.DAMAS,8,4.8,0,0.95),
             DriverCandidate(5,11,VehicleType.YENGIL,3,5.0,0,1)]
    assert [d.driver_id for d,_,_ in rank_drivers(group,drivers,{4:bands})]==[4]


def test_merge_cancel_small_group():
    groups=[CandidateGroup(1,780,(1,),(1,),1),CandidateGroup(1,785,(2,3),(2,),2),
            CandidateGroup(2,780,(4,),(3,),3)]
    good,bad=merge_or_cancel(groups,minimum=3)
    assert len(good)==1 and set(good[0].rider_ids)=={1,2,3}
    assert len(bad)==1 and bad[0].rider_ids==(4,)


def demo_fixture(db):
    from scripts.seed import DRIVERS,STOPS
    admin=User(phone='+998900000001',name='Admin',role=UserRole.ADMIN)
    db.add(admin);db.flush()
    route=Route(name='Kosonsoy → NamSU',origin_geo='POINT(71.55 41.25)',
          destination_geo='POINT(71.675 41.008)',distance_km=35,duration_min=60)
    db.add(route);db.flush()
    stops=[]
    for idx,(label,lat,lon) in enumerate(STOPS):
        p=PickupPoint(route_id=route.id,name=label,location=f'POINT({lon} {lat})',order_index=idx,verified=True)
        db.add(p);db.flush();stops.append(p)
    driver_users=[]
    for i,(name,car_type,model,plate,seats,bands) in enumerate(DRIVERS):
        user=User(name=name,phone=f'+99890100{i:04d}',role=UserRole.DRIVER)
        db.add(user);db.flush()
        db.add(DriverProfile(user_id=user.id,license_no=f'DEMO-{i}',license_expiry=DAY+timedelta(days=400),
                 created_by_admin_id=admin.id,last_doc_check=DAY,status=DriverStatus.ACTIVE,rating=Decimal('4.8')))
        db.flush()
        db.add(Vehicle(driver_id=user.id,type=car_type,model=model,color='Oq',plate=plate,seats=seats,photos=[]))
        for a,b,price in bands:
            db.add(DriverPrice(driver_id=user.id,route_id=route.id,min_riders=a,max_riders=b,price_per_person=price))
        db.add(DriverAvailability(driver_id=user.id,route_id=route.id,weekday=0,from_time=time(7),to_time=time(16)))
        driver_users.append(user)
    riders=[]
    for i in range(40):
        rider=User(name=f'Student {i+1:02d}',phone=f'+99890200{i:04d}',role=UserRole.RIDER)
        db.add(rider);db.flush();riders.append(rider)
        for wd in (0,2):
            db.add(RiderSchedule(rider_id=rider.id,route_id=route.id,weekday=wd,
                   arrive_by_time=time(13),direction=Direction.OUTBOUND,
                   pickup_point_id=stops[i%6].id,active=True))
    db.commit()
    return route,stops,driver_users,riders


def simulation(db, print_output=False):
    route,stops,drivers,riders=demo_fixture(db)
    assert questions_for_day(db,DAY)==40
    # Reflect seed's 40 scheduled people: all answer YES to expose capacity constraints.
    confirmations=db.scalars(select(DailyConfirmation).where(DailyConfirmation.date==DAY)).all()
    for c in confirmations:c.status=ConfirmationStatus.YES
    assert close_confirmations(db,DAY)['confirmed']==40
    grouping=create_groups(db,DAY)
    result=match_groups(db,DAY,datetime.now(timezone.utc))
    db.commit()
    groups=db.scalars(select(TripGroup).where(TripGroup.date==DAY).order_by(TripGroup.id)).all()
    trips=db.scalars(select(Trip).where(Trip.date==DAY).order_by(Trip.id)).all()
    rows=[]
    for group in groups:
        allocations=db.scalars(select(GroupRider).where(GroupRider.group_id==group.id)).all()
        trip=next((t for t in trips if t.group_id==group.id),None)
        driver=db.get(User,trip.driver_id) if trip and trip.status!=TripStatus.CANCELLED else None
        rows.append({'group':group.id,'pickup_stops':sorted({db.get(PickupPoint,x.pickup_point_id).name for x in allocations}),
               'riders':len(allocations),'car_type':group.suggested_car_type.value,'driver':driver.name if driver else 'UNMATCHED',
               'price_som':int(trip.price_per_person) if trip and trip.status!=TripStatus.CANCELLED else None,'status':group.status.value})
    if print_output:
        print('\nSIMULATION: Kosonsoy -> NamSU, 2026-11-23, arrive by 13:00')
        print(json.dumps({'daily_questions':40,'yes':40,'grouping':grouping,'matching':result,
                          'groups':rows},ensure_ascii=False,indent=2))
    return rows,trips,drivers,riders


def test_seed_day_simulation(db):
    rows,trips,drivers,riders=simulation(db)
    assert sum(g['riders'] for g in rows)==40
    assert len({r.id for r in riders})==40
    assert all(g['price_som'] is not None for g in rows if g['status']=='matched')
    assert len(trips)>=1
    assert not any(len(db.scalars(select(TripMember).where(TripMember.trip_id==t.id)).all()) >
                   db.get(Vehicle,t.vehicle_id).seats for t in trips)
    assert sum(len(db.scalars(select(TripMember).where(TripMember.trip_id==t.id)).all()) for t in trips)<=40


def test_offer_decline_fallback_and_expire(db):
    rows,trips,drivers,riders=simulation(db)
    # Test actual cascade among 2 Damas drivers for a 6+ rider group.
    offer=db.scalar(select(DriverOffer).where(DriverOffer.status=='offered').order_by(DriverOffer.id))
    assert offer is not None
    trip=db.get(Trip,offer.trip_id)
    start_driver=trip.driver_id
    now=datetime.now(timezone.utc)
    respond_to_offer(db,start_driver,offer.id,False,now)
    db.flush()
    assert offer.status=='declined'
    # Another driver may already be reserved for the same time; in that case cancel safely.
    assert trip.status in (TripStatus.CANCELLED,TripStatus.OFFERED)
    if trip.status==TripStatus.OFFERED:
        replacement=db.scalar(select(DriverOffer).where(DriverOffer.trip_id==trip.id,DriverOffer.status=='offered'))
        assert replacement.driver_id!=start_driver
        expire_offers(db,now+timedelta(hours=2))
        assert replacement.status=='expired'


def test_driver_offer_http_permissions_and_no_phone(client,db):
    rows,trips,drivers,riders=simulation(db)
    offer=db.scalar(select(DriverOffer).where(DriverOffer.status=='offered'))
    assert offer
    driver=db.get(User,offer.driver_id)
    rider=riders[0]
    assert client.get('/driver/offers',headers=auth(access(rider))).status_code==403
    response=client.get('/driver/offers',headers=auth(access(driver)))
    assert response.status_code==200
    assert '+998' not in response.text and 'phone' not in response.text.lower()
    assert client.post(f'/driver/offers/{offer.id}/accept',headers=auth(access(rider))).status_code==403
    response=client.post(f'/driver/offers/{offer.id}/accept',headers=auth(access(driver)))
    assert response.status_code==200,response.text
    assert response.json()['status']=='accepted'
    trip=db.get(Trip,offer.trip_id)
    member=db.scalar(select(TripMember).where(TripMember.trip_id==trip.id))
    owner=db.get(User,member.rider_id)
    confirmation=client.post(f'/rider/trips/{trip.id}/confirm',headers=auth(access(owner)))
    assert confirmation.status_code==200,confirmation.text
    assert confirmation.json()['status']=='confirmed'
    outsider=next(r for r in riders if r.id not in {x.rider_id for x in trip.members})
    assert client.post(f'/rider/trips/{trip.id}/confirm',headers=auth(access(outsider))).status_code==404
    assert '+998' not in confirmation.text and 'phone' not in confirmation.text.lower()


def test_print_one_day_simulation(db):
    rows,trips,drivers,riders=simulation(db, print_output=True)
    assert sum(x['riders'] for x in rows)==40

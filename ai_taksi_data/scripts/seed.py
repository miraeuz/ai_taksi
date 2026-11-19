"""Deterministic demo seed for ONE Kosonsoy -> NamSU route; NOT production user data."""
from datetime import date, datetime, time, timedelta, timezone
from decimal import Decimal
from random import Random
from sqlalchemy import select, text
from app.db import SessionLocal
from app.models import (User, DriverProfile, Vehicle, Route, PickupPoint, RiderSchedule,
                        DailyConfirmation, DriverPrice, DriverAvailability, TripGroup, Trip, TripMember, Rating, Message)
from app.models.enums import (UserRole, Gender, DriverStatus, VehicleType, Direction,
                              ConfirmationStatus, GroupStatus, TripStatus, MemberStatus)

rng = Random(20261119)
# Sample coordinates only; pickup locations must be ground-verified before pilot operation.
STOPS = [
    ('Kosonsoy markazi (namuna)', 41.2562, 71.5500),
    ('Kosonsoy bozor bekati (namuna)', 41.2505, 71.5583),
    ('Kosonsoy janub bekati (namuna)', 41.2395, 71.5650),
    ('Yo‘l bo‘yi 1-bekat (namuna)', 41.1870, 71.5920),
    ('Yo‘l bo‘yi 2-bekat (namuna)', 41.1080, 71.6210),
    ('Namangan kirish bekati (namuna)', 41.0370, 71.6530),
]
DRIVERS = [
    ('Sherzod Karimov', VehicleType.YENGIL, 'Chevrolet Cobalt', '01 A 123 BC', 3, [(1, 2, 33000), (3, 3, 30000)]),
    ('Akmal Tojiyev', VehicleType.YENGIL, 'Chevrolet Nexia 3', '50 B 234 CD', 3, [(1, 2, 32000), (3, 3, 29000)]),
    ('Javohir Rasulov', VehicleType.DAMAS, 'Chevrolet Damas', '50 C 345 DE', 8, [(4, 5, 25000), (6, 8, 20000)]),
    ('Islom Ergashev', VehicleType.DAMAS, 'Chevrolet Damas', '50 D 456 EF', 8, [(4, 5, 26000), (6, 8, 21000)]),
    ('Bahodir Soliyev', VehicleType.AVTOBUS, 'Isuzu SAZ', '50 E 567 FG', 20, [(9, 14, 18000), (15, 20, 16000)]),
]
FIRST_NAMES = ['Aziza','Madina','Dilnoza','Malika','Zilola','Sevara','Shahnoza','Gulnoza','Mohira','Nigora','Farida','Diyora','Munisa','Maftuna','Lola','Zarina','Nilufar','Saida','Laylo','Shahlo','Bekzod','Jasur','Bobur','Sardor','Temur','Otabek','Abdulaziz','Asadbek','Diyor','Umid','Shoxrux','Suhrob','Murod','Alisher','Sanjar','Akbar','Anvar','Farrux','Azamat','Oybek']
LAST_NAMES = ['Aliyeva','Karimova','Rasulova','Ergasheva','Tojiyeva','Xolmatova','Solieva','Mamatova','Ismoilova','Yusupova','Rahimov','Qodirov','Tursunov','Nazarov','Zokirov','Sattorov','Sharipov','Sodiqov','Usmonov','Xasanov']

def main():
    with SessionLocal.begin() as session:
        if session.scalar(select(Route.id).where(Route.name == 'Kosonsoy → NamSU')):
            route=session.scalar(select(Route).where(Route.name=='Kosonsoy → NamSU'))
            added=0
            for profile in session.scalars(select(DriverProfile).where(DriverProfile.status==DriverStatus.ACTIVE)):
                for weekday in (0,2):
                    existing=session.scalar(select(DriverAvailability.id).where(
                        DriverAvailability.driver_id==profile.user_id,DriverAvailability.route_id==route.id,
                        DriverAvailability.weekday==weekday))
                    if not existing:
                        session.add(DriverAvailability(driver_id=profile.user_id,route_id=route.id,
                                    weekday=weekday,from_time=time(7),to_time=time(16)))
                        added+=1
            print(f'Seed already present; ensured demo driver availability ({added} added).')
            return
        admin = User(phone='+998900000001', name='AI Taksi pilot administratori', role=UserRole.ADMIN)
        session.add(admin)
        session.flush()
        # The driver and rider phone numbers are fabricated fixtures, never contact these numbers.
        session.execute(text('''INSERT INTO routes
            (name, origin_geo, destination_geo, distance_km, duration_min, active)
            VALUES (:name, ST_GeogFromText(:origin), ST_GeogFromText(:dest), :km, :minutes, true)'''),
            dict(name='Kosonsoy → NamSU', origin='SRID=4326;POINT(71.5500 41.2562)',
                 dest='SRID=4326;POINT(71.6750 41.0080)', km=35, minutes=60))
        session.flush()
        route = session.scalar(select(Route).where(Route.name == 'Kosonsoy → NamSU'))
        for order, (label, lat, lon) in enumerate(STOPS):
            session.execute(text('''INSERT INTO pickup_points (route_id, name, location, order_index, verified)
                VALUES (:route_id, :name, ST_GeogFromText(:geom), :order_index, true)'''),
                dict(route_id=route.id, name=label,
                     geom=f'SRID=4326;POINT({lon} {lat})', order_index=order))
        session.flush()
        stops = session.scalars(select(PickupPoint).order_by(PickupPoint.order_index)).all()
        drivers = []
        for i, (name, car_type, model, plate, seats, bands) in enumerate(DRIVERS):
            user = User(phone=f'+99890100{i:04d}', name=name, role=UserRole.DRIVER, gender=Gender.MALE)
            profile = DriverProfile(user=user, license_no=f'DEMO-LIC-{i+1:03d}',
                                    license_expiry=date.today()+timedelta(days=600+i*30),
                                    status=DriverStatus.ACTIVE, created_by_admin_id=admin.id,
                                    last_doc_check=date.today()-timedelta(days=30), rating=Decimal('4.80'))
            session.add(profile)
            session.flush()
            car = Vehicle(driver_id=user.id, type=car_type, model=model, color='Oq', plate=plate,
                          seats=seats, photos=[])
            session.add(car)
            for min_r, max_r, amount in bands:
                session.add(DriverPrice(driver_id=user.id, route_id=route.id,
                                        min_riders=min_r, max_riders=max_r,
                                        price_per_person=amount))
            for weekday in (0,2):
                session.add(DriverAvailability(driver_id=user.id,route_id=route.id,weekday=weekday,
                                               from_time=time(7,0),to_time=time(16,0)))
            drivers.append((user, profile, car, bands))
        riders = []
        for i, given in enumerate(FIRST_NAMES):
            female = i < 20
            last = LAST_NAMES[i % 10] if female else LAST_NAMES[10+i % 10]
            user = User(phone=f'+99890200{i:04d}', name=f'{given} {last}', role=UserRole.RIDER,
                        gender=Gender.FEMALE if female else Gender.MALE, reliability_score=95+i%6)
            session.add(user)
            session.flush()
            pickup = stops[i % 6]
            schedules = []
            for weekday in [0, 2]:  # Monday / Wednesday; arrive by 13:00
                schedule = RiderSchedule(rider_id=user.id, route_id=route.id, weekday=weekday,
                                         arrive_by_time=time(13, 0), direction=Direction.OUTBOUND,
                                         pickup_point_id=pickup.id)
                session.add(schedule)
                schedules.append(schedule)
            riders.append((user, pickup, schedules))
        session.flush()
        today = date.today()
        dates = [today - timedelta(days=i) for i in range(1, 22)
                 if (today - timedelta(days=i)).weekday() in (0, 2)]
        # Create realistic recent daily confirmations and capacity-respecting historical trips.
        trip_total = 0
        for travel_date in sorted(dates):
            confirmed = []
            for rider, stop, schedules in riders:
                schedule = next(s for s in schedules if s.weekday == travel_date.weekday())
                is_yes = rng.random() > .18
                session.add(DailyConfirmation(rider_id=rider.id, schedule_id=schedule.id,
                    date=travel_date, status=ConfirmationStatus.YES if is_yes else ConfirmationStatus.NO,
                    answered_at=datetime.combine(travel_date-timedelta(days=1), time(19, 10), tzinfo=timezone.utc)))
                if is_yes:
                    confirmed.append((rider, stop))
            rng.shuffle(confirmed)
            # One bus (up to 20), two Damas (up to 8), two sedans (up to 3).
            for (driver, _, vehicle, bands) in [drivers[4], drivers[2], drivers[3], drivers[0], drivers[1]]:
                if not confirmed:
                    break
                capacity = min(vehicle.seats, len(confirmed))
                price_band = next(((low, high, cost) for low, high, cost in bands if low <= capacity <= high), None)
                if not price_band:
                    continue
                passengers, confirmed = confirmed[:capacity], confirmed[capacity:]
                group = TripGroup(route_id=route.id, date=travel_date, time_slot=time(11, 45),
                                  status=GroupStatus.COMPLETED, suggested_car_type=vehicle.type)
                session.add(group)
                session.flush()
                began = datetime.combine(travel_date, time(11,45), tzinfo=timezone.utc)
                trip = Trip(group_id=group.id, driver_id=driver.id, vehicle_id=vehicle.id,
                            date=travel_date, start_time=time(11,45), price_per_person=price_band[2],
                            status=TripStatus.COMPLETED, started_at=began,
                            ended_at=began+timedelta(minutes=62))
                session.add(trip)
                session.flush()
                for passenger, stop in passengers:
                    session.add(TripMember(trip_id=trip.id, rider_id=passenger.id,
                        pickup_point_id=stop.id, status=MemberStatus.PICKED_UP,
                        amount=price_band[2], paid=True))
                    if rng.random() < 0.65:
                        session.add(Rating(trip_id=trip.id, from_user=passenger.id, to_user=driver.id,
                            stars=rng.choice([4,5,5,5]), comment=rng.choice([
                                'Safar qulay bo‘ldi.', 'Haydovchi vaqtida keldi.', 'Rahmat, yaxshi xizmat!'])))
                if passengers:
                    session.add(Message(trip_id=trip.id, sender_id=driver.id,
                                        text='Assalomu alaykum! Belgilangan bekatda kutaman.', flagged=False))
                trip_total += 1
        print(f'Seed prepared: 1 route, {len(stops)} pickup points, 5 drivers, 5 vehicles, '
              f'{len(riders)} riders, {len(riders)*2} schedules, {trip_total} past trips.')
    print('Seed committed.')

if __name__ == '__main__':
    main()

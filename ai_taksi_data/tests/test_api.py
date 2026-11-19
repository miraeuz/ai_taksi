from datetime import date, timedelta, time
import json
import re
import jwt
import pytest
from sqlalchemy import select
from app.models import User, DriverProfile, Vehicle, Route, PickupPoint, RiderSchedule, OTPChallenge
from app.models.enums import UserRole, DriverStatus, VehicleType
from app.config import settings
from app.services.sms import fake_sms
from app.services.security import digest, make_token
from app.schemas import PublicUser
from datetime import timedelta

RIDER = '+998901234567'
DRIVER = '+998909999999'
ADMIN = '+998900000001'

def auth(token): return {'Authorization':f'Bearer {token}'}

def access(user): return make_token(user.id, user.role.value, 'access', timedelta(minutes=15))

def make_user(db, role, phone, name='Test User'):
    user = User(role=role, phone=phone, name=name)
    db.add(user); db.commit(); return user

def signup(client, phone=RIDER, name='Aziza Karimova'):
    r = client.post('/auth/request-otp', json={'phone':phone,'purpose':'signup'})
    assert r.status_code == 202, r.text
    code = fake_sms.sent[phone]
    r = client.post('/auth/verify-otp', json={'phone':phone, 'code':code, 'purpose':'signup', 'name':name})
    assert r.status_code == 200, r.text
    return r.json()

def route_setup(db):
    route = Route(name='Kosonsoy - NamSU', origin_geo='POINT(71.55 41.25)', destination_geo='POINT(71.67 41.0)', distance_km=35, duration_min=60)
    db.add(route); db.flush()
    stop = PickupPoint(route_id=route.id, name='Kosonsoy bekati', order_index=1, location='POINT(71.55 41.25)', verified=True)
    db.add(stop); db.commit()
    return route, stop

def make_driver(db, phone=DRIVER, active=True):
    admin = db.scalar(select(User).where(User.role == UserRole.ADMIN)) or make_user(db, UserRole.ADMIN, ADMIN)
    user = make_user(db, UserRole.DRIVER, phone, 'Sherzod')
    db.add(DriverProfile(user_id=user.id, created_by_admin_id=admin.id, license_no='AA100100', license_expiry=date.today()+timedelta(days=300), last_doc_check=date.today(), status=DriverStatus.ACTIVE if active else DriverStatus.PENDING))
    db.commit()
    return user

def test_signup_verify_login_refresh_logout(client, db):
    r = signup(client)
    assert r['user'] == {'id':1, 'name':'Aziza Karimova', 'role':'rider'}
    assert 'phone' not in json.dumps(r).lower()
    assert client.get('/auth/me', headers=auth(r['access_token'])).status_code == 200
    used = client.post('/auth/verify-otp', json={'phone':RIDER, 'code':fake_sms.sent[RIDER],'purpose':'signup','name':'Aziza'})
    assert used.status_code in (400,429)
    refreshed = client.post('/auth/refresh', json={'refresh_token':r['refresh_token']})
    assert refreshed.status_code == 200, refreshed.text
    assert client.post('/auth/refresh',json={'refresh_token':r['refresh_token']}).status_code == 401
    assert client.post('/auth/logout',json={'refresh_token':refreshed.json()['refresh_token']},headers=auth(refreshed.json()['access_token'])).status_code == 200
    assert client.post('/auth/refresh',json={'refresh_token':refreshed.json()['refresh_token']}).status_code == 401
    login = client.post('/auth/request-otp',json={'phone':RIDER,'purpose':'login'})
    assert login.status_code == 202
    ok = client.post('/auth/verify-otp', json={'phone':RIDER,'purpose':'login','code':fake_sms.sent[RIDER]})
    assert ok.status_code == 200

def test_sms_expiry_attempts_rate_limit_and_format(client, db):
    assert client.post('/auth/request-otp',json={'phone':'901234567'}).status_code == 422
    client.post('/auth/request-otp',json={'phone':RIDER})
    for i in range(settings.otp_attempts):
        bad = client.post('/auth/verify-otp',json={'phone':RIDER,'code':'000000' if fake_sms.sent[RIDER] != '000000' else '999999'})
        assert bad.status_code == 400
    assert client.post('/auth/verify-otp',json={'phone':RIDER,'code':fake_sms.sent[RIDER]}).status_code == 429
    for _ in range(settings.otp_hourly_limit-1):
        assert client.post('/auth/request-otp',json={'phone':RIDER}).status_code == 202
    assert client.post('/auth/request-otp',json={'phone':RIDER}).status_code == 429
    # Explicit expiry test on independent number.
    other = '+998901234568'
    client.post('/auth/request-otp',json={'phone':other})
    c = db.scalar(select(OTPChallenge).where(OTPChallenge.phone_hash==digest(other,'phone')))
    c.expires_at = __import__('datetime').datetime.now(__import__('datetime').timezone.utc)-timedelta(minutes=1)
    db.commit()
    assert client.post('/auth/verify-otp',json={'phone':other,'code':fake_sms.sent[other],'name':'Zilola'}).status_code == 400

def test_no_driver_self_registration_and_admin_creation(client, db):
    admin = make_user(db, UserRole.ADMIN, ADMIN)
    driver_phone = DRIVER
    payload={'phone':driver_phone,'name':'Sherzod', 'license_no':'AA-123456', 'license_expiry':str(date.today()+timedelta(days=200)),
             'vehicle_type':'damas','vehicle_model':'Damas','vehicle_color':'Oq','vehicle_plate':'50 D 123 AB','seats':8}
    assert client.post('/admin/drivers',json=payload).status_code == 401
    rider = signup(client)
    assert client.post('/admin/drivers',json=payload,headers=auth(rider['access_token'])).status_code == 403
    made = client.post('/admin/drivers',json=payload,headers=auth(access(admin)))
    assert made.status_code == 201, made.text
    assert made.json()['role'] == 'driver'
    assert db.scalar(select(User).where(User.phone==DRIVER)).role == UserRole.DRIVER
    assert client.post('/auth/request-otp',json={'phone':DRIVER,'purpose':'signup'}).status_code == 202
    assert DRIVER not in fake_sms.sent
    # Driver may log in after admin creation; pending driver cannot use operational endpoints.
    client.post('/auth/request-otp',json={'phone':DRIVER,'purpose':'login'})
    logged = client.post('/auth/verify-otp',json={'phone':DRIVER,'purpose':'login','code':fake_sms.sent[DRIVER]})
    assert logged.status_code == 200
    assert client.get('/driver/prices',headers=auth(logged.json()['access_token'])).status_code == 403

def test_driver_availability_prices_and_rbac(client, db):
    driver = make_driver(db)
    route,_=route_setup(db)
    h=auth(access(driver))
    av={'route_id':route.id,'weekday':0,'from_time':'07:00','to_time':'16:00'}
    a=client.post('/driver/availability',json=av,headers=h)
    assert a.status_code == 201, a.text
    assert client.post('/driver/availability',json=av,headers=h).status_code == 409
    assert len(client.get('/driver/availability',headers=h).json()) == 1
    price={'route_id':route.id,'min_riders':4,'max_riders':8,'price_per_person':'20000'}
    assert client.put('/driver/prices',json=price,headers=h).status_code == 200
    assert client.put('/driver/prices',json=dict(price, min_riders=6),headers=h).status_code == 409
    assert client.put('/driver/prices',json=dict(price, price_per_person='21000'),headers=h).status_code == 200
    assert len(client.get('/driver/prices',headers=h).json()) == 1
    assert client.delete(f'/driver/availability/{a.json()["id"]}',headers=h).status_code == 204
    rider=signup(client)
    assert client.get('/driver/prices',headers=auth(rider['access_token'])).status_code == 403

def test_schedule_and_today_confirmation(client, db, monkeypatch):
    rider=signup(client)
    route,stop=route_setup(db)
    h=auth(rider['access_token'])
    from app.api import rider as rider_api
    monkeypatch.setattr(rider_api,'today_local',lambda:date(2026,11,23)) # Monday
    schedule={'route_id':route.id,'weekday':0,'arrive_by_time':'13:00','pickup_point_id':stop.id,'direction':'outbound'}
    s=client.post('/rider/schedules',json=schedule,headers=h)
    assert s.status_code == 201, s.text
    assert client.post('/rider/schedules',json=schedule,headers=h).status_code == 409
    assert len(client.get('/rider/schedules',headers=h).json()) == 1
    items=client.get('/rider/confirmations/today',headers=h)
    assert items.status_code == 200, items.text
    assert len(items.json()) == 1 and items.json()[0]['status']=='no_answer'
    cid=items.json()[0]['id']
    ok=client.post(f'/rider/confirmations/{cid}',json={'status':'yes'},headers=h)
    assert ok.status_code == 200 and ok.json()['status']=='yes'
    assert len(client.get('/rider/confirmations/today',headers=h).json())==1

def test_phone_never_leaks_in_rider_driver_responses(client, db):
    """Inspect every rider/driver response, including errors and hostile text values."""
    rider = signup(client, name='Aziza +998901112233')
    rider_h = auth(rider['access_token'])
    drv=make_driver(db, active=True)
    driver_h=auth(access(drv))
    attempts = [
        ('GET','/auth/me',None,rider_h),('GET','/auth/me',None,driver_h),
        ('GET','/rider/schedules',None,rider_h),('GET','/rider/confirmations/today',None,rider_h),
        ('GET','/driver/availability',None,driver_h),('GET','/driver/prices',None,driver_h),
        ('GET','/driver/prices',None,rider_h),('GET','/rider/schedules',None,driver_h),
        ('GET','/not-a-route',None,rider_h),
    ]
    for method,url,body,headers in attempts:
        response=client.request(method,url,json=body,headers=headers)
        raw=response.text
        assert 'phone' not in raw.lower(), (url,raw)
        assert not re.search(r'\+?998\d{9}',raw), (url,raw)
        assert '+998901112233' not in raw
    assert rider['user']['name']=='Aziza [hidden]'
    assert PublicUser.model_fields.keys().isdisjoint({'phone','phone_number','telegram_username'})

def test_token_type_and_suspension(client,db):
    rider=signup(client)
    assert client.get('/auth/me',headers=auth(rider['refresh_token'])).status_code==401
    user=db.get(User,rider['user']['id'])
    from app.models.enums import UserStatus
    user.status=UserStatus.SUSPENDED;db.commit()
    assert client.get('/auth/me',headers=auth(rider['access_token'])).status_code==401

def test_sensitive_validation_errors_are_masked(client, db):
    rider = signup(client)
    h = auth(rider['access_token'])
    # FastAPI includes rejected input values in its default validation errors.
    bad = client.post('/admin/drivers', json={'phone': '+998901112233', 'vehicle_plate': 99}, headers=h)
    assert '+998901112233' not in bad.text
    assert '+998901112233' not in client.post('/auth/request-otp',json={'phone':'+998901112233444'}).text


def test_rider_cannot_change_another_riders_schedule(client, db):
    rider1 = signup(client)
    route, stop = route_setup(db)
    schedule = {'route_id':route.id,'weekday':0,'arrive_by_time':'13:00','pickup_point_id':stop.id}
    made=client.post('/rider/schedules',json=schedule,headers=auth(rider1['access_token']))
    assert made.status_code == 201
    second = signup(client, '+998901234568', 'Madina')
    other_headers = auth(second['access_token'])
    assert client.delete(f'/rider/schedules/{made.json()["id"]}',headers=other_headers).status_code == 404
    assert client.get('/rider/schedules',headers=other_headers).json() == []

def test_sensitive_contact_text_redacted_in_api(client, db):
    for i, name in enumerate(('Madina 901234567', 'Madina +998 90 123 45 67',
                 'Madina @someuser', 'Madina https://t.me/someuser')):
        phone = '+99890' + str(1300000 + i).zfill(7)
        result = signup(client, phone=phone, name=name)
        payload = json.dumps(result, ensure_ascii=False)
        assert '901234567' not in payload
        assert '123 45 67' not in payload
        assert '@someuser' not in payload
        assert 't.me/' not in payload


def test_tomorrow_lookup_does_not_create_other_riders_records(client, db, monkeypatch):
    from app.api import rider as rider_api
    from app.models import DailyConfirmation
    monkeypatch.setattr(rider_api, 'today_local', lambda: date(2026, 11, 22))
    route, stop = route_setup(db)
    first = signup(client, '+998901234561', 'Aziza')
    second = signup(client, '+998901234562', 'Malika')
    for token in (first['access_token'], second['access_token']):
        payload = {'route_id': route.id, 'weekday': 0, 'arrive_by_time': '13:00',
                   'pickup_point_id': stop.id, 'direction': 'outbound'}
        assert client.post('/rider/schedules', json=payload, headers=auth(token)).status_code == 201
    got = client.get('/rider/confirmations/tomorrow', headers=auth(first['access_token']))
    assert got.status_code == 200
    assert len(got.json()) == 1
    assert db.query(DailyConfirmation).count() == 1
    assert db.query(DailyConfirmation).one().rider_id == first['user']['id']


def test_role_guard_matrix(client, db):
    rider = signup(client)
    driver = make_driver(db)
    admin = db.scalar(select(User).where(User.role == UserRole.ADMIN))
    h_r, h_d, h_a = (auth(rider['access_token']), auth(access(driver)), auth(access(admin)))
    checked = [
        ('GET', '/rider/schedules', h_r, (h_d, h_a)),
        ('GET', '/rider/confirmations/today', h_r, (h_d, h_a)),
        ('GET', '/driver/availability', h_d, (h_r, h_a)),
        ('GET', '/driver/prices', h_d, (h_r, h_a)),
        ('GET', '/driver/offers', h_d, (h_r, h_a)),
        ('POST', '/admin/drivers', h_a, (h_r, h_d)),
    ]
    for method, path, good, wrongs in checked:
        response = client.request(method, path, headers=good)
        assert response.status_code not in (401, 403), (path, response.text)
        for wrong in wrongs:
            response = client.request(method, path, headers=wrong)
            assert response.status_code == 403, (path, response.status_code)
            assert '+998' not in response.text

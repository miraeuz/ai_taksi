from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy import func, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from app.config import settings
from app.deps import Db, CurrentUser
from app.models import User, OTPChallenge, RefreshSession
from app.models.enums import UserRole, UserStatus
from app.schemas import OTPRequest, OTPVerify, TokenPair, RefreshRequest, PublicUser, StatusResponse
from app.services.security import digest, new_code, make_token, decode_token
from app.services.sms import SMSProvider, get_sms_provider

router = APIRouter(prefix='/auth', tags=['Auth'])

def tokens(db: Session, user: User) -> TokenPair:
    jti = __import__('secrets').token_urlsafe(32)
    expiry = datetime.now(timezone.utc) + timedelta(days=settings.refresh_days)
    db.add(RefreshSession(user_id=user.id, jti_hash=digest(jti, 'refresh'), expires_at=expiry))
    db.flush()
    return TokenPair(access_token=make_token(user.id, user.role.value, 'access', timedelta(minutes=settings.access_minutes)),
                     refresh_token=make_token(user.id, user.role.value, 'refresh', timedelta(days=settings.refresh_days), jti),
                     user=PublicUser.model_validate(user))

@router.post('/request-otp', response_model=StatusResponse, status_code=202)
def request_otp(data: OTPRequest, request: Request, db: Db, sms: SMSProvider = Depends(get_sms_provider)):
    """Identical public response for existing/nonexistent/driver phones; no driver signup."""
    generic = StatusResponse(message='If eligible, a verification code has been sent')
    user = db.scalar(select(User).where(User.phone == data.phone))
    if (data.purpose == 'signup' and user is not None) or (data.purpose == 'login' and (user is None or user.status != UserStatus.ACTIVE)):
        return generic
    ph = digest(data.phone, 'phone')
    ip_hash = digest(request.client.host if request.client else 'unknown', 'otp-ip')
    now = datetime.now(timezone.utc)
    recent_ip = db.scalar(select(func.count(OTPChallenge.id)).where(OTPChallenge.requester_hash == ip_hash, OTPChallenge.created_at >= now - timedelta(hours=1)))
    if recent_ip >= settings.otp_ip_hourly_limit: raise HTTPException(429, 'Too many requests; try later')
    recent = db.scalar(select(func.count(OTPChallenge.id)).where(OTPChallenge.phone_hash == ph, OTPChallenge.created_at >= now - timedelta(hours=1)))
    if recent >= settings.otp_hourly_limit: raise HTTPException(429, 'Too many requests; try later')
    # Disable previous active codes for the same phone/purpose.
    db.execute(update(OTPChallenge).where(OTPChallenge.phone_hash == ph, OTPChallenge.purpose == data.purpose, OTPChallenge.consumed_at.is_(None)).values(consumed_at=now))
    code = new_code()
    db.add(OTPChallenge(phone_hash=ph, requester_hash=ip_hash, code_hash=digest(f'{ph}:{code}', 'otp'), purpose=data.purpose,
                        expires_at=now+timedelta(minutes=settings.otp_minutes)))
    db.flush()
    try:
        sms.send_otp(data.phone, code)
    except Exception:
        db.rollback()
        raise HTTPException(503, 'SMS service unavailable')
    db.commit()
    return generic

@router.post('/verify-otp', response_model=TokenPair)
def verify_otp(data: OTPVerify, db: Db):
    ph = digest(data.phone, 'phone')
    now = datetime.now(timezone.utc)
    challenge = db.scalar(select(OTPChallenge).where(OTPChallenge.phone_hash == ph, OTPChallenge.purpose == data.purpose,
              OTPChallenge.consumed_at.is_(None)).order_by(OTPChallenge.id.desc()).with_for_update())
    if challenge is None or challenge.expires_at.replace(tzinfo=challenge.expires_at.tzinfo or timezone.utc) <= now:
        raise HTTPException(400, 'Invalid or expired verification code')
    if challenge.attempts >= settings.otp_attempts:
        raise HTTPException(429, 'Verification attempts exhausted')
    challenge.attempts += 1
    if not __import__('hmac').compare_digest(challenge.code_hash, digest(f'{ph}:{data.code}', 'otp')):
        db.commit()
        raise HTTPException(400, 'Invalid or expired verification code')
    challenge.consumed_at = now
    user = db.scalar(select(User).where(User.phone == data.phone))
    if data.purpose == 'signup':
        if user is not None: raise HTTPException(409, 'Account already exists')
        if not data.name: raise HTTPException(422, 'Name is required for signup')
        user = User(phone=data.phone, name=data.name, role=UserRole.RIDER, gender=data.gender)
        db.add(user)
        db.flush()
    elif user is None or user.status != UserStatus.ACTIVE:
        raise HTTPException(403, 'Account unavailable')
    result = tokens(db, user)
    db.commit()
    return result

@router.post('/refresh', response_model=TokenPair)
def refresh(data: RefreshRequest, db: Db):
    payload = decode_token(data.refresh_token, 'refresh')
    now = datetime.now(timezone.utc)
    row = db.scalar(select(RefreshSession).where(RefreshSession.jti_hash == digest(payload['jti'], 'refresh')).with_for_update())
    if row is None or row.revoked_at is not None or row.expires_at.replace(tzinfo=row.expires_at.tzinfo or timezone.utc) <= now or row.user_id != int(payload['sub']):
        raise HTTPException(401, 'Invalid or revoked refresh token')
    user = db.get(User, row.user_id)
    if user is None or user.status != UserStatus.ACTIVE or user.role.value != payload.get('role'):
        raise HTTPException(401, 'Account unavailable')
    row.revoked_at = now
    pair = tokens(db, user)
    db.commit()
    return pair

@router.post('/logout', response_model=StatusResponse)
def logout(data: RefreshRequest, user: CurrentUser, db: Db):
    payload = decode_token(data.refresh_token, 'refresh')
    if payload['sub'] != str(user.id): raise HTTPException(403, 'Token belongs to another account')
    row = db.scalar(select(RefreshSession).where(RefreshSession.jti_hash == digest(payload['jti'], 'refresh')))
    if row and row.user_id == user.id:
        row.revoked_at = datetime.now(timezone.utc)
        db.commit()
    return StatusResponse(message='Logged out')

@router.get('/me', response_model=PublicUser)
def me(user: CurrentUser): return user

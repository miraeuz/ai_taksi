import hashlib
import hmac
import re
import secrets
from datetime import datetime, timedelta, timezone
import jwt
from fastapi import HTTPException, status
from app.config import settings

UZ_PHONE = re.compile(r'^\+998\d{9}$')
PHONE_IN_TEXT = re.compile(r'(?<![\w])(?:\+?998[\s().-]*)?(?:\d[\s().-]*){9,}(?!\d)')
CONTACT_HANDLE = re.compile(r'(?<!\w)@[a-zA-Z][a-zA-Z0-9_]{4,31}\b')
CONTACT_LINK = re.compile(r'(?i)\b(?:https?://)?(?:t\.me|telegram\.me)/[^\s]+')

def digest(value: str, purpose: str) -> str:
    return hmac.new(settings.otp_secret.encode(), f'{purpose}:{value}'.encode(), hashlib.sha256).hexdigest()

def new_code() -> str:
    return f'{secrets.randbelow(1000000):06d}'

def make_token(user_id: int, role: str, typ: str, ttl: timedelta, jti: str | None = None) -> str:
    now = datetime.now(timezone.utc)
    return jwt.encode({'sub':str(user_id), 'role':role, 'type':typ, 'iat':now, 'exp':now+ttl, 'jti':jti or secrets.token_urlsafe(32)}, settings.jwt_secret, algorithm='HS256')

def decode_token(token: str, typ: str) -> dict:
    try:
        p = jwt.decode(token, settings.jwt_secret, algorithms=['HS256'], options={'require':['sub','type','exp','jti']})
        if p['type'] != typ: raise ValueError('Wrong token type')
        return p
    except (jwt.PyJWTError, ValueError, KeyError):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid or expired token')

def scrub_phone_text(text: str) -> str:
    return CONTACT_LINK.sub('[hidden]', CONTACT_HANDLE.sub('[hidden]', PHONE_IN_TEXT.sub('[hidden]', text)))

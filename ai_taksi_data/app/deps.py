from typing import Annotated
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.db import SessionLocal
from app.models import User
from app.models.enums import UserRole, UserStatus
from app.services.security import decode_token

def get_db():
    with SessionLocal() as session:
        yield session

Db = Annotated[Session, Depends(get_db)]
bearer = HTTPBearer(auto_error=False)

def get_current_user(db: Db, cred: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer)]):
    if not cred: raise HTTPException(401, 'Authentication required')
    payload = decode_token(cred.credentials, 'access')
    user = db.get(User, int(payload['sub']))
    if user is None or user.status != UserStatus.ACTIVE:
        raise HTTPException(401, 'Account unavailable')
    # Stale role claims are never sufficient: always check current DB role.
    if payload.get('role') != user.role.value:
        raise HTTPException(401, 'Session role changed')
    return user
CurrentUser = Annotated[User, Depends(get_current_user)]
def allow_roles(*roles: UserRole):
    def guard(user: CurrentUser) -> User:
        if user.role not in roles: raise HTTPException(403, 'Insufficient permissions')
        return user
    return guard

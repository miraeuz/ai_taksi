"""New persistence objects required for OTP, refresh-token rotation, and availability.
No changes to the 13 business tables.
"""
from datetime import datetime, time
from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Index, Integer, String, Time, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import Base

class OTPChallenge(Base):
    __tablename__ = 'otp_challenges'
    id: Mapped[int] = mapped_column(primary_key=True)
    phone_hash: Mapped[str] = mapped_column(String(64), index=True, nullable=False)
    requester_hash: Mapped[str] = mapped_column(String(64), index=True, nullable=False)
    code_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    purpose: Mapped[str] = mapped_column(String(16), nullable=False)
    attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    consumed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    __table_args__ = (CheckConstraint('attempts >= 0', name='ck_otp_attempts'), Index('ix_otp_phone_created', 'phone_hash', 'created_at'))

class RefreshSession(Base):
    __tablename__ = 'refresh_sessions'
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    jti_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

class DriverAvailability(Base):
    __tablename__ = 'driver_availability'
    id: Mapped[int] = mapped_column(primary_key=True)
    driver_id: Mapped[int] = mapped_column(ForeignKey('driver_profiles.user_id', ondelete='CASCADE'), nullable=False)
    route_id: Mapped[int] = mapped_column(ForeignKey('routes.id', ondelete='CASCADE'), nullable=False)
    weekday: Mapped[int] = mapped_column(Integer, nullable=False)
    from_time: Mapped[time] = mapped_column(Time, nullable=False)
    to_time: Mapped[time] = mapped_column(Time, nullable=False)
    __table_args__ = (UniqueConstraint('driver_id', 'route_id', 'weekday', 'from_time', 'to_time', name='uq_driver_availability'), CheckConstraint('weekday BETWEEN 0 AND 6', name='ck_availability_weekday'), CheckConstraint('from_time < to_time', name='ck_availability_hours'))

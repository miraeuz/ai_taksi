from __future__ import annotations
from datetime import date, datetime, time
from decimal import Decimal
from typing import Optional
from sqlalchemy import (
    Boolean, CheckConstraint, Date, DateTime, Enum as SAEnum, ForeignKey,
    Index, Integer, Numeric, String, Text, Time, UniqueConstraint, ForeignKeyConstraint, func
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import Base, GeographyPoint
from .enums import (
    UserRole, UserStatus, Gender, DriverStatus, VehicleType, Direction,
    ConfirmationStatus, GroupStatus, TripStatus, MemberStatus
)

def enum_type(cls):
    return SAEnum(cls, name=cls.__name__.lower(), values_callable=lambda x: [e.value for e in x], native_enum=True)

class User(Base):
    __tablename__ = 'users'
    id: Mapped[int] = mapped_column(primary_key=True)
    phone: Mapped[str] = mapped_column(String(13), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(140), nullable=False)
    role: Mapped[UserRole] = mapped_column(enum_type(UserRole), index=True, nullable=False)
    gender: Mapped[Optional[Gender]] = mapped_column(enum_type(Gender))
    photo_url: Mapped[Optional[str]] = mapped_column(Text)
    language: Mapped[str] = mapped_column(String(5), default='uz', server_default='uz')
    telegram_username: Mapped[Optional[str]] = mapped_column(String(64))
    reliability_score: Mapped[Decimal] = mapped_column(Numeric(5, 2), default=100, server_default='100')
    status: Mapped[UserStatus] = mapped_column(enum_type(UserStatus), default=UserStatus.ACTIVE, server_default='active')
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    driver_profile: Mapped[Optional[DriverProfile]] = relationship(back_populates='user', foreign_keys='DriverProfile.user_id', uselist=False)
    schedules: Mapped[list[RiderSchedule]] = relationship(back_populates='rider', foreign_keys='RiderSchedule.rider_id')
    confirmations: Mapped[list[DailyConfirmation]] = relationship(back_populates='rider')
    trip_memberships: Mapped[list[TripMember]] = relationship(back_populates='rider')
    ratings_given: Mapped[list[Rating]] = relationship(back_populates='author', foreign_keys='Rating.from_user')
    ratings_received: Mapped[list[Rating]] = relationship(back_populates='recipient', foreign_keys='Rating.to_user')
    messages: Mapped[list[Message]] = relationship(back_populates='sender')
    __table_args__ = (CheckConstraint("phone ~ '^\\+998[0-9]{9}$'", name='ck_users_uz_phone'), CheckConstraint('reliability_score BETWEEN 0 AND 100', name='ck_users_reliability'))

class DriverProfile(Base):
    __tablename__ = 'driver_profiles'
    user_id: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    license_no: Mapped[str] = mapped_column(String(32), unique=True)
    license_expiry: Mapped[date] = mapped_column(Date)
    id_doc_url: Mapped[Optional[str]] = mapped_column(Text)
    status: Mapped[DriverStatus] = mapped_column(enum_type(DriverStatus), nullable=False, default=DriverStatus.PENDING, server_default='pending')
    rating: Mapped[Decimal] = mapped_column(Numeric(3, 2), default=0, server_default='0')
    created_by_admin_id: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='RESTRICT'))
    last_doc_check: Mapped[date] = mapped_column(Date)
    user: Mapped[User] = relationship(back_populates='driver_profile', foreign_keys=[user_id])
    created_by: Mapped[User] = relationship(foreign_keys=[created_by_admin_id])
    vehicles: Mapped[list[Vehicle]] = relationship(back_populates='driver')
    prices: Mapped[list[DriverPrice]] = relationship(back_populates='driver')
    trips: Mapped[list[Trip]] = relationship(back_populates='driver')
    __table_args__ = (CheckConstraint('rating BETWEEN 0 AND 5', name='ck_driver_rating'),)

class Vehicle(Base):
    __tablename__ = 'vehicles'
    id: Mapped[int] = mapped_column(primary_key=True)
    driver_id: Mapped[int] = mapped_column(ForeignKey('driver_profiles.user_id', ondelete='RESTRICT'), index=True)
    type: Mapped[VehicleType] = mapped_column(enum_type(VehicleType))
    model: Mapped[str] = mapped_column(String(80))
    color: Mapped[str] = mapped_column(String(40))
    plate: Mapped[str] = mapped_column(String(20), unique=True)
    seats: Mapped[int] = mapped_column(Integer)
    registration_doc_url: Mapped[Optional[str]] = mapped_column(Text)
    insurance_expiry: Mapped[Optional[date]] = mapped_column(Date)
    photos: Mapped[list] = mapped_column(JSONB, default=list, server_default='[]')
    driver: Mapped[DriverProfile] = relationship(back_populates='vehicles')
    trips: Mapped[list[Trip]] = relationship(back_populates='vehicle', viewonly=True)
    __table_args__ = (CheckConstraint('seats > 0', name='ck_vehicle_seats'), UniqueConstraint('id', 'driver_id', name='uq_vehicle_driver_pair'))

class Route(Base):
    __tablename__ = 'routes'
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(160), unique=True)
    origin_geo: Mapped[str] = mapped_column(GeographyPoint())
    destination_geo: Mapped[str] = mapped_column(GeographyPoint())
    distance_km: Mapped[Decimal] = mapped_column(Numeric(7,2))
    duration_min: Mapped[int] = mapped_column(Integer)
    active: Mapped[bool] = mapped_column(Boolean, default=True, server_default='true')
    pickup_points: Mapped[list[PickupPoint]] = relationship(back_populates='route', order_by='PickupPoint.order_index')
    schedules: Mapped[list[RiderSchedule]] = relationship(back_populates='route')
    prices: Mapped[list[DriverPrice]] = relationship(back_populates='route')
    trip_groups: Mapped[list[TripGroup]] = relationship(back_populates='route')
    __table_args__ = (CheckConstraint('distance_km > 0 AND duration_min > 0', name='ck_route_metrics'),)

class PickupPoint(Base):
    __tablename__ = 'pickup_points'
    id: Mapped[int] = mapped_column(primary_key=True)
    route_id: Mapped[int] = mapped_column(ForeignKey('routes.id', ondelete='CASCADE'))
    name: Mapped[str] = mapped_column(String(140))
    location: Mapped[str] = mapped_column(GeographyPoint())
    order_index: Mapped[int] = mapped_column(Integer)
    verified: Mapped[bool] = mapped_column(Boolean, server_default='false', default=False)
    route: Mapped[Route] = relationship(back_populates='pickup_points')
    schedules: Mapped[list[RiderSchedule]] = relationship(back_populates='pickup_point')
    __table_args__ = (UniqueConstraint('route_id', 'order_index', name='uq_pickup_route_order'), UniqueConstraint('id', 'route_id', name='uq_pickup_route_pair'))

class RiderSchedule(Base):
    __tablename__ = 'rider_schedules'
    id: Mapped[int] = mapped_column(primary_key=True)
    rider_id: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'))
    route_id: Mapped[int] = mapped_column(ForeignKey('routes.id', ondelete='RESTRICT'))
    weekday: Mapped[int] = mapped_column(Integer)  # Monday=0 ... Sunday=6
    arrive_by_time: Mapped[time] = mapped_column(Time)
    direction: Mapped[Direction] = mapped_column(enum_type(Direction), default=Direction.OUTBOUND)
    pickup_point_id: Mapped[int] = mapped_column(ForeignKey('pickup_points.id', ondelete='RESTRICT'))
    active: Mapped[bool] = mapped_column(Boolean, server_default='true', default=True)
    rider: Mapped[User] = relationship(back_populates='schedules')
    route: Mapped[Route] = relationship(back_populates='schedules')
    pickup_point: Mapped[PickupPoint] = relationship(back_populates='schedules')
    confirmations: Mapped[list[DailyConfirmation]] = relationship(back_populates='schedule')
    __table_args__ = (CheckConstraint('weekday BETWEEN 0 AND 6', name='ck_schedule_weekday'), UniqueConstraint('rider_id', 'route_id', 'weekday', 'arrive_by_time', 'direction', name='uq_rider_schedule'),)

class DailyConfirmation(Base):
    __tablename__ = 'daily_confirmations'
    id: Mapped[int] = mapped_column(primary_key=True)
    rider_id: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'))
    schedule_id: Mapped[int] = mapped_column(ForeignKey('rider_schedules.id', ondelete='CASCADE'))
    date: Mapped[date] = mapped_column(Date)
    status: Mapped[ConfirmationStatus] = mapped_column(enum_type(ConfirmationStatus), default=ConfirmationStatus.NO_ANSWER, server_default='no_answer')
    answered_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    rider: Mapped[User] = relationship(back_populates='confirmations')
    schedule: Mapped[RiderSchedule] = relationship(back_populates='confirmations')
    __table_args__ = (UniqueConstraint('schedule_id', 'date', name='uq_daily_schedule_date'), Index('ix_confirm_date_status', 'date','status'))

class DriverPrice(Base):
    __tablename__ = 'driver_prices'
    id: Mapped[int] = mapped_column(primary_key=True)
    driver_id: Mapped[int] = mapped_column(ForeignKey('driver_profiles.user_id', ondelete='CASCADE'))
    route_id: Mapped[int] = mapped_column(ForeignKey('routes.id', ondelete='CASCADE'))
    min_riders: Mapped[int] = mapped_column(Integer)
    max_riders: Mapped[int] = mapped_column(Integer)
    price_per_person: Mapped[Decimal] = mapped_column(Numeric(12,2))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    driver: Mapped[DriverProfile] = relationship(back_populates='prices')
    route: Mapped[Route] = relationship(back_populates='prices')
    __table_args__ = (CheckConstraint('min_riders >= 1 AND max_riders >= min_riders', name='ck_price_group_range'), CheckConstraint('price_per_person > 0', name='ck_positive_price'), UniqueConstraint('driver_id','route_id','min_riders','max_riders',name='uq_driver_price_band'))

class TripGroup(Base):
    __tablename__ = 'trip_groups'
    id: Mapped[int] = mapped_column(primary_key=True)
    route_id: Mapped[int] = mapped_column(ForeignKey('routes.id', ondelete='RESTRICT'))
    date: Mapped[date] = mapped_column(Date)
    time_slot: Mapped[time] = mapped_column(Time)
    status: Mapped[GroupStatus] = mapped_column(enum_type(GroupStatus), default=GroupStatus.FORMING)
    suggested_car_type: Mapped[VehicleType] = mapped_column(enum_type(VehicleType))
    route: Mapped[Route] = relationship(back_populates='trip_groups')
    trips: Mapped[list[Trip]] = relationship(back_populates='group')
    __table_args__ = (Index('ix_group_date_route', 'date', 'route_id'),)

class Trip(Base):
    __tablename__ = 'trips'
    id: Mapped[int] = mapped_column(primary_key=True)
    group_id: Mapped[int] = mapped_column(ForeignKey('trip_groups.id', ondelete='RESTRICT'))
    driver_id: Mapped[int] = mapped_column(ForeignKey('driver_profiles.user_id', ondelete='RESTRICT'))
    vehicle_id: Mapped[int] = mapped_column(Integer)
    date: Mapped[date] = mapped_column(Date)
    start_time: Mapped[time] = mapped_column(Time)
    price_per_person: Mapped[Decimal] = mapped_column(Numeric(12, 2))
    status: Mapped[TripStatus] = mapped_column(enum_type(TripStatus), default=TripStatus.OFFERED)
    started_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    group: Mapped[TripGroup] = relationship(back_populates='trips')
    driver: Mapped[DriverProfile] = relationship(back_populates='trips')
    vehicle: Mapped[Vehicle] = relationship(back_populates='trips', viewonly=True)
    members: Mapped[list[TripMember]] = relationship(back_populates='trip')
    ratings: Mapped[list[Rating]] = relationship(back_populates='trip')
    messages: Mapped[list[Message]] = relationship(back_populates='trip')
    __table_args__ = (ForeignKeyConstraint(['vehicle_id','driver_id'], ['vehicles.id','vehicles.driver_id'], name='fk_trip_vehicle_driver'), CheckConstraint('price_per_person > 0', name='ck_trip_price'), Index('ix_trip_date_status','date','status'))

class TripMember(Base):
    __tablename__ = 'trip_members'
    id: Mapped[int] = mapped_column(primary_key=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey('trips.id', ondelete='CASCADE'))
    rider_id: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='RESTRICT'))
    pickup_point_id: Mapped[int] = mapped_column(ForeignKey('pickup_points.id', ondelete='RESTRICT'))
    status: Mapped[MemberStatus] = mapped_column(enum_type(MemberStatus), default=MemberStatus.CONFIRMED)
    amount: Mapped[Decimal] = mapped_column(Numeric(12,2))
    paid: Mapped[bool] = mapped_column(Boolean, default=False, server_default='false')
    trip: Mapped[Trip] = relationship(back_populates='members')
    rider: Mapped[User] = relationship(back_populates='trip_memberships')
    pickup_point: Mapped[PickupPoint] = relationship()
    __table_args__ = (UniqueConstraint('trip_id','rider_id',name='uq_trip_rider'), CheckConstraint('amount >= 0', name='ck_member_amount'))

class Rating(Base):
    __tablename__ = 'ratings'
    id: Mapped[int] = mapped_column(primary_key=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey('trips.id', ondelete='CASCADE'))
    from_user: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='RESTRICT'))
    to_user: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='RESTRICT'))
    stars: Mapped[int] = mapped_column(Integer)
    comment: Mapped[Optional[str]] = mapped_column(Text)
    trip: Mapped[Trip] = relationship(back_populates='ratings')
    author: Mapped[User] = relationship(back_populates='ratings_given', foreign_keys=[from_user])
    recipient: Mapped[User] = relationship(back_populates='ratings_received', foreign_keys=[to_user])
    __table_args__ = (CheckConstraint('stars BETWEEN 1 AND 5', name='ck_rating_stars'), CheckConstraint('from_user <> to_user', name='ck_rating_not_self'), UniqueConstraint('trip_id','from_user','to_user',name='uq_rating_trip_pair'))

class Message(Base):
    __tablename__ = 'messages'
    id: Mapped[int] = mapped_column(primary_key=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey('trips.id', ondelete='CASCADE'))
    sender_id: Mapped[int] = mapped_column(ForeignKey('users.id', ondelete='RESTRICT'))
    text: Mapped[str] = mapped_column(Text)
    flagged: Mapped[bool] = mapped_column(Boolean, default=False, server_default='false')
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    trip: Mapped[Trip] = relationship(back_populates='messages')
    sender: Mapped[User] = relationship(back_populates='messages')
    __table_args__ = (CheckConstraint('length(text) BETWEEN 1 AND 4000', name='ck_message_length'), Index('ix_message_trip_created','trip_id','created_at'))

"""Persistence for auditable driver offers; core business models are unchanged."""
from datetime import datetime
from sqlalchemy import ForeignKey, String, DateTime, Integer, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column
from .base import Base
class DriverOffer(Base):
    __tablename__ = 'driver_offers'
    id: Mapped[int] = mapped_column(primary_key=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey('trips.id', ondelete='CASCADE'), nullable=False, index=True)
    driver_id: Mapped[int] = mapped_column(ForeignKey('driver_profiles.user_id', ondelete='RESTRICT'), nullable=False)
    rank: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False, default='queued') # queued, offered, accepted, declined, expired
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    responded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    __table_args__ = (UniqueConstraint('trip_id','driver_id',name='uq_offer_trip_driver'),)
class GroupRider(Base):
    """Persist the 20:30 grouping until matching; no existing table changed."""
    __tablename__='group_riders'
    id: Mapped[int] = mapped_column(primary_key=True)
    group_id: Mapped[int] = mapped_column(ForeignKey('trip_groups.id',ondelete='CASCADE'),nullable=False,index=True)
    rider_id: Mapped[int] = mapped_column(ForeignKey('users.id',ondelete='RESTRICT'),nullable=False)
    pickup_point_id: Mapped[int] = mapped_column(ForeignKey('pickup_points.id',ondelete='RESTRICT'),nullable=False)
    __table_args__=(UniqueConstraint('group_id','rider_id',name='uq_group_rider'),)

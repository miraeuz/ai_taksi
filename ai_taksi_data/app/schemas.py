"""Explicit output schemas never expose private phone fields to riders/drivers."""
from datetime import date, datetime, time
from decimal import Decimal
from typing import Literal
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.enums import UserRole, Direction, ConfirmationStatus, VehicleType, Gender
from app.services.security import UZ_PHONE

class ResponseModel(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')

class PhoneInput(BaseModel):
    phone: str
    @field_validator('phone')
    @classmethod
    def valid_phone(cls, v):
        if not UZ_PHONE.fullmatch(v): raise ValueError('Must be a +998 number with 9 digits')
        return v

class OTPRequest(PhoneInput):
    purpose: Literal['signup', 'login'] = 'signup'

class OTPVerify(PhoneInput):
    code: str = Field(pattern=r'^\d{6}$')
    purpose: Literal['signup', 'login'] = 'signup'
    name: str | None = Field(default=None, min_length=2, max_length=140)
    gender: Gender | None = None

class StatusResponse(ResponseModel):
    message: str

class PublicUser(ResponseModel):
    id: int
    name: str
    role: UserRole

class TokenPair(ResponseModel):
    access_token: str
    refresh_token: str
    token_type: Literal['bearer'] = 'bearer'
    user: PublicUser

class RefreshRequest(BaseModel):
    refresh_token: str

class DriverCreate(PhoneInput):
    name: str = Field(min_length=2, max_length=140)
    license_no: str = Field(min_length=3, max_length=32)
    license_expiry: date
    vehicle_type: VehicleType
    vehicle_model: str = Field(min_length=2, max_length=80)
    vehicle_color: str = Field(min_length=2, max_length=40)
    vehicle_plate: str = Field(min_length=4, max_length=20)
    seats: int = Field(ge=1, le=60)

class DriverCreated(ResponseModel):
    id: int
    name: str
    role: UserRole
    vehicle_id: int
    vehicle_plate: str

class AvailabilityIn(BaseModel):
    route_id: int
    weekday: int = Field(ge=0, le=6)
    from_time: time
    to_time: time

class AvailabilityOut(ResponseModel):
    id: int
    route_id: int
    weekday: int
    from_time: time
    to_time: time

class PriceIn(BaseModel):
    route_id: int
    min_riders: int = Field(ge=1)
    max_riders: int = Field(ge=1)
    price_per_person: Decimal = Field(gt=0)

class PriceOut(ResponseModel):
    id: int
    route_id: int
    min_riders: int
    max_riders: int
    price_per_person: Decimal

class ScheduleIn(BaseModel):
    route_id: int
    weekday: int = Field(ge=0, le=6)
    arrive_by_time: time
    direction: Direction = Direction.OUTBOUND
    pickup_point_id: int

class ScheduleOut(ResponseModel):
    id: int
    route_id: int
    weekday: int
    arrive_by_time: time
    direction: Direction
    pickup_point_id: int
    active: bool

class ConfirmationIn(BaseModel):
    status: Literal['yes', 'no']

class ConfirmationOut(ResponseModel):
    id: int
    schedule_id: int
    date: date
    status: ConfirmationStatus
    answered_at: datetime | None

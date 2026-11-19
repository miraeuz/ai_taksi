from enum import Enum

class StrEnum(str, Enum):
    pass

class UserRole(StrEnum):
    RIDER = 'rider'
    DRIVER = 'driver'
    ADMIN = 'admin'
    SUPER_ADMIN = 'super_admin'

class UserStatus(StrEnum):
    ACTIVE = 'active'
    SUSPENDED = 'suspended'
    DELETED = 'deleted'

class Gender(StrEnum):
    FEMALE = 'female'
    MALE = 'male'
    OTHER = 'other'
    UNDISCLOSED = 'undisclosed'

class DriverStatus(StrEnum):
    PENDING = 'pending'
    ACTIVE = 'active'
    SUSPENDED = 'suspended'

class VehicleType(StrEnum):
    YENGIL = 'yengil'
    DAMAS = 'damas'
    AVTOBUS = 'avtobus'

class Direction(StrEnum):
    OUTBOUND = 'outbound'
    RETURN = 'return'

class ConfirmationStatus(StrEnum):
    YES = 'yes'
    NO = 'no'
    NO_ANSWER = 'no_answer'

class GroupStatus(StrEnum):
    FORMING = 'forming'
    MATCHED = 'matched'
    CANCELLED = 'cancelled'
    COMPLETED = 'completed'

class TripStatus(StrEnum):
    OFFERED = 'offered'
    ACCEPTED = 'accepted'
    CONFIRMED = 'confirmed'
    IN_PROGRESS = 'in_progress'
    COMPLETED = 'completed'
    CANCELLED = 'cancelled'

class MemberStatus(StrEnum):
    CONFIRMED = 'confirmed'
    PICKED_UP = 'picked_up'
    NO_SHOW = 'no_show'
    CANCELLED = 'cancelled'

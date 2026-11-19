import os
from dataclasses import dataclass

@dataclass(frozen=True)
class Settings:
    jwt_secret: str = os.getenv('JWT_SECRET', 'development-only-jwt-key-not-for-prod-000000000000')
    otp_secret: str = os.getenv('OTP_SECRET', 'development-only-otp-key-not-for-prod-00000000000')
    access_minutes: int = 15
    refresh_days: int = 30
    otp_minutes: int = 5
    otp_attempts: int = 5
    otp_hourly_limit: int = 5
    otp_ip_hourly_limit: int = 20
    sms_provider: str = os.getenv('SMS_PROVIDER', 'fake')
    timezone: str = 'Asia/Tashkent'
settings = Settings()

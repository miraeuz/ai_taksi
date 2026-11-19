"""SMS transport interface. No live credentials in source control."""
from typing import Protocol

class SMSProvider(Protocol):
    def send_otp(self, destination: str, code: str) -> None: ...

class FakeSMSProvider:
    """Development-only capture. Never print phone numbers or OTPs to logs."""
    def __init__(self): self.sent: dict[str, str] = {}
    def send_otp(self, destination: str, code: str) -> None:
        self.sent[destination] = code

class EskizSMSProvider:
    def send_otp(self, destination: str, code: str) -> None:
        # Intentionally unimplemented until Eskiz credentials, approved sender,
        # actual API contract and delivery retry policy are configured.
        raise RuntimeError('Eskiz.uz SMS integration is not configured')

fake_sms = FakeSMSProvider()
def get_sms_provider() -> SMSProvider:
    from app.config import settings
    return fake_sms if settings.sms_provider == 'fake' else EskizSMSProvider()

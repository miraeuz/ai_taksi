"""OTP sessions, refresh tokens and driver weekly availability.

Revision ID: 0002_auth_availability
Revises: 0001_initial
"""
from alembic import op
from app.models import Base
revision = '0002_auth_availability'
down_revision = '0001_initial'
branch_labels = None
depends_on = None
NAMES = ['otp_challenges', 'refresh_sessions', 'driver_availability']
def upgrade():
    Base.metadata.create_all(bind=op.get_bind(), tables=[Base.metadata.tables[n] for n in NAMES], checkfirst=False)
def downgrade():
    Base.metadata.drop_all(bind=op.get_bind(), tables=[Base.metadata.tables[n] for n in reversed(NAMES)], checkfirst=False)

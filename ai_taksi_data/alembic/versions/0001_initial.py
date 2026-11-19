"""Initial PostGIS data schema.

Revision ID: 0001_initial
Revises:

This baseline is intentionally bound to the initial declarative schema. For later
revisions, use alembic revision --autogenerate and keep migrations immutable.
"""
from alembic import op
from app.models import Base

revision = '0001_initial'
down_revision = None
branch_labels = None
depends_on = None

INITIAL_TABLES = ['users', 'driver_profiles', 'vehicles', 'routes', 'pickup_points', 'rider_schedules', 'daily_confirmations', 'driver_prices', 'trip_groups', 'trips', 'trip_members', 'ratings', 'messages']

def upgrade():
    op.execute('CREATE EXTENSION IF NOT EXISTS postgis')
    Base.metadata.create_all(bind=op.get_bind(), tables=[Base.metadata.tables[n] for n in INITIAL_TABLES], checkfirst=True)

ENUM_TYPES = ('userrole', 'userstatus', 'gender', 'driverstatus', 'vehicletype', 'direction',
              'confirmationstatus', 'groupstatus', 'tripstatus', 'memberstatus')

def downgrade():
    # Explicit SQL: dropping tables one by one would try to drop shared Enum types too early.
    op.execute('DROP TABLE IF EXISTS ' + ', '.join(reversed(INITIAL_TABLES)) + ' CASCADE')
    for name in ENUM_TYPES:
        op.execute(f'DROP TYPE IF EXISTS {name}')
    # Keep PostGIS installed: the database may have other dependent objects.

"""Auditable sequential driver offers. Revision ID: 0003_driver_offers"""
from alembic import op
from app.models import Base
revision='0003_driver_offers'
down_revision='0002_auth_availability'
branch_labels=depends_on=None
def upgrade():
    Base.metadata.create_all(bind=op.get_bind(), tables=[Base.metadata.tables['driver_offers','group_riders']],checkfirst=False)
def downgrade():
    Base.metadata.drop_all(bind=op.get_bind(),tables=[Base.metadata.tables['driver_offers','group_riders']],checkfirst=False)

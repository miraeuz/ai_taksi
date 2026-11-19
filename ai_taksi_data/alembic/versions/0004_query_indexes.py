"""Indexes for frequent scoped lookups and scheduled jobs; no model fields changed."""
from alembic import op
revision = '0004_query_indexes'
down_revision = '0003_driver_offers'
branch_labels = depends_on = None
INDEXES = [
    ('ix_schedule_rider_day_active','rider_schedules',['rider_id','weekday','active']),
    ('ix_confirmation_rider_date','daily_confirmations',['rider_id','date']),
    ('ix_schedule_day_active','rider_schedules',['weekday','active']),
    ('ix_availability_route_weekday','driver_availability',['route_id','weekday']),
    ('ix_price_route_driver','driver_prices',['route_id','driver_id']),
    ('ix_offer_driver_status_expiry','driver_offers',['driver_id','status','expires_at']),
    ('ix_offer_status_expiry','driver_offers',['status','expires_at']),
    ('ix_group_day_status','trip_groups',['date','status']),
    ('ix_trip_day_driver_time','trips',['date','driver_id','start_time']),
]
def upgrade():
    for name,table,columns in INDEXES: op.create_index(name,table,columns)
def downgrade():
    for name,table,columns in reversed(INDEXES): op.drop_index(name,table_name=table)

from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.types import UserDefinedType

class Base(DeclarativeBase):
    pass

class GeographyPoint(UserDefinedType):
    """PostGIS geography(Point,4326), without an extra GeoAlchemy dependency."""
    cache_ok = True
    def get_col_spec(self, **kw):
        return 'geography(POINT,4326)'

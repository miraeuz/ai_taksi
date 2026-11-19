"""Fast isolated integration suite; SQLite adapter for Postgres-only column types.
Use PostgreSQL/PostGIS in Docker for final integration verification.
"""
import os, sys
os.environ["DATABASE_URL"] = "sqlite+pysqlite://"
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, event, CheckConstraint
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from app.models.base import GeographyPoint
from app.models import Base
from app.deps import get_db
from app.main import app
from app.services.sms import fake_sms

@compiles(GeographyPoint, 'sqlite')
def geo_sqlite(type_, compiler, **kw): return 'TEXT'

@compiles(JSONB, 'sqlite')
def jsonb_sqlite(type_, compiler, **kw): return 'JSON'

@compiles(CheckConstraint, "sqlite")
def check_sqlite(element, compiler, **kw):
    if element.name == "ck_users_uz_phone":
        return "CONSTRAINT ck_users_uz_phone CHECK (1=1)"
    return compiler.visit_check_constraint(element, **kw)

@pytest.fixture
def db():
    engine = create_engine('sqlite+pysqlite://', connect_args={'check_same_thread':False}, poolclass=StaticPool)
    Base.metadata.create_all(engine)
    Session = sessionmaker(engine, expire_on_commit=False)
    with Session() as session:
        yield session
    engine.dispose()

@pytest.fixture
def client(db):
    def override(): yield db
    app.dependency_overrides[get_db] = override
    fake_sms.sent.clear()
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()

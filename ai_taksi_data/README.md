# AI Taksi — data layer only

SQLAlchemy 2.0 models, Alembic baseline, PostgreSQL 16 + PostGIS; **no UI or API**.

## Run in a local Docker installation

```bash
docker compose up -d db
docker compose run --rm data alembic upgrade head
docker compose run --rm data python -m scripts.seed
```

Check:

```bash
docker compose exec db psql -U aitaksi -d aitaksi -c "SELECT 'users' AS tbl, count(*) FROM users UNION ALL SELECT 'routes', count(*) FROM routes UNION ALL SELECT 'pickup_points',count(*) FROM pickup_points UNION ALL SELECT 'trips',count(*) FROM trips;"
```

Tables: users, driver_profiles, vehicles, routes, pickup_points, rider_schedules,
daily_confirmations, driver_prices, trip_groups, trips, trip_members, ratings, messages.

SQLAlchemy geography uses a lightweight custom `geography(POINT,4326)` column type;
PostGIS `ST_GeogFromText` is used in the seed. All six seeded pickup points and
coordinates are **illustrative, not real-world verified**. Their `verified=true`
means a demo platform flag only; re-survey them before real deployment.

Driver `status=active` simulates admin verification for the demo. Fake phone
numbers, identity/license data and plates are test fixtures only. Avoid
connecting SMS/call providers to this demo data.

The pilot defines 40 riders, Monday+Wednesday **arrive by 13:00**, and one
Kosonsoy → NamSU route. Vehicle seats in this demo denote *passenger* seats.
Driver prices are tied to route and group size and can differ per driver.

⚠️ Do not deploy this dataset as a production service. Beyond this data-only
scope, production requires data encryption, externalized secrets, role validation,
phone ownership verification, payment and transport/legal compliance checks.

The initial Alembic baseline uses the model metadata itself. Freeze this initial
schema for future edits and create separate versioned migrations as it evolves.

## API layer (Phase 2: authentication and roles)

Added FastAPI endpoints without changing the 13 original business models. New SQLAlchemy
persistence tables: `otp_challenges`, `refresh_sessions`, and `driver_availability`.
Alembic revision `0002_auth_availability` creates them after the original baseline.

### Launch with Docker

Create a `.env` file in the project root containing **your own randomly generated secrets**:

```dotenv
JWT_SECRET=replace-with-a-random-secret-at-least-32-bytes
OTP_SECRET=replace-with-a-different-random-secret-at-least-32-bytes
SMS_PROVIDER=fake
```

Then:

```bash
docker compose up -d db
docker compose run --rm data alembic upgrade head
docker compose run --rm data python -m scripts.seed
docker compose up --build -d api
# Open http://localhost:8000/docs to explore the API.
docker compose run --rm api pytest -q
```

The development-only `FakeSMSProvider` saves the most recently sent OTP in process
memory at `app.services.sms.fake_sms.sent`, deliberately not to the API or logs.
An `EskizSMSProvider` interface stub exists, but it does not transmit messages.
Real OTP delivery needs approved Eskiz credentials and gateway implementation.

### API endpoints

| Method | Path | Role | Purpose |
|---|---|---|---|
| POST | `/auth/request-otp` | Public | Request a 6-digit signup/login code |
| POST | `/auth/verify-otp` | Public | Verify code and get access/refresh tokens |
| POST | `/auth/refresh` | Session token | Rotate refresh token |
| POST | `/auth/logout` | Authenticated | Revoke refresh session |
| GET | `/auth/me` | Any authenticated | Restricted user identity without phone |
| POST | `/admin/drivers` | Admin | Create driver and vehicle (driver pending review) |
| GET/POST | `/driver/availability` | Verified driver | List/create availability |
| DELETE | `/driver/availability/{id}` | Verified driver | Delete own availability |
| GET/PUT | `/driver/prices` | Verified driver | List/upsert own per-person price bands |
| GET/POST | `/rider/schedules` | Rider | List/create recurring schedules |
| DELETE | `/rider/schedules/{id}` | Rider | Deactivate own schedule |
| GET | `/rider/confirmations/today` | Rider | Get/create today's confirmation(s) |
| POST | `/rider/confirmations/{id}` | Rider | Confirm yes or no for today |

### Security and privacy

- Only `+998` numbers with 9 additional digits are accepted; OTPs are six digits,
  expire in 5 minutes, and allow at most 5 attempts per challenge.
- At most 5 OTP sends per phone and 20 per source IP per hour are allowed, using
  one-way HMAC identifiers in PostgreSQL. FastAPI's validation responses are also
  scrubbed of phone-number patterns. For large-scale deployment, add a shared Redis
  edge limiter and account for reverse-proxy trusted client IP configuration.
- OTPs are HMAC hashed at rest; refresh tokens are rotated and revoked using a
  hashed session identifier. Access tokens expire after 15 minutes; refresh tokens
  after 30 days. Roles are always checked against current database values.
- Riders may only self-register as rider. Drivers are created via the admin endpoint
  with `DriverStatus.PENDING`; an admin must verify and activate them through the
  administration workflow before operational driver APIs work.
- Rider/driver JSON responses use explicit phone-free Pydantic output schemas plus
  a JSON response redaction guard, which also covers validation errors and user-
  supplied text. **Do not bypass these schemas and the guard in future routes.**
- Production readiness still requires an actual Eskiz integration, proper admin
  provisioning, Redis/distributed throttling (including concurrency protection),
  security/audit reviews, PostgreSQL/PostGIS integration tests, HTTPS, secure secret
  management, and deployment review.

### Tests

```bash
pytest -q
```

Current local run: **9 passed**, 16 warnings (SQLite compatibility tests).
Tests use an in-memory SQLite compatibility adapter for PostgreSQL types; they
exercise HTTP request/response behavior but **are not PostgreSQL integration tests**.
Docker and a live PostgreSQL server were unavailable in the authoring environment.

## Phase 1 matching (rules only, no ML)

Pure policy functions: `app/services/matching.py`; transaction and state machine: `app/services/workflow.py`.
Celery/Beat schedule: `app/tasks.py` (timezone `Asia/Tashkent`).

- 18:00: create tomorrow's `daily_confirmations` (notification delivery is an FCM integration hook, not implemented).
- 20:00: close the tomorrow planning window; tomorrow confirmation endpoint rejects late answers.
- 20:30: group YES responses by route, exact verified pickup point, and arrive-by time (10-minute window); persist in `trip_groups` and `group_riders`.
- 21:00: vehicle choice, price-eligible ranked drivers, first sequential offer.
- Hourly: expire outstanding offers and offer next ranked driver or cancel the group.

**New migration**: `0003_driver_offers`, adding `driver_offers` and `group_riders` without changing any of the 13 original business tables.
New endpoints: `GET /driver/offers`, `POST /driver/offers/{id}/accept`, `POST /driver/offers/{id}/decline`, `POST /rider/trips/{id}/confirm`, and `GET /rider/confirmations/tomorrow`. Existing `POST /rider/confirmations/{id}` also accepts tomorrow before 20:00.
All new responses have explicit phone-free response models and the existing JSON privacy middleware.

### Start infrastructure

```bash
cp .env.example .env  # edit both secrets to secure values
# add POSTGRES_PASSWORD if desired; default 'aitaksi' is development only
docker compose up -d db redis
docker compose run --rm data alembic upgrade head
docker compose run --rm data python -m scripts.seed
docker compose up -d api worker beat
docker compose run --rm data pytest -q
```

Run only ONE Beat instance, and serialize the planning tasks per day and route in production. The supplied single-concurrency worker is a development safeguard, not a distributed locking implementation. Before production use, add PostgreSQL advisory locks or lease locks, transaction retries and outward messaging with an outbox. Production also needs real FCM delivery and an operational cancellation/rebooking notice. Here, `questions_for_day` **only creates database confirmation rows**.

### Reproducible tests and simulation

```bash
pytest -q
pytest -q -s tests/test_matching.py::test_print_one_day_simulation
```

The simulation builds an in-memory SQLite fixture **based on the same 5 driver definitions and 6 sample stops in `scripts/seed.py`**, plus 40 riders, and confirms all 40 for Monday 2026-11-23. It does not claim to run the PostGIS seed SQL against a live PostgreSQL server. Since the first-stage group rule requires **same pickup point** and 4-8 riders require a Damas, only the two Damas can serve two of the six 6-7-person groups simultaneously. Four groups remain unmatched; this demonstrates a real operational capacity shortfall, not 40 successful rides. `Yengil` and `Avtobus` are not artificially substituted for a six-person group. A next-phase multi-stop route optimizer could redistribute the demand subject to detour and passenger consent.

Scoring weights are exactly 0.35 price, 0.25 rating, 0.20 proximity, 0.10 seat fit, 0.10 reliability. Normalizations are explicit pilot assumptions in `rank_drivers`, and demo proximity is a placeholder 0 km until real driver GPS/location data exists. The 10-minute window is between **requested arrival times**, rather than a calculated stop-by-stop pickup ETA; routing optimization is intentionally outside Phase 1. Trip confirmation is intentionally simple/idempotent with existing `TripMember.status`; for per-rider acceptance auditability a dedicated confirmation timestamp/state is advisable in the next migration.

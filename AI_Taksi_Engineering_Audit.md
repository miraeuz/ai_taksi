# AI Taksi — engineering audit (2026-11-19)

Scope: reviewed the latest Phase 1 matching backend and the Flutter Android frontend, rather than older intermediate ZIPs. No product features added; only fixes, regression tests and a query-index migration.

## Findings and disposition

| Priority | Finding | Outcome |
|---|---|---|
| High | Flutter driver offer screen filtered `pending`; backend returns `offered`; therefore real driver offers appeared missing. | **Fixed** filter. |
| High | Rider `/confirmations/tomorrow` called `questions_for_day()` for **all** riders on each GET, exposing expensive unintended global database mutations. | **Fixed**: scoped creation to requesting rider; other users untouched. |
| High | SQL exception diagnostics could disclose query bind parameters including phone numbers if logged. | **Fixed**: SQLAlchemy `hide_parameters=True` and Uvicorn access logging disabled in supplied Compose service. External proxy/APM/logging still requires independent redaction. |
| High | Android release manifest explicitly allowed arbitrary unencrypted HTTP traffic. | **Fixed**: cleartext disabled in main manifest, enabled in debug-only manifest for local emulator. Production API URLs must be HTTPS. |
| Medium | Privacy response scrubber did not cover local 9-digit numbers, Telegram usernames/links and overlong numbers in validation errors. | **Fixed** expanded sanitization for JSON error and output bodies. Regex redaction is defense-in-depth, not a proof of no possible phone leak. |
| Medium | `GET /rider/confirmations/today` did one DB query per schedule. | **Fixed**: one query for existing confirmations, then only needed inserts. |
| Medium | Scheduled creation of daily questions did one query for every schedule. | **Fixed**: bulk-read existing schedule IDs for the date. Race conditions remain possible with concurrently running schedulers and require unique-constraint conflict handling. |
| Medium | Driver selection repeatedly looked up the same route inside the vehicle loop. | **Fixed**: route fetched once per candidate search. Matching still scales with groups × driver searches. |
| Medium | No tailored indexes for multiple day/role/offer queries. | **Fixed**: Alembic `0004_query_indexes` creates nine supporting composite indexes. They were not applied or benchmarked on live PostgreSQL. |
| Low | Unused imports (`logging` and `and_`). | **Removed**. Flutter preview screens are intentionally used UI demo flows; no dead feature modules were deleted. |

## Endpoint role review

- Public: `POST /auth/request-otp`, `POST /auth/verify-otp`, `POST /auth/refresh`; refresh requires a valid, revocable refresh token.
- Authenticated user: `GET /auth/me`, `POST /auth/logout`.
- Admin/superadmin: `POST /admin/drivers`. Admin/driver/rider separation is in FastAPI dependencies, not UI-only logic.
- Verified driver only: `/driver/availability` GET/POST/DELETE; `/driver/prices` GET/PUT; `/driver/offers` GET and accept/decline POST. Role guard plus active driver verification.
- Rider only: `/rider/schedules` GET/POST/DELETE; `/rider/confirmations/today` GET; `/rider/confirmations/tomorrow` GET; `/rider/confirmations/{id}` POST; `/rider/trips/{id}/confirm` POST. ID ownership is checked before writes.
- FastAPI generated `/docs`, `/redoc`, and `/openapi.json` remain public documentation endpoints; restrict by deployment policy if necessary.

## Privacy and chat

- Rider/driver response schemas do not serialize `User.phone`; global JSON response sanitization handles phone-like strings and Telegram contacts in fields/errors.
- The backend has **no chat API**, so there is currently no server message-send/read path to test or guarantee. Existing `Message` model is not exposed as a public HTTP endpoint. Flutter chat is explicitly a **local-only demo** and its blocklist/time window must never be treated as a server-enforced privacy boundary.
- URL query parameters and payload bodies should never be logged by proxies, monitoring agents, crash reporters or infrastructure outside this repository; the local API's code cannot guarantee compliance of external systems.
- Secret configuration in Docker Compose requires explicit JWT/OTP secrets, but the Python local development defaults are not production secrets. Production SMS provider is an unimplemented stub. OTP limits are database-based and have concurrency/race limits at higher load.

## Outstanding risks (not feature work)

1. PostgreSQL/PostGIS migrations and query plans not executed here (no Docker or PostgreSQL server). Check the nine new indexes using `EXPLAIN (ANALYZE, BUFFERS)` with realistic workloads before deployment.
2. Offer acceptance/expiry and 20:30 grouping have concurrency races if multiple workers run; per-row locking or idempotent scheduling is needed before production load.
3. `GET` confirmation endpoints still create missing confirmation rows for the requesting user for backward compatibility. A clean read/write split would require a contract change.
4. Current matching repeatedly loads drivers and price bands for every group and loads trip members lazily during offer advances. The highest-scale N+1 risk persists in matching; benchmarking and carefully batched queries remain necessary.
5. Current driver scorer uses placeholder zero distance rather than real driver position; this is existing MVP behavior, not corrected during audit.
6. There is no end-to-end phone privacy guarantee for third-party logs or future backend chat implementation.
7. Flutter Android scaffold contains only partial checked-in platform files. A Flutter SDK is required to generate the full native scaffold, run static analysis, and produce an APK.

## Executed checks

```text
Backend: python -m pytest -q
...................                                                      [100%]
19 passed in 1.32s

Python: python -m compileall -q app scripts alembic tests
PASSED (exit code 0)

Flutter: flutter analyze
NOT RUN — flutter: command not found (exit code 127)

Flutter: flutter build apk --debug
NOT RUN — flutter: command not found (exit code 127)

PostgreSQL/PostGIS integration and Alembic upgrades
NOT RUN — Docker/PostgreSQL unavailable in execution environment
```

## Reproduction

Backend: `cd ai_taksi_data && python -m pytest -q`; full PostgreSQL: run `docker compose up -d db redis`, then `docker compose run --rm data alembic upgrade head`.

Flutter: `cd ai_taksi_flutter && flutter create --platforms=android --project-name ai_taksi . && flutter pub get && flutter analyze && flutter test && flutter build apk --debug`.

For the emulator, pass the debug-only `--dart-define=API_BASE_URL=http://10.0.2.2:8000`; for release builds, configure an HTTPS API origin.

"""Data-backed authentication and schedule endpoints. No trip matching/UI in this phase."""
import json
from fastapi import FastAPI, Request
from starlette.responses import Response
from app.api import auth, admin, driver, rider, offers
from app.services.security import scrub_phone_text

app = FastAPI(title='AI Taksi', version='0.2.0')

SENSITIVE_KEYS = {'phone', 'phone_number', 'telephone', 'mobile', 'telegram_username'}

def redact(payload):
    if isinstance(payload, dict):
        return {k: ('[hidden]' if k.lower() in SENSITIVE_KEYS else redact(v)) for k, v in payload.items()}
    if isinstance(payload, list): return [redact(v) for v in payload]
    if isinstance(payload, str): return scrub_phone_text(payload)
    return payload

@app.middleware('http')
async def phone_privacy_guard(request: Request, call_next):
    response = await call_next(request)
    # Defense in depth also covers validation errors on admin endpoints.
    if not (response.headers.get('content-type', '').startswith('application/json')):
        return response
    chunks = [chunk async for chunk in response.body_iterator]
    try:
        body = json.dumps(redact(json.loads(b''.join(chunks))), ensure_ascii=False).encode()
    except (ValueError, TypeError):
        # Do not echo unparseable JSON data without sanitizing it.
        body = scrub_phone_text(b''.join(chunks).decode('utf-8', errors='replace')).encode('utf-8')
    headers = dict(response.headers)
    headers.pop('content-length', None)
    return Response(content=body, status_code=response.status_code, headers=headers, background=response.background)

app.include_router(auth.router)
app.include_router(admin.router)
app.include_router(driver.router)
app.include_router(rider.router)
app.include_router(offers.router)

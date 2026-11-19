"""Celery Beat timetable, Asia/Tashkent local time.
Run the scheduling worker with --concurrency=1; do not run duplicate beat instances.
"""
import os
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo
from celery import Celery
from celery.schedules import crontab
from app.config import settings
from app.db import SessionLocal
from app.services.workflow import questions_for_day, close_confirmations, create_groups, match_groups, expire_offers

celery_app=Celery('ai_taksi',broker=os.getenv('CELERY_BROKER_URL','redis://localhost:6379/0'))
celery_app.conf.update(timezone=settings.timezone, enable_utc=True, beat_schedule={
    'questions-1800':{'task':'aitaksi.questions','schedule':crontab(hour=18,minute=0)},
    'close-2000':{'task':'aitaksi.close','schedule':crontab(hour=20,minute=0)},
    'group-2030':{'task':'aitaksi.group','schedule':crontab(hour=20,minute=30)},
    'match-2100':{'task':'aitaksi.match','schedule':crontab(hour=21,minute=0)},
    'expire-hourly':{'task':'aitaksi.expire','schedule':crontab(minute=0)},
})

def tomorrow(): return datetime.now(ZoneInfo(settings.timezone)).date()+timedelta(days=1)

def transactional(operation,*args):
    with SessionLocal.begin() as db:
        return operation(db,*args)

@celery_app.task(name='aitaksi.questions')
def questions():
    # Hook for FCM: query newly created DailyConfirmation rows to send notifications
    # Integration is intentionally not pretended implemented.
    return {'questions_created':transactional(questions_for_day,tomorrow())}

@celery_app.task(name='aitaksi.close')
def close():return transactional(close_confirmations,tomorrow())

@celery_app.task(name='aitaksi.group')
def group():return transactional(create_groups,tomorrow())

@celery_app.task(name='aitaksi.match')
def match():return transactional(match_groups,tomorrow())

@celery_app.task(name='aitaksi.expire')
def expire():return transactional(expire_offers)

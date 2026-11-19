"""Thin transport layer: all state transitions reside in workflow.py."""
from datetime import datetime
from fastapi import APIRouter, Depends
from pydantic import BaseModel, ConfigDict
from app.deps import Db, allow_roles
from app.models import User, Trip
from app.models.enums import UserRole
from app.services import workflow
from app.api.driver import ensure_driver

class OfferView(BaseModel):
    model_config=ConfigDict(from_attributes=True,extra='forbid')
    id:int
    trip_id:int
    status:str
    expires_at:datetime | None

class TripView(BaseModel):
    model_config=ConfigDict(from_attributes=True,extra='forbid')
    id:int
    status:str
    price_per_person:float

router=APIRouter(tags=['Matching'])
@router.get('/driver/offers',response_model=list[OfferView])
def offers(db:Db,user:User=Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user,db)
    return workflow.list_offers(db,user.id)

@router.post('/driver/offers/{offer_id}/accept',response_model=OfferView)
def accept(offer_id:int,db:Db,user:User=Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user,db)
    row=workflow.respond_to_offer(db,user.id,offer_id,True)
    db.commit();db.refresh(row)
    return row

@router.post('/driver/offers/{offer_id}/decline',response_model=OfferView)
def decline(offer_id:int,db:Db,user:User=Depends(allow_roles(UserRole.DRIVER))):
    ensure_driver(user,db)
    row=workflow.respond_to_offer(db,user.id,offer_id,False)
    db.commit();db.refresh(row)
    return row

@router.post('/rider/trips/{trip_id}/confirm',response_model=TripView)
def confirm(trip_id:int,db:Db,user:User=Depends(allow_roles(UserRole.RIDER))):
    trip=workflow.confirm_trip(db,user.id,trip_id)
    db.commit();db.refresh(trip)
    return trip

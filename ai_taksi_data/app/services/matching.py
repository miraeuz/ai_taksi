"""Phase-1 deterministic matching policy. No DB, framework, or ML dependencies."""
from dataclasses import dataclass, replace
from datetime import time
from decimal import Decimal
from typing import Iterable
from app.models.enums import VehicleType

@dataclass(frozen=True)
class RiderRequest:
    rider_id: int
    route_id: int
    pickup_point_id: int
    minute: int  # arrival-time minutes since midnight; group within 10 minutes
    pickup_order: int = 0

@dataclass(frozen=True)
class CandidateGroup:
    route_id: int
    minute: int
    rider_ids: tuple[int, ...]
    pickup_ids: tuple[int, ...]
    pickup_order: int

@dataclass(frozen=True)
class DriverCandidate:
    driver_id: int
    vehicle_id: int
    car_type: VehicleType
    seats: int
    rating: float
    distance_km: float
    reliability: float
    available: bool = True

@dataclass(frozen=True)
class PriceBand:
    min_riders: int
    max_riders: int
    price_per_person: Decimal


def car_type_for(count: int) -> VehicleType:
    if count < 1: raise ValueError('Group must contain at least one passenger')
    return VehicleType.YENGIL if count <= 3 else VehicleType.DAMAS if count <= 8 else VehicleType.AVTOBUS


def group_confirmed(requests: Iterable[RiderRequest], wait_minutes: int = 10, max_group: int = 20) -> list[CandidateGroup]:
    """Same route and pickup stop; first-to-last arrival spread <= wait_minutes.
    Splits large groups into vehicle-sized chunks; stable rider ID order.
    """
    if wait_minutes < 0 or max_group < 1: raise ValueError('Invalid grouping settings')
    result = []
    ordered = sorted(requests, key=lambda r:(r.route_id,r.pickup_point_id,r.minute,r.rider_id))
    batch = []
    for r in ordered:
        if not batch or (r.route_id == batch[0].route_id and r.pickup_point_id == batch[0].pickup_point_id
                         and r.minute - batch[0].minute <= wait_minutes and len(batch) < max_group):
            batch.append(r)
        else:
            result.append(CandidateGroup(batch[0].route_id, batch[0].minute, tuple(x.rider_id for x in batch),
                                         (batch[0].pickup_point_id,), batch[0].pickup_order))
            batch = [r]
    if batch:
        result.append(CandidateGroup(batch[0].route_id, batch[0].minute, tuple(x.rider_id for x in batch),
                                     (batch[0].pickup_point_id,), batch[0].pickup_order))
    return sorted(result, key=lambda g:(g.route_id,g.minute,g.pickup_order,g.rider_ids))


def merge_or_cancel(groups: Iterable[CandidateGroup], minimum: int = 3, wait_minutes: int = 10, max_group: int = 20):
    """Merge undersized neighboring stops only if same route, time window and capacity.
    Returns (retained groups, cancelled groups). Never silently lose riders.
    """
    pending = sorted(groups, key=lambda g:(g.route_id,g.minute,g.pickup_order))
    accepted, cancelled = [], []
    while pending:
        g = pending.pop(0)
        if len(g.rider_ids) >= minimum:
            accepted.append(g); continue
        choices = [(abs(g.pickup_order - h.pickup_order), abs(g.minute - h.minute), i, h)
                   for i,h in enumerate(pending)
                   if h.route_id == g.route_id and abs(g.minute-h.minute) <= wait_minutes
                   and len(g.rider_ids)+len(h.rider_ids) <= max_group and abs(g.pickup_order-h.pickup_order) <= 1]
        if not choices:
            cancelled.append(g); continue
        _, _, i, other = min(choices, key=lambda t:(t[0],t[1],t[2]))
        pending.pop(i)
        combined = CandidateGroup(g.route_id, min(g.minute,other.minute), g.rider_ids+other.rider_ids,
                                  tuple(dict.fromkeys(g.pickup_ids+other.pickup_ids)), min(g.pickup_order,other.pickup_order))
        pending.insert(0, combined)
    return sorted(accepted,key=lambda g:(g.route_id,g.minute,g.pickup_order)), cancelled


def price_for_group(bands: Iterable[PriceBand], count: int) -> Decimal | None:
    matches = [b.price_per_person for b in bands if b.min_riders <= count <= b.max_riders]
    if len(matches) > 1: raise ValueError('Overlapping driver price bands')
    return matches[0] if matches else None


def score_driver(price_fit: float, driver_rating: float, proximity_to_first_pickup: float,
                 seat_fit: float, driver_reliability: float) -> float:
    """All five components normalized to [0,1]. Literal weights from section 12.3."""
    values = (price_fit,driver_rating,proximity_to_first_pickup,seat_fit,driver_reliability)
    if any(not 0 <= v <= 1 for v in values): raise ValueError('Scoring components must be in [0,1]')
    return round(.35*price_fit + .25*driver_rating + .20*proximity_to_first_pickup +
                 .10*seat_fit + .10*driver_reliability, 8)


def rank_drivers(group: CandidateGroup, candidates: Iterable[DriverCandidate],
                 bands_by_driver: dict[int,list[PriceBand]], maximum_fare: Decimal = Decimal('40000')):
    """Filter unavailable drivers, capacity and price eligibility; sort deterministically.
    Phase-1 price_fit = 1 - fare/maximum_fare (bounded), proximity=1/(1+km),
    seat_fit=occupied/available, driver rating=stars/5, reliability already in [0,1].
    These normalization rules are pilot assumptions, NOT extra rules in the source.
    """
    ranked = []
    count = len(group.rider_ids)
    required = car_type_for(count)
    for d in candidates:
        if not d.available or d.car_type != required or d.seats < count or d.seats <= 0: continue
        fare = price_for_group(bands_by_driver.get(d.driver_id,[]),count)
        if fare is None or fare > maximum_fare: continue
        score = score_driver(max(0., 1.-float(fare/maximum_fare)), min(1.,max(0.,d.rating/5)),
                             1/(1+max(0.,d.distance_km)), count/d.seats,
                             min(1.,max(0.,d.reliability)))
        ranked.append((d, fare, score))
    return sorted(ranked,key=lambda row:(-row[2],row[1],row[0].driver_id))

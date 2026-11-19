# AI Taksi: Full Project Document

> A scheduled shared-ride application for students and commuters (first route: Kosonsoy → Namangan / NamSU), with AI planning, admin-only driver registration, and fully masked communication.

---

## 1. Vision

**One sentence:** People with the same weekly routine ride together in one car at a fair price, and AI organizes everything every day.

**Problem today**
- Many students and workers travel from Kosonsoy to Namangan on the same days and times.
- Each one pays for a separate taxi or waits for a full minibus with no schedule.
- Drivers do not know in advance how many passengers they will have, so their income is unstable.
- Prices are not clear, and there is no trust or safety control.

**Solution**
- Riders enter a weekly routine once (for example Mon/Wed 13:00 at NamSU).
- AI asks each day "Are you going today?", groups riders, and finds the right driver and car.
- Drivers set their own prices by group size and get predictable income.
- Phone numbers are never shown. Calls and chat happen inside the app.

**What makes it different from a normal taxi app**
| Normal taxi | AI Taksi |
|---|---|
| On-demand, one rider per car | Scheduled, many riders per car |
| Price set by the platform | Price set by the driver per group size |
| Phone numbers visible | Fully masked |
| Anyone can become a driver | Drivers created only by admin |
| No planning | AI predicts and plans daily |

---

## 2. Target Users

- **Primary riders:** university students (NamSU and others) traveling from Kosonsoy and nearby districts.
- **Secondary riders:** workers, teachers, patients going to the city on fixed days.
- **Drivers:** owners of Yengil (sedan), Damas (minivan), and Avtobus (bus/minibus).
- **Admin:** the company team that verifies drivers and supports users.

---

## 3. Roles and Permissions

### 3.1 Rider
- Registers by himself/herself with a **+998 phone number and SMS code**.
- Sets weekly schedule, pickup point, destination.
- Confirms daily trips, pays, rates, contacts the driver through masked channels.

### 3.2 Driver
- **Cannot register by himself.** Only the admin can create a driver account.
- Sets routes, prices, availability.
- Accepts or declines trip offers, runs trips, sees earnings.

### 3.3 Admin (web dashboard)
- Creates, edits, suspends, and deletes driver accounts.
- Verifies documents, handles complaints, bans users, manages refunds.
- Sees statistics and monitors live trips.

### 3.4 Super admin (optional)
- Manages other admins and system settings, views audit logs.

---

## 4. Identity and Registration

### 4.1 Rider sign-up
1. Enter +998 number (only Uzbek numbers accepted).
2. Receive SMS OTP (6 digits, 5-minute expiry, limited attempts).
3. Enter name, optional photo, gender (needed for women-only groups).
4. Optional extra contact: Telegram username (stored privately, never shown to others).

### 4.2 Why not Telegram login
Telegram accounts can be tied to old numbers, foreign numbers, or numbers the person no longer owns. SMS verification of a real +998 number is more trustworthy.

### 4.3 Rules
- One phone number = one account.
- Changing the number requires a new OTP on the new number and a check on the old one if possible.
- Account is blocked after repeated fake OTP attempts.
- SMS provider: Eskiz.uz or PlayMobile (verify current prices and terms).

### 4.4 Driver onboarding (admin only)
1. The driver contacts the company and meets an admin (in person or by video).
2. Required documents: passport/ID, driver license, vehicle registration, plate number, insurance if required, car photos (front, back, interior).
3. Admin creates the account in the dashboard: phone, full name, car type (Yengil / Damas / Avtobus), seats, plate, color, model.
4. Driver receives an SMS to set up login (OTP login, optional PIN).
5. Admin can suspend the driver at any time.
6. Documents are re-checked every 6 months.

---

## 5. Number Masking and Communication

**Rule: no rider ever sees a driver's number, and no driver ever sees a rider's number.**

### 5.1 Options (in order of preference)
1. **In-app VoIP calls** (WebRTC, Agora, or similar). No numbers exchanged, usually cheapest.
2. **Proxy number per trip** from a telephony provider. Both sides call a temporary number and the system connects them. Check which providers in Uzbekistan support this and their cost.
3. **In-app chat** with automatic blocking of phone numbers and usernames typed in messages.

### 5.2 Rules
- Calls and chat are enabled **1 hour before the trip until 1 hour after**, then closed.
- Group chat per trip (driver + riders) and private rider↔driver call.
- Only first name, car, and plate are shown. No surname, no number.
- Call logs (time, duration) are stored for dispute handling. Check local law before any recording.
- Report button inside every chat and call screen.

---

## 6. Core Concepts

- **Route:** a path between two places (Kosonsoy center → Namangan center).
- **Pickup point:** a fixed, named stop on the map (no door-to-door in the MVP). This makes grouping easy and cheaper.
- **Schedule:** a rider's recurring plan (days, time, direction).
- **Daily confirmation:** the rider's yes/no for a specific date.
- **Trip group:** riders who go the same route at the same time.
- **Trip:** a group matched to one driver and vehicle.
- **Leg:** one segment of a journey. A full journey can have several legs.

---

## 7. Rider Features

### 7.1 Screens
1. Splash and language choice (Uzbek, Russian, English)
2. Phone login and SMS code
3. Profile setup
4. Home: today's status, next trip, quick actions
5. Weekly schedule editor
   - Days of the week
   - Time (arrive-by time, e.g. 13:00 at NamSU)
   - Direction (to / from, or both)
   - Home pickup point on the map
   - Destination (NamSU, other university, city center)
6. Daily AI card: "Are you going today?" with Yes / No / Change time
7. Trip offer: price, driver, car, group size, pickup time. Confirm / Decline
8. Active trip: live map, driver location, ETA, masked call/chat, Share Trip, SOS
9. Payment screen
10. Rating and feedback
11. Trip history and receipts
12. Subscription (monthly plan for fixed days)
13. Support and reports
14. Settings (language, notifications, women-only preference, delete account)

### 7.2 Example
> "I go to NamSU every Monday and Wednesday, must be there by 13:00. If many students like me exist, one Damas takes us for 20,000 so'm each."

The app stores the schedule, asks on Sunday evening and Tuesday evening, groups all students from the same area, and offers the trip.

---

## 8. Driver Features

### 8.1 Screens
1. OTP login
2. Dashboard: today's trips, expected income this week
3. Availability calendar (days and hours he can drive)
4. Routes and price settings
   - Price per person by group size (example: 1–3 riders: 30,000; 4–7: 25,000; 8+: 20,000)
   - Minimum group size he accepts
5. Trip offers: accept or decline with a timer
6. Trip detail: ordered pickup list, rider first names, time per stop, navigation
7. Start trip, mark pickups (arrived / picked up / no-show), end trip
8. Masked call and chat
9. Earnings, payouts, history
10. Ratings and feedback
11. Documents status and expiry reminders
12. Support

### 8.2 AI price questions
From time to time the AI asks:
> "Kosonsoy → NamSU, Mon 13:00. How much do you charge per person if 8 people go?"

Answers are stored and used for future offers. The driver can change them anytime.

---

## 9. Admin Dashboard (Web)

- **Drivers:** create, edit, suspend, documents, vehicle data, expiry alerts
- **Riders:** search, reliability score, ban/unban
- **Routes and pickup points:** create and edit on the map
- **Trips:** live monitor, history, manual group merge/split, manual driver assignment
- **Pricing:** min/max price limits, commission settings
- **Payments:** transactions, payouts, refunds
- **Complaints and SOS:** queue, status, notes
- **Analytics:** riders, demand by route/hour, fill rate, no-show rate, revenue
- **Notifications:** broadcast messages
- **Audit log:** who did what and when
- **Admin roles:** super admin, support, finance

---

## 10. Daily Operating Flow

| Time | Step |
|---|---|
| 18:00–20:00 | AI asks riders about tomorrow (push notification with Yes/No) |
| 20:00 | Deadline. Unanswered riders get one reminder next morning |
| 20:30 | Grouping: cluster confirmed riders by route, time, pickup point |
| 21:00 | Pricing and matching: groups are offered to the best drivers |
| 22:00 | Drivers accept or decline. Declines go to the next best driver |
| Next morning | Final confirmation shown to riders with price and pickup time |
| Trip time | Live tracking, pickups, drop-off |
| After trip | Payment, rating, reliability update |

**If the group is too small:** merge with a nearby group, shift the time slightly (with consent), downgrade to a smaller car, or cancel and notify early.

---

## 11. Multi-Leg Journeys

Some people need several cars:
Home → Kosonsoy center → Namangan center → University (inside city).

- Each leg is a separate trip with its own group, driver, and price.
- The app shows it as **one journey plan** with all times and transfer points.
- If one leg is cancelled, the rider is notified immediately and alternatives are offered.
- Rider can choose to pay per leg or for the whole journey.

---

## 12. AI Design

### 12.1 What AI does
1. **Habit learning:** learns weekly patterns, asks at the right time, auto-suggests schedules.
2. **Demand forecast:** predicts riders per route/day/hour.
3. **Grouping:** clusters riders by pickup location and time window.
4. **Vehicle choice:** Yengil (1–3), Damas (4–8), Avtobus (9+).
5. **Driver matching:** scores drivers by price, rating, distance, availability, reliability.
6. **Price suggestion:** proposes fair prices to drivers using history and demand.
7. **No-show prediction:** estimates the chance a rider won't show up and plans extra seats or overbooking carefully.
8. **Anomaly detection:** flags suspicious accounts, repeated cancellations, off-route driving.

### 12.2 Phased approach
- **Phase 1 (rules):** simple clustering, fixed time windows, price tables set by drivers.
- **Phase 2 (statistics):** averages and trends from 4–8 weeks of real data.
- **Phase 3 (ML):** demand forecasting, no-show model, dynamic suggestions.

Do not build heavy ML before there is real data.

### 12.3 Matching score (starting formula)
```
score = 0.35 * price_fit
      + 0.25 * driver_rating
      + 0.20 * proximity_to_first_pickup
      + 0.10 * seat_fit
      + 0.10 * driver_reliability
```
Weights are tuned later from acceptance and satisfaction data.

### 12.4 Simplified matching pseudocode
```
for each route, time_slot in tomorrow:
    riders = confirmed riders for route, time_slot
    groups = cluster(riders, by=pickup_point, max_wait=10min)
    for group in groups:
        car_type = choose_car(len(group))
        candidates = drivers(route, time_slot, car_type, available)
        ranked = sort(candidates, key=score(group))
        for driver in ranked:
            price = driver.price_for(route, len(group))
            if driver.accepts(group, price):
                create_trip(group, driver, price)
                break
        else:
            merge_or_cancel(group)
```

---

## 13. Pricing Model

- **Driver sets** price per person by group size, per route.
- Platform sets **minimum and maximum** limits to prevent abuse.
- Rider always sees the **final price before confirming**.
- **Subscriptions:** "Mon/Wed 13:00 for a month" gives drivers guaranteed income and riders a discount.
- **Commission:** decide early (for example 8–12% from each trip). Be transparent to drivers.
- Cancellation fees apply for late rider cancellation (after the group is formed) and for driver no-shows.

---

## 14. Payments

1. **Phase 1:** cash, with the amount shown in the app and confirmed by both sides.
2. **Phase 2:** Payme / Click / Uzum. The app holds the money and pays the driver after the trip.
3. **Phase 3:** wallet and monthly subscriptions.

Rules: no off-app payments, automatic refunds for driver-caused cancellations, daily or weekly payouts to drivers, receipts for every trip.

---

## 15. Trust, Safety, and Quality

- Verified +998 numbers for riders, admin-verified drivers.
- Driver profile shows photo, car, plate, rating.
- **Reliability score** for riders (no-shows lower it, low score limits booking).
- **Driver rating** and automatic review if it drops below a threshold.
- **SOS button:** alerts admin and the rider's trusted contact with live location.
- **Share Trip link** for family (live location, no personal data).
- **Women-only groups** option.
- **Report and block** at every stage.
- Live trip tracking with off-route and long-stop alerts.
- Trip data kept for dispute handling for a defined period.

---

## 16. Notifications

| Event | Who | Channel |
|---|---|---|
| "Are you going tomorrow?" | Rider | Push (Yes/No buttons) |
| Reminder if no answer | Rider | Push |
| Trip offer | Driver | Push + in-app sound |
| Trip confirmed | Both | Push |
| Driver on the way | Rider | Push |
| Group changed or cancelled | Both | Push + SMS fallback |
| Document expiring | Driver | Push + admin alert |
| Payment and receipt | Both | In-app |

Use Firebase Cloud Messaging, with SMS fallback for critical changes.

---

## 17. Maps and Location

- Map: **OpenStreetMap** (free) or **Yandex Maps** (strong local data). Compare the cost and coverage for Kosonsoy and Namangan.
- Pickup points are predefined and verified by admin.
- Driver app sends GPS only during active trips.
- Location data is minimized and stored only as long as needed.
- Routing and ETA via OSRM, GraphHopper, or Yandex API.

---

## 18. Technical Architecture

### 18.1 Stack
| Layer | Choice |
|---|---|
| Mobile app | Flutter (Android first, then iOS) |
| Backend API | FastAPI (Python) |
| Database | PostgreSQL + PostGIS |
| Cache and queues | Redis + Celery (or RQ) for scheduled jobs |
| Real-time | WebSocket (live trip tracking) |
| Push | Firebase Cloud Messaging |
| SMS | Eskiz.uz / PlayMobile |
| Calls | WebRTC / Agora, or proxy-number provider |
| Maps | OpenStreetMap or Yandex Maps |
| Admin web | React or Next.js |
| Storage | S3-compatible (documents, photos) |
| Hosting | VPS or cloud in a nearby region, Docker |
| Monitoring | Sentry, Prometheus/Grafana, logs |

### 18.2 Backend modules
auth, users, drivers, vehicles, routes, pickup_points, schedules, confirmations, matching, pricing, trips, payments, calls, notifications, ratings, reports, admin, analytics.

### 18.3 Scheduled jobs
- 18:00 send daily questions
- 20:00 close confirmations
- 20:30 grouping
- 21:00 matching and offers
- Hourly: expire offers, reminders
- Nightly: update scores, retrain models, backups

---

## 19. Database Design (Main Tables)

**users**
`id, phone (unique), name, role (rider/driver/admin), gender, photo_url, language, telegram_username (optional, private), reliability_score, status, created_at`

**driver_profiles**
`user_id, license_no, license_expiry, id_doc_url, status (active/suspended), rating, created_by_admin_id, last_doc_check`

**vehicles**
`id, driver_id, type (yengil/damas/avtobus), model, color, plate, seats, registration_doc_url, insurance_expiry, photos`

**routes**
`id, name, origin_geo, destination_geo, distance_km, duration_min, active`

**pickup_points**
`id, route_id, name, location (geography), order_index, verified`

**rider_schedules**
`id, rider_id, route_id, weekday, arrive_by_time, direction, pickup_point_id, active`

**daily_confirmations**
`id, rider_id, schedule_id, date, status (yes/no/no_answer), answered_at`

**driver_availability**
`id, driver_id, weekday, from_time, to_time, route_id`

**driver_prices**
`id, driver_id, route_id, min_riders, max_riders, price_per_person, updated_at`

**trip_groups**
`id, route_id, date, time_slot, status, suggested_car_type`

**trips**
`id, group_id, driver_id, vehicle_id, date, start_time, price_per_person, status (offered/accepted/confirmed/in_progress/completed/cancelled), started_at, ended_at`

**trip_members**
`id, trip_id, rider_id, pickup_point_id, status (confirmed/picked_up/no_show/cancelled), amount, paid`

**journeys**
`id, rider_id, date, status` and **journey_legs** `(journey_id, trip_id, order_index)`

**payments**
`id, trip_member_id, method, amount, commission, status, provider_ref, created_at`

**payouts**
`id, driver_id, period, amount, status`

**ratings**
`id, trip_id, from_user, to_user, stars, comment`

**call_sessions**
`id, trip_id, caller_id, callee_id, started_at, duration, type (voip/proxy)`

**messages**
`id, trip_id, sender_id, text, flagged, created_at`

**reports**
`id, reporter_id, target_id, trip_id, reason, status, admin_notes`

**notifications, otp_codes, audit_logs, settings**

---

## 20. API Overview (examples)

**Auth:** `POST /auth/request-otp`, `POST /auth/verify-otp`, `POST /auth/refresh`
**Rider:** `GET/POST /schedules`, `GET /confirmations/today`, `POST /confirmations/{id}`, `GET /trips/upcoming`, `POST /trips/{id}/confirm`, `POST /trips/{id}/rate`
**Driver:** `GET /driver/offers`, `POST /driver/offers/{id}/accept`, `PUT /driver/prices`, `POST /driver/trips/{id}/start`, `POST /driver/trips/{id}/end`
**Calls and chat:** `POST /trips/{id}/call-token`, `GET/POST /trips/{id}/messages`
**Admin:** `POST /admin/drivers`, `PATCH /admin/drivers/{id}/suspend`, `GET /admin/trips`, `GET /admin/reports`

All endpoints use JWT, role-based access, rate limiting, and input validation.

---

## 21. Security and Privacy

- Phone numbers encrypted at rest, never returned by any rider/driver API.
- Masking enforced on the **server**, not just hidden in the UI.
- OTP rate limits and device binding.
- Admin actions logged, two-factor login for admins.
- Document files stored privately with signed, short-lived URLs.
- Data retention policy and account deletion on request.
- Regular backups, HTTPS everywhere, dependency scanning.

---

## 22. Legal and Compliance (check with a lawyer)

- Passenger transport licensing and rules for organized shared rides in Uzbekistan.
- Insurance requirements for drivers and passengers.
- Personal data law: consent, storage location, location data.
- Rules for recording calls, if used at all.
- Tax treatment of commission and driver income.
- Terms of service, privacy policy, and driver agreement in Uzbek and Russian.

---

## 23. Business Model

- Commission on each trip (8–12% suggested starting point).
- Premium subscriptions for riders (priority matching, guaranteed seat).
- Partnerships with universities and colleges (official student routes).
- Later: corporate shuttles, school transport, intercity routes.

**Unit economics to track:** average riders per trip, average price, commission per trip, cost per SMS and call, riders per driver per week.

---

## 24. Roadmap

| Phase | Weeks | Goal |
|---|---|---|
| 1. Foundation | 1–4 | Auth, profiles, admin dashboard, driver creation |
| 2. Core | 5–8 | Schedules, map, pickup points, daily confirmation, push |
| 3. Matching | 9–12 | Grouping, pricing, offers, masked calls and chat |
| 4. Pilot | 13–16 | 1 route, 3–5 drivers, 30–50 students, cash payments |
| 5. Improve | 17–24 | Payments, ratings, reliability, analytics, AI stats |
| 6. Grow | 25+ | More routes and universities, ML forecasting, iOS |

**Pilot success metrics:** 70%+ of confirmed riders show up, average fill rate above 70%, driver satisfaction above 4.5/5, 50%+ of riders use the app weekly.

---

## 25. Team and Budget (approximate roles)

- 1 product/project lead
- 1–2 Flutter developers
- 1–2 backend developers
- 1 UI/UX designer
- 1 part-time AI/data engineer (from phase 5)
- 1 operations/support person (driver onboarding, complaints)
- Costs: development, servers, SMS, calls, maps, Firebase, legal, marketing, driver onboarding.

---

## 26. Risks and Mitigation

| Risk | Mitigation |
|---|---|
| Too few riders at launch | Start with one route and one university, campus promotion |
| Too few drivers | Admin recruits trusted drivers, guaranteed minimum income in the pilot |
| Drivers bypass the app | Masked contacts, in-app payments, subscription income they can't get elsewhere |
| Rider no-shows | Evening confirmation, reminders, reliability score, cancellation fee |
| Unsafe rides | Admin-verified drivers, SOS, trip sharing, ratings, women-only groups |
| Legal problems | Early legal consultation, official partnerships |
| Poor connectivity in rural areas | Offline-friendly screens, SMS fallback for critical alerts |
| Masked call costs | Prefer VoIP, limit call windows |
| AI too complex too early | Rules first, ML only after real data |

---

## 27. Example Day (Story)

1. Aziza (Kosonsoy) has a Mon/Wed 13:00 schedule for NamSU.
2. Sunday 19:00: the app asks "Are you going tomorrow?" She taps **Yes**.
3. 20:30: AI finds 9 students from Kosonsoy center with the same time.
4. AI picks a **Damas** (up to 8) plus a **Yengil** for the extra riders, or suggests an **Avtobus** if available.
5. A driver, Sherzod, previously set "8+ riders: 20,000 so'm". The offer is sent and he accepts.
6. Monday morning: Aziza sees "Pickup 10:40, Damas 01 A 123 BC, 20,000 so'm."
7. During the trip she can call Sherzod through the app. Neither sees the other's number.
8. At NamSU the trip ends. She pays, rates, and her reliability score goes up.
9. Admin sees the trip in the dashboard with no complaints.

---

## 28. MVP Scope (Strict)

**Include**
- Rider SMS login, weekly schedule, daily confirmation
- Admin-created drivers
- One route with fixed pickup points
- Rule-based grouping and matching
- Driver price table
- Masked in-app call/chat
- Cash payment, ratings, basic admin panel

**Exclude for now**
- ML models, online payments, multi-leg automation, iOS, door-to-door pickup, wallet

---

## 29. Next Steps

1. Validate the route: survey 100 students and talk to 5–10 drivers.
2. Check the legal requirements.
3. Choose providers: SMS, calls, maps.
4. Design the UI (Uzbek and Russian) and test with 10 students.
5. Finalize the database schema and the matching rules.
6. Build Phase 1 and run the pilot.

---

*Document version 1.0, prepared for the AI Taksi project.*

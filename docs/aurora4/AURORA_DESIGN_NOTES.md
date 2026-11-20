# AI Taksi Aurora 2026 — UI/UX design handoff

## Design direction

This rebuild directly uses the visual vocabulary of the **12-slide AI Taksi pitch** (reference slides 04 and 05 in `design_references/`), rather than the prior emerald/cream color scheme.

- **Midnight navy `#071529`** — chrome, app header, bottom navigation, premium journey areas
- **Electric violet `#783DF5`** — primary selection, interactive controls, visual identity
- **Aurora cyan `#00E9E5`** — route paths, vehicle highlights, confirmation emphasis, positive action on dark
- **Indigo `#172B61`** — navy-to-violet blending and deep cards
- **Periwinkle surface `#F6F7FF`** — breathable screen canvas
- **Lavender border `#E4E5F4`** — low-contrast structure
- **Warm amber `#F7BE5D`** — ratings/rare status details

Visual patterns: cinematic photo illustration taken from the approved title slide; layered navy-to-violet route gradients; cyan route path; rounded 16–27px interactive surfaces; accessible light content panels; consistent 4-tab navigation; explicit offline-demo tags; immediate feedback on mocked user actions.

## Design decisions

1. Keep **passenger** and **driver** flows separate but in one demo shell so one tester can inspect both roles.
2. Put route and trip confirmation first. Avoid hiding the next important passenger action behind decorative content.
3. Present prices/passenger counts as **sample values** until live API connectivity is implemented.
4. Keep service logic in `lib/studio/studio_state.dart` using Riverpod; UI widgets only render state and delegate events.
5. Keep all assets local, so the application and standalone browser preview do not require network connectivity.
6. The browser preview (`preview/index.html`) is a functional design companion, **not a Flutter web build**.
7. Preserve the existing backend under `ai_taksi_data/` byte-for-byte. No API or database changes.

## Main screens

| Rider | Driver |
|---|---|
| Home with cinematic Kosonsoy → NamSU route | Earnings dashboard with an aurora graph |
| Daily go/no-go confirmation | Driver offers with live demo countdowns |
| Weekly schedule editor | Price bands editable in memory |
| Trip offer, booking, status, rating | Ordered pickup list and passenger count |
| In-trip *demo* chat with client-side filtering | In-trip *demo* chat and driver profile |
| Notifications, profile, reset | Notifications, role switching, reset |

## Files changed relative to previous premium demo

- `ai_taksi_flutter/lib/studio/studio_design.dart` — new tokens, map treatment, cinematic hero
- `ai_taksi_flutter/lib/studio/studio_app.dart` — new onboarding hero/header/nav
- `ai_taksi_flutter/lib/studio/rider_pages.dart` — new home hierarchy and accent CTA
- `ai_taksi_flutter/lib/studio/driver_pages.dart` — new earnings visualization colors
- `ai_taksi_flutter/pubspec.yaml` — local bundled WebP image assets
- `ai_taksi_flutter/assets/images/` — cropped slide imagery, bundled offline
- `preview/index.html` — new standalone visual system, with inline local image data
- `preview/` — interaction tests and updated screenshots

The backend, matching engine, schemas, migrations, provider contracts, and existing mock-data values were not altered.

## Verification actually performed

- `python -m pytest -q tests` from `ai_taksi_data/`: **19 passed**
- Browser Playwright smoke test: **pass**, including trip, schedules, chat rejection of contact strings, offers, pricing, pickups
- Browser JavaScript syntax: **pass**
- Browser: **no external network calls or JavaScript errors** in tested flows
- Screenshots captured at 390×844 and 1360×900
- Flutter SDK and Dart were unavailable, so **`flutter analyze`, `flutter test`, and APK build were NOT run**. Flutter compilation is unverified.

## Android commands

```bash
cd ai_taksi_flutter
flutter create --platforms=android --project-name ai_taksi .
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

Review/preserve `android/app/src/{main,debug}/AndroidManifest.xml` when creating the missing Android scaffold, particularly release HTTP restrictions.

## Security limit

The sample chat blocks common phone/username/link patterns in the local client for interaction demos only. It is *not* a production guarantee: a real chat API must enforce moderation, access permissions, contact masking, and time windows on the server. No real SMS, payment, GPS, calls, or bookings are performed in offline demo mode.

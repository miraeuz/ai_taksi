# AI Taksi — Telegram-style Offline Mobile Demo (V5)

A rebuilt Uzbek-first rider and driver mobile demo. The design takes **interaction and spacing cues** from Telegram but is independently branded as AI Taksi and is **not affiliated with Telegram**. It uses consistent line icons, fast scanning lists, grouped settings, a compact bottom tab bar, blue accents, and matched Android system navigation colors. The sunset-road minibus appears only in a restrained promotional hero.

## Contents

- `ai_taksi_flutter/` — Flutter Android app; new interactive demo code under `lib/telegram/`. Its `lib/main.dart` opens the new UI. Legacy Aurora/NOVA code is retained for reference but is not the active entry point.
- `ai_taksi_flutter/assets/images/app_logo.png` — unique new AI Taksi icon used in mock login and branded screen header.
- `ai_taksi_flutter/android/app/src/main/res/` — Android launcher icon mipmaps, adaptive icon, light/dark launch styles.
- `ai_taksi_data/` — **unchanged backend** copied from Aurora 4.0 including migrations, auth, tests and matching engine.
- `preview/index.html` — independent offline interactive browser approximation of the new design (open in a browser), with JavaScript and CSS.
- `mock_data/ai_taksi_mock_dataset.json` — reproducible test fixtures (96 fictional riders, 15 fictional drivers, 12 offers, 11 destinations, 6 origins and 7 vehicle models).
- `docs/` — checks and constraints.

## What changed

1. Proper app icon: source PNG, Android mipmap densities, adaptive icon resource, launcher references.
2. Material 3 Telegram-inspired UI: light & dark themes, high-contrast type, clear list rows, blue avatars, calmer spacing, accessible labels.
3. Physical Android bottom navigation bar: light/dark nav colors with matching foreground glyph brightness, plus edge-to-edge layout behind the system navigation area. Android 15 and hardware verification are still required.
4. New mock login: passenger and driver role choice, sample name, quick entry **or demo code `123456`**; no actual phone number or SMS provider used.
5. Expanded sample destinations: Yuksalish / NamDU newer campus, NamDU main campus, Namangan State Technical University, Namangan Pedagogical Institute, University of Business and Science, Davlatobod, city center, railway station, bus station, market and medical area. More mock origins include Kosonsoy, To‘raqo‘rg‘on, Chust, Yangiqo‘rg‘on, Pop and Namangan.
6. Interactive offline flows: daily confirmation, booking, trip progress, five-star rating, schedule editing, search, saved places, car comparison, group size, driver offers (accept/decline), group-size tariffs, ordered pickups, mock chat, notifications, theme/role switching, and safety preview.
7. 7 sample car models mapped to the 3 real backend enum categories (Yengil / Damas / Avtobus). No real inventory or GPS tracking is claimed.

## Build on Windows / Android

**Requirements:** Flutter 3.29+ (stable), compatible Dart, Android SDK/platform tools, configured `flutter doctor`. The native Android scaffold in the original project was partial, so finish it with `flutter create` before building.

```sh
cd ai_taksi_flutter
flutter create --platforms=android --project-name ai_taksi .
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

Do **not** remove the existing Android manifest and app icon resources when running `flutter create`. If prompted to overwrite existing project files, preserve the custom `android/app/src/main/AndroidManifest.xml`, `android/app/src/debug/AndroidManifest.xml`, `android/app/src/main/res/` and `pubspec.yaml`.

If compilation succeeds, the APK is at `ai_taksi_flutter/build/app/outputs/flutter-apk/app-debug.apk`.

**Browser preview:** Open `preview/index.html` directly, or run `python -m http.server 8765` inside `preview/` and visit `http://localhost:8765`.

## Mock login

Choose **Yo‘lovchi** or **Haydovchi**. Tap **Demo sifatida kirish**. Alternatively choose **SMS kod kirishini sinash**, enter `123456`, and sign in. This is a deliberately fake credential for a local demo only. It never sends SMS or authenticates with the production API.

## Privacy & safety boundaries

The browser and Flutter previews are mock-only. The chat rejects phone-number, username and web-link patterns locally; this is **not a production security boundary**. The real backend does not yet implement trip chat. The safety preview does not dispatch SOS, share trips, make calls or track live locations. Do not release it as a transport service without server-side protections and legal/safety validation.

All personal names and driving data in the fixture are fictional. Place names are based on real regional naming, but **pickup-point precise positions, offers, prices, operating hours, and availability are illustrative**, not verified.

## Verification

See `docs/QA.md`: backend regression tests pass. Browser JavaScript syntax and 12 local logic checks pass. Dart source structural checks pass; **no Flutter compiler/SDK is installed here**, so Flutter analyze, tests and APK compilation have **not** run. The browser's GUI rendering could not be tested in this environment due to managed browser restrictions; the browser preview is provided for inspection on your machine.

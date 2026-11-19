# AI Taksi — redesigned Flutter demo (Uzbek)

This package contains an **improved Material 3 Flutter UI** with **interactive, offline sample data**, an **independent browser design prototype**, and a **byte-for-byte copy of the previously audited Python backend** (unchanged).

## Try the design now — no Flutter or server

Open `preview/index.html` in a desktop/mobile browser. The responsive prototype contains the key rider and driver flows, all using local state. It is a design preview, **not the Flutter runtime**. It is offline, has no API calls, and does not process real payments, SMS, bookings, or communication.

### Rider journey to click through
1. Start at **Asosiy**. Tap **Ha, boraman**.
2. Open **Safarlar**. Review sample Damas (8 riders / 20,000 so'm), then **Safarni tasdiqlash**.
3. Start and finish the mocked trip; leave a five-star rating.
4. In **Jadval**, change departure stop, weekly days and arrival time.

### Driver journey to click through
1. Go to **Profil**, switch role to **Haydovchi**.
2. Go to **Takliflar**, see countdown; accept/decline and ordered stops.
3. Go to **Narxlar** and edit the eight-passenger per-person price.

## Launch Flutter Android demo

Prerequisites: Flutter stable with Dart >=3.4, Android SDK/emulator or Android device.

```bash
cd ai_taksi_flutter
flutter create --platforms=android --project-name ai_taksi .
flutter pub get
flutter analyze
flutter test
flutter run
# For an APK:
flutter build apk --debug
```

At launch select **Yo‘lovchi sifatida** or **Haydovchi sifatida**. This **offline demo** requires no backend and does not send sample data to the backend. All changes are in-memory and reset on restart. Choose **Haqiqiy API orqali kirish** to enter the existing live authentication flow and backend-connected screens (these retain their original layouts). For Android emulator live API requests use:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

The Flutter project still contains only a partial native Android scaffold from the previous version; `flutter create` generates the remainder. Preserve the existing `android/app/src/main/AndroidManifest.xml` and `android/app/src/debug/AndroidManifest.xml` when generating the scaffold. The release manifest should **not** allow cleartext HTTP.

## Design changes

- **System:** deep navy + soft teal + mint, elevated white cards, consistent spacing, larger typography, rounded corners and a four-tab bottom navigation.
- **Rider:** personalized home, route card, confirmation card, interactive schedule editor, trip offer, current trip, rating, history mockup.
- **Driver:** earnings sample, offer countdown, ordered pickup list, editable price table and profile switching.
- **Navigation:** choose demo role without OTP; role switch and reset in Profile.
- **Privacy:** demonstration chat blocks common phone-number, @handle and Telegram-link forms and enforces a sample one-hour window on the **client only**.
- **No server changes:** the copied backend files are unchanged; no new backend API routes are assumed.

## Demo seed values

- Pilot route: Kosonsoy → Namangan State University (NamSU).
- Rider: Aziza (fictional first name), weekly Monday/Wednesday, arrive by 13:00.
- Stops: Kosonsoy markazi, Kosonsoy bozori, Kosonsoy janub, Yo‘l bo‘yi 1, Yo‘l bo‘yi 2, Namangan kirish.
- Trip: sample Damas, plate `01 A 123 BC` (illustrative only), pickup 10:40, eight passengers, 20,000 so'm per rider.
- Driver: Sherzod (fictional first name), sample 4.9 rating, sample weekly earnings of 840,000 so'm.

All sample price, earnings, trip and rating values are synthetic; none is a verified live transaction.

## What was checked here

- New browser preview JavaScript parsed successfully with `node --check`.
- ZIP file integrity and package content were checked.
- **Not executed:** Flutter SDK (`flutter analyze`, `flutter test`, `flutter build apk`) because Flutter and Dart are not installed in this environment. The source is provided for local execution and may need SDK-specific fixes.
- The previous backend's reported 19 passing tests are historical results, **not a new test run**.

## Important safety & product limitations

- Client-side chat filters are not security enforcement. The backend has no real trip chat service; never enable real chat without server-side filtering, permissions and time-window checks.
- The mock route visual is illustrative, not geospatial navigation or live driver tracking.
- A real rider trip list, trip details, ratings and pickup-point discovery still require backend endpoints. The existing live screens correctly label such portions as previews.
- This ZIP contains no `.env` secrets or valid tokens; `.env.example` files remain examples only.

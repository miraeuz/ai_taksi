# AI Taksi — Flutter Android client

**Status:** Flutter frontend source is written; Dart/Flutter SDK is not installed in the authoring environment, so `flutter analyze`, `flutter test`, and APK build could not be run here. This is a frontend-only deliverable, not a working backend extension.

## Prerequisites
- Flutter stable (Dart 3.4+), Android SDK, working Android emulator/device.
- Existing AI Taksi FastAPI backend and PostgreSQL database with migrations and seed data.

## Build and launch
```sh
cd ai_taksi_flutter
flutter create --platforms=android --project-name ai_taksi .
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
flutter build apk --release --dart-define=API_BASE_URL=https://your-secure-api.example
```

`10.0.2.2` points to the development PC from an Android emulator. For a physical device, use the PC LAN IP and ensure it is accessible. For production use HTTPS and remove `android:usesCleartextTraffic="true"` from the Android manifest; this flag is for local emulator development only.

The folder contains the app Dart sources, an Android manifest with Internet permission, and a unit test. `flutter create` initializes the standard Android Gradle/Kotlin files using your installed Flutter SDK without modifying the Python backend. If Flutter warns about existing platform files, back up the supplied manifest and restore it after scaffold generation.

## Architecture
- `lib/data/api.dart`: Dio API repository, secure token storage, access token refresh once after 401.
- `lib/state/providers.dart`: Riverpod providers and authentication controller.
- `lib/models/models.dart`: typed API response models.
- `lib/ui/screens/`: screens are presentation and orchestration; API code stays in repositories.
- `lib/core/chat_policy.dart`: client-side chat time-window and message filter (not a server security boundary).
- `lib/ui/widgets/common.dart`: reusable empty/loading/error states, cards, explicit preview warning.

## Live contracts matched to the unmodified backend

| Feature | Actual API | Status |
|---|---|---|
| Rider signup and existing user login | `POST /auth/request-otp`, `POST /auth/verify-otp` (`purpose=signup/login`) | Connected |
| Driver OTP login | Same login endpoint; drivers are admin-created only | Connected |
| Session recovery | `GET /auth/me`, `POST /auth/refresh` | Connected |
| Rider weekly schedules | `GET/POST /rider/schedules`, `DELETE /rider/schedules/{id}` | Connected; pilot route ID and pickup IDs are configurable samples |
| Today's confirmation | `GET /rider/confirmations/today`, `POST /rider/confirmations/{id}` with yes/no | Connected |
| Driver price table | `GET /driver/prices`, `PUT /driver/prices` | Connected |
| Driver offers | `GET /driver/offers`, `POST /driver/offers/{id}/accept`, `/decline` | Connected; current API only returns offer id, trip id, status, expiration |
| Trip confirmation | `POST /rider/trips/{id}/confirm` | Repository method exists, but no rider trip listing/detail endpoint provides safe real IDs |

### Explicit previews — not connected
- Pickup-point name list: backend does not expose `GET /routes` or `GET /pickup-points`. UI uses sample IDs 1–6, verified by backend on schedule creation. IDs can differ from actual database IDs.
- Rider trip offers, full car/plate/price data: no rider offer listing/detail endpoint. An illustrative Damas offer shows **Namoyish** and never sends a fake confirmation.
- Trip detail and ordered pickup list, active trip information: no corresponding endpoints. These remain labelled previews.
- Rating submit: ratings model exists, but no `POST /trips/{id}/rate` endpoint. UI never claims the rating was sent.
- Chat: no message read/write endpoints or realtime interface. Chat is only local memory; regex guards against phone numbers/handles and window access, but must ALSO be enforced by the server to be secure. No messages are persisted/transmitted.
- Driver offer details: real API only provides limited offer fields; do not fabricate route, price, vehicle, passenger identities in live cards.

**Safety**: No phone numbers are shown as profile data in authenticated screens; phone is used only for login. Tokens are held in secure storage. The Flutter client cannot enforce server-side privacy, chat content filtering, or clock-based access authorization; the backend must do those before live launch.

## UX
Material 3, white surfaces, teal accent, rounded cards, Uzbek default, graceful loading/error/retry on network-backed screens, preview warning on unsupported flows. No fake successful API confirmations.

# AI Taksi — AURORA 4 (visual-only redesign)

This archive extends the existing NOVA 3 demo. The **FastAPI backend, Alembic files, SQLAlchemy models, matching, SMS, role checks and data are unchanged**. Rider and driver demo actions still run on Riverpod mock state, entirely offline. No real booking, SMS, SOS or location sharing occurs.

## Design direction

The actual competition slides are the reference. They feature a deep midnight-navy frame, an electric violet gradient, cyan route glows, rounded purple icon holders and a sunset Namangan road with a white Damas-style minibus. AURORA 4 applies these traits to shared Flutter components, both navigation surfaces, and all mounted rider/driver pages.

| Design token | HEX | Use |
| --- | --- | --- |
| Midnight | `#08142D` | Headers and trip hero |
| Deep background | `#0B1129` | Night surfaces |
| Electric violet | `#713FF5` | Primary actions and icon tiles |
| Indigo | `#17265A` | Gradient endpoints |
| Cyan | `#00E7E8` | Routes, status and accent |
| Morning canvas | `#F7F8FE` | Light background |
| Dark card | `#192445` | Frosted night card |

Material 3 themes have shared typography, controls, chips and form colors. The AppBar sun/moon icon and **Profile → Ko‘rinish** switch toggle themes without modifying ride or pricing state. Colors in the pitch slides are visual guidance, not an accuracy guarantee for generated images.

## What was edited

- `lib/studio/studio_design.dart`: light/dark theme, frosted cards, icons, gradients, map visualization and cinematic hero.
- `lib/studio/studio_app.dart`: welcome, top navigation, bottom tab bar and theme toggle.
- `lib/studio/{rider_pages,driver_pages,fleet_page,shared_pages,safety_page}.dart`: visual contrast, dark cards, dialogs, and profile appearance controls. The original missing import and closing class brace in the safety page were corrected to restore valid Dart structure.
- `test/aurora_theme_test.dart`: tests the two theme palettes and that the visual toggle does not modify rider trip state.
- `preview/`: corresponding interactive browser styling, light/dark toggle, responsive previews and browser regression checks.

## Flutter commands

Start with the Flutter SDK installed and Android SDK configured. This archive contains a **partial native Android scaffold** inherited from NOVA. From `ai_taksi_flutter`:

```bash
flutter --version
flutter create --platforms=android --project-name ai_taksi .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Preserve the two existing `android/app/src/{main,debug}/AndroidManifest.xml` files when recreating Android scaffolding. The `flutter create` command can modify generated native files; review the diff before committing. If the build succeeds, the expected APK path is `build/app/outputs/flutter-apk/app-debug.apk`.

## Verified and not verified

- Browser JavaScript syntax via `node --check`: PASS.
- Existing browser interaction regression: **18/18 PASS**.
- AURORA 4 theme and browser smoke suite: **10/10 PASS**.
- Backend regression (unchanged backend): **19/19 PASS**.
- Flutter SDK is absent in the execution environment: `flutter analyze`, `flutter test`, and `flutter build apk --debug` all return **command not found (127)**. No compiled APK has been produced.
- New Dart source has passed a delimiter-balance structural check, **not** Dart type checking or compilation. The Flutter tests in `aurora_theme_test.dart` remain unexecuted.

## Runtime scope

This is an offline UI/UX testing app with local sample users, seven vehicle models and three transport categories. Future API integration is a separate step; this redesign does not add an API, alter a model, or create real chat/masked calls. The browser preview mirrors the high-level interactions and visuals but is not the Flutter runtime.

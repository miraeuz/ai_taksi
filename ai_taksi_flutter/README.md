# AI Taksi Flutter — redesigned demo

See `../README.md` for full instructions.

App entry: `lib/main.dart`. Offline Riverpod state: `lib/demo/demo_state.dart`. Redesigned widgets/screens: `lib/demo/demo_screens.dart`, `lib/demo/demo_theme.dart`. Original live API screens remain under `lib/ui/screens/`.

Run:

```bash
flutter create --platforms=android --project-name ai_taksi .
flutter pub get
flutter analyze
flutter test
flutter run
```

**Demo mode sends no network requests.** Live API mode is an explicit separate button on the launch screen.

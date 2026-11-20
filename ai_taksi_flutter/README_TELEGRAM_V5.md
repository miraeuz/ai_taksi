# AI Taksi Telegram-inspired V5 — Flutter

The active entry point is `lib/main.dart`, and the active implementation lives in `lib/telegram/`.

Main modules:
- `telegram_app.dart`: fake login, app shell, consistent bottom navigation, system-bar theme.
- `tg_theme.dart`: light/dark material theme and core color tokens.
- `tg_widgets.dart`: reusable avatars, badges, cards, rows, pickers.
- `mock_data.dart`: sample locations, vehicles, trips and history.
- `demo_state.dart`: mock session and all actions via Riverpod.
- `rider_pages.dart`: rider landing, search, trip, schedule, details.
- `driver_pages.dart`: driver dashboard, offers, tariffs, pickup list.
- `more_pages.dart`: profile, fleet, chat, notifications, safety.

No backend endpoints are called from the new demo app. All changes are in-memory and reset after restart (the browser preview additionally persists its mock state in localStorage).

See root `README.md` for build and test commands. Android native generation requires an installed Flutter SDK. Preserve existing launcher and manifest files when completing that scaffold.

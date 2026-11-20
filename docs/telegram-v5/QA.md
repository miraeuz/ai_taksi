# QA & verification — AI Taksi V5

## Executed

- Backend (unchanged) `python -m pytest -q`: **19 passed in 1.50s**.
- Browser JavaScript `node --check preview/app.js`: **passed**.
- Browser logic test `node docs/browser_logic_test.js`: **12/12 pass**. Covers mock login, multiple destinations, selecting a route, trip lifecycle, phone-blocked chat, theme switch, role switch, driver offers, prices, pickup checklist and logout.
- Dart source bracket and quote-aware structural check using the installed Pygments Dart lexer: **8/8 new Dart source files balanced**. This does **not** replace Dart type checking.
- Android app launcher resources generated: standard-density `mipmap-*`, adaptive icon, light/dark styles and manifest links.
- Original backend file comparison: all **42 original source/config files byte-for-byte unchanged** after removing generated pytest caches.

## Not executed / limitations

- `flutter analyze`: cannot run because Flutter command is absent.
- `flutter test`: cannot run because Flutter command is absent. Flutter test source files are included.
- `flutter build apk --debug`: cannot run because Flutter command is absent. **No debug APK** is provided.
- Native Android runtime/real device system bar behavior: not verified on hardware.
- Browser screenshot and full DOM integration: managed Chromium browser blocks all local URLs. The preview passes pure JS logic tests but **visual rendering and click targets need confirmation in an unrestricted browser**.
- External integrations: none; backend remains disconnected, SMS fake, chat and SOS mock only.

## Known remaining risks

- Flutter static type errors could remain until actual `flutter analyze` and `flutter build` run.
- Production route support is still limited: adding mock destinations does not add API endpoints or transport inventory.
- The chat filter is client-side only and cannot guarantee information masking on a real backend.
- If `flutter create` overwrites native resources, manually restore launcher assets and manifest styles from this archive.
- System gesture navigation on Android 15+ uses edge-to-edge behavior; test both gesture and 3-button mode on a real Android device.

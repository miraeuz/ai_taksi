@echo off
setlocal
cd /d "%~dp0ai_taksi_flutter"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter not found. Install Flutter SDK and Android SDK, then rerun.
  echo See README.md for installation and preserving launcher icons.
  exit /b 1
)
flutter --version
flutter doctor
rem On first use, complete the partially generated native Android scaffold.
rem Existing app launcher resources, manifests and pubspec.yaml must be kept.
flutter create --platforms=android --project-name ai_taksi .
if errorlevel 1 exit /b 1
flutter pub get
if errorlevel 1 exit /b 1
flutter analyze
if errorlevel 1 exit /b 1
flutter test
if errorlevel 1 exit /b 1
flutter build apk --debug
if errorlevel 1 exit /b 1
echo.
echo Debug APK: build\app\outputs\flutter-apk\app-debug.apk
pause

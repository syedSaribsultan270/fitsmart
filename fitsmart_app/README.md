# FitSmart AI

Your AI-Powered Fitness & Nutrition Companion — built with Flutter, Riverpod, Drift, Firebase, and Gemini.

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Set up your API key

```bash
cp .env.example .env
# Edit .env and add your Gemini API key
```

Get a free Gemini API key at: https://aistudio.google.com/apikey

### 3. Run the app

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

> **⚠️ Security:** Never hardcode API keys in source code. Always use `--dart-define` to inject them at build time. The `.env` file is gitignored and will never be committed.

### 4. Firebase setup (optional — already configured for web)

For Android/iOS, download platform config files from the [Firebase Console](https://console.firebase.google.com/):

- **Android:** Place `google-services.json` in `android/app/`
- **iOS:** Place `GoogleService-Info.plist` in `ios/Runner/`

These files are gitignored for security.

## Architecture

| Layer | Technology |
|---|---|
| UI | Flutter + Material 3 (dark theme) |
| State | Riverpod (StateNotifier, StreamProvider) |
| Navigation | GoRouter |
| Local DB | Drift (SQLite) |
| Auth | Firebase Auth + Google Sign-In |
| AI | Google Gemini 2.5 Flash |
| Analytics | Firebase Analytics + Crashlytics |

## Security

- API keys injected via `--dart-define` (never hardcoded)
- Firebase Security Rules enforce per-user data isolation
- Cleartext HTTP traffic disabled on Android
- iOS App Transport Security (ATS) enforced
- All AI requests routed through Google's TLS endpoints

See the [Flutter docs](https://docs.flutter.dev/) for more info.

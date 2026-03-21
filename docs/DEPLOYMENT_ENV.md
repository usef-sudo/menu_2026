# Production build configuration

Pass secrets and endpoints at **build time** with `--dart-define` (or your CI’s equivalent).

## Required for production

| Define | Purpose |
|--------|---------|
| `APP_FLAVOR=prod` | Enables prod defaults in [`lib/app/config/app_environment.dart`](../lib/app/config/app_environment.dart) |
| `API_BASE_URL` | HTTPS origin of the Menu API (no trailing `/api`) |
| `SENTRY_DSN` | Crash reporting ([Sentry](https://sentry.io)); empty DSN disables reporting |

## Google Maps

- **Android:** `GOOGLE_MAPS_API_KEY` environment variable or `local.properties` — see [android/MAPS_KEY.md](../android/MAPS_KEY.md).
- **iOS:** Copy `ios/Secrets.xcconfig.example` to `ios/Secrets.xcconfig` and set `GOOGLE_MAPS_API_KEY`, or inject that file in CI.

## Legal / store listings

| Define | Purpose |
|--------|---------|
| `LEGAL_PRIVACY_URL` | Public privacy policy URL (opened from Profile) |
| `LEGAL_TERMS_URL` | Public terms of service URL |

## Example release build

```bash
flutter build apk \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=SENTRY_DSN=https://your-key@o.ingest.sentry.io/project \
  --dart-define=LEGAL_PRIVACY_URL=https://yourdomain.com/privacy \
  --dart-define=LEGAL_TERMS_URL=https://yourdomain.com/terms
```

Set `GOOGLE_MAPS_API_KEY` in the environment for the Gradle step (Android) and provide `ios/Secrets.xcconfig` for Xcode (iOS).

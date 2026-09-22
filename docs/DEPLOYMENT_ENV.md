# Production build configuration

Pass secrets and endpoints at **build time** with `--dart-define` (or your CI’s equivalent).

## Required for production

| Define | Purpose |
|--------|---------|
| `APP_FLAVOR=prod` | Enables prod defaults in [`lib/app/config/app_environment.dart`](../lib/app/config/app_environment.dart) |
| `API_BASE_URL` | Origin of the Menu API (no trailing `/api`). Current VPS: `http://169.58.151.217:8000` |
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
  --dart-define=API_BASE_URL=http://169.58.151.217:8000 \
  --dart-define=SENTRY_DSN=https://your-key@o.ingest.sentry.io/project \
  --dart-define=LEGAL_PRIVACY_URL=https://yourdomain.com/privacy \
  --dart-define=LEGAL_TERMS_URL=https://yourdomain.com/terms
```

Set `GOOGLE_MAPS_API_KEY` in the environment for the Gradle step (Android) and provide `ios/Secrets.xcconfig` for Xcode (iOS).

## Flutter web (Firebase Hosting)

Firebase Hosting is HTTPS. The current VPS API (`http://169.58.151.217:8000`) is HTTP. Browsers **block mixed content**, so a Hosting deploy will not load the API or images until the API is served over HTTPS.

Required before a working web deploy:

1. Point a domain at `169.58.151.217` and terminate TLS (nginx/caddy + Let’s Encrypt).
2. Set `PUBLIC_BASE_URL=https://api.YOUR_DOMAIN` on the VPS so `/api/media` URLs are HTTPS.
3. Set `CORS_ORIGINS` to the Hosting origin, e.g. `https://YOUR_PROJECT.web.app`.
4. In Firebase Console create a project (Hosting only is enough). Replace `YOUR_FIREBASE_PROJECT_ID` in `.firebaserc`.
5. Restrict the Maps JS key in [web/index.html](../web/index.html) to the Hosting HTTP referrer.

Build and deploy (from `menu_2026/`):

```bash
flutter build web --release \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=API_BASE_URL=https://api.YOUR_DOMAIN

firebase deploy --only hosting
```

Do **not** point the web build at `http://169.58.151.217:8000`. That URL will fail in the browser on an HTTPS Hosting origin.


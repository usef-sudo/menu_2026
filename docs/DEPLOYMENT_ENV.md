# Production build configuration

Pass secrets and endpoints at **build time** with `--dart-define` (or your CI’s equivalent).

## Required for production

| Define | Purpose |
|--------|---------|
| `APP_FLAVOR=prod` | Enables prod defaults in [`lib/app/config/app_environment.dart`](../lib/app/config/app_environment.dart) |
| `API_BASE_URL` | Origin of the Menu API (no trailing `/api`). HTTPS (Caddy): `https://169.58.151.217.sslip.io`. Direct HTTP still available at `http://169.58.151.217:8000` for existing mobile builds. |
| `SENTRY_DSN` | Crash reporting ([Sentry](https://sentry.io)); empty DSN disables reporting |

## Google Maps

- **Android:** `GOOGLE_MAPS_API_KEY` environment variable or `local.properties` — see [android/MAPS_KEY.md](../android/MAPS_KEY.md).
- **iOS:** Copy `ios/Secrets.xcconfig.example` to `ios/Secrets.xcconfig` and set `GOOGLE_MAPS_API_KEY`, or inject that file in CI.
- **Web:** Maps JS key is in [web/index.html](../web/index.html). Restrict it in Google Cloud to `https://menu-78832.web.app/*` and `https://menu-78832.firebaseapp.com/*`.

## Legal / store listings

| Define | Purpose |
|--------|---------|
| `LEGAL_PRIVACY_URL` | Public privacy policy URL (opened from Profile) |
| `LEGAL_TERMS_URL` | Public terms of service URL |

## Example Android release build

```bash
flutter build apk \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=API_BASE_URL=https://169.58.151.217.sslip.io \
  --dart-define=SENTRY_DSN=https://your-key@o.ingest.sentry.io/project \
  --dart-define=LEGAL_PRIVACY_URL=https://yourdomain.com/privacy \
  --dart-define=LEGAL_TERMS_URL=https://yourdomain.com/terms
```

Set `GOOGLE_MAPS_API_KEY` in the environment for the Gradle step (Android) and provide `ios/Secrets.xcconfig` for Xcode (iOS).

## Flutter web (Firebase Hosting)

Firebase project: `menu-78832`  
Live site: https://menu-78832.web.app  
Admin login: https://menu-78832.web.app/admin/login

Hosting is HTTPS. The web build must call the HTTPS API (`https://169.58.151.217.sslip.io`). Caddy on the VPS terminates TLS and reverse-proxies to Node on `127.0.0.1:8000`. Port 8000 stays open so older APKs keep working.

VPS env:

- `PUBLIC_BASE_URL=https://169.58.151.217.sslip.io` so `/api/media` URLs are HTTPS
- `CORS_ORIGINS=https://menu-78832.web.app,https://menu-78832.firebaseapp.com`

Build and deploy (from `menu_2026/`):

```bash
flutter build web --release \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=API_BASE_URL=https://169.58.151.217.sslip.io

firebase deploy --only hosting
```

Do **not** point the web build at `http://169.58.151.217:8000`. Browsers block that mixed content on an HTTPS Hosting origin.

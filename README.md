# Menu 2026

Production Flutter app for restaurant discovery and decision support.

## Product Scope

- Restaurant discovery
- Branch maps and nearby browsing
- Branch voting
- Favorites
- Spin wheel decision flow
- Category browsing

Menu is not a food ordering app.

## Tech Stack

- Flutter + Material 3
- Riverpod state management
- GoRouter navigation
- Dio networking with interceptors
- Sentry + logger observability

## Run (Dev → VPS API)

Default API base URL is the VPS: `http://169.58.151.217:8000` (see `lib/app/config/app_environment.dart`).

```bash
flutter pub get
flutter run --dart-define=APP_FLAVOR=dev
```

Local API instead:

```bash
flutter run --dart-define=APP_FLAVOR=dev --dart-define=API_BASE_URL=http://localhost:8000
```

## Backend pull & restart (VPS)

On the server (`/opt/menu_jo_backend`):

```bash
cd /opt/menu_jo_backend
sudo git pull
sudo -u menuapi -- env HOME=/var/lib/menuapi bash -c 'cd /opt/menu_jo_backend && npm ci && npm run build'
sudo systemctl restart menu-api
curl -sS http://127.0.0.1:8000/api/health/ready
```

## Useful Commands

```bash
flutter analyze
flutter test
```

## Docs

- `docs/WORKSPACE_ROOT.md`
- `docs/API_CONTRACT.md`
- `docs/DESIGN_SYSTEM.md`
- `docs/MIGRATION_CHECKLIST.md`
- `docs/RELEASE_HARDENING.md`
- `docs/DEPLOYMENT_ENV.md` — production dart-define, Maps keys, Sentry, legal URLs

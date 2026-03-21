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

## Run (Dev)

```bash
flutter pub get
flutter run --dart-define=APP_FLAVOR=dev --dart-define=API_BASE_URL=http://localhost:8000
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

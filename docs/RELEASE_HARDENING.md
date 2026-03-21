# Release Hardening Checklist

## Security

- No hardcoded admin credentials in mobile client
- JWT stored with `flutter_secure_storage`
- Auth header injected only when token exists
- Environment values loaded from dart-define at runtime
- Google Maps keys: never commit real keys; use `GOOGLE_MAPS_API_KEY` / `ios/Secrets.xcconfig` (see `docs/DEPLOYMENT_ENV.md`, `android/MAPS_KEY.md`)
- API: set `CORS_ORIGINS` in production for browser clients; `/api/docs` off unless `ENABLE_SWAGGER=true`

## Observability

- Structured logger enabled (`logger`)
- Sentry bootstrap wired in `bootstrap.dart`
- Zone-level uncaught exception capture enabled

## Quality Gates

- `flutter analyze`
- `flutter test`
- Smoke integration for core navigation and discovery flow

## Release Readiness

- Configure production API base URL and Sentry DSN via CI
- Set `LEGAL_PRIVACY_URL` and `LEGAL_TERMS_URL` dart-defines to live URLs (store compliance)
- Verify map keys and platform signing
- Verify backend rate limits and API timeout handling in production
- Confirm API `/api/health/ready` passes against production DB (load balancer / k8s probes)

# Release Hardening Checklist

## Security

- No hardcoded admin credentials in mobile client
- JWT stored with `flutter_secure_storage`
- Auth header injected only when token exists
- Environment values loaded from dart-define at runtime

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
- Verify map keys and platform signing
- Verify backend rate limits and API timeout handling in production

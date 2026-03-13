# Menu 2026 Client API Contract (Node v1)

## Base URL

- Default dev: `http://localhost:8000/api`
- Override via dart define: `--dart-define=API_BASE_URL=...`

## Response Normalization Strategy

Node v1 returns mixed shapes:

1. Raw arrays/objects (`restaurants`, `branches`, `offers`, `users`)
2. Envelope responses (`categories`, `menu-images`):
   - `{ "success": true, "message": "...", "data": ... }`

The app normalizes both by using:

- `ApiEnvelope.fromDynamic()` in `lib/core/network/api_envelope.dart`
- DTO mappers per feature

## Endpoints Used by Mobile Discovery App

- `POST /users/login`
- `GET /categories`
- `GET /restaurants`
- `GET /branches`
- `GET /offers`
- `GET /votes/branches/:branchId/votes`
- `POST /votes/branches/:branchId/vote`

## Field Mapping (Legacy Firebase -> Node v1)

### Categories
- `nameAr` / `nameEN` -> `nameAr` / `nameEn`
- `image` -> `imageUrl` (fallback to `image`)

### Restaurants
- `nameAR` / `nameEN` -> `nameAr` / `nameEn`
- `logo` -> `logoUrl`
- `descriptionAr` -> `descriptionAr`

### Branches
- `branchAR` / `branchEN` -> `nameAr` / `nameEn`
- `lat` / `lng` -> `latitude` / `longitude`
- `is_open` integer to bool `isOpen`

## Error Handling Contract

- 401 maps to `AuthFailure`
- Other network/api errors map to `NetworkFailure`
- Errors are exposed as failed `AsyncValue` in Riverpod controllers

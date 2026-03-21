# Google Maps API key (Android)

Do **not** commit API keys. Set the key using one of:

1. **Environment variable** (CI / local shell):

   ```bash
   export GOOGLE_MAPS_API_KEY=your_key_here
   flutter build apk
   ```

2. **`local.properties`** (ignored by git) in `android/`:

   ```properties
   GOOGLE_MAPS_API_KEY=your_key_here
   ```

Restrict the key in [Google Cloud Console](https://console.cloud.google.com/) to your app’s package name and signing SHA-1.

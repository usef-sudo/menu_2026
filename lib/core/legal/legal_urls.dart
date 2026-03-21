/// Host your real documents and pass URLs at build time:
/// `--dart-define=LEGAL_PRIVACY_URL=https://... --dart-define=LEGAL_TERMS_URL=https://...`
abstract final class LegalUrls {
  static const String privacyPolicy = String.fromEnvironment(
    "LEGAL_PRIVACY_URL",
    defaultValue: "https://example.com/privacy",
  );

  static const String termsOfService = String.fromEnvironment(
    "LEGAL_TERMS_URL",
    defaultValue: "https://example.com/terms",
  );
}

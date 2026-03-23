import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

enum AppFlavor { dev, staging, prod }

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.apiBaseUrl,
    required this.sentryDsn,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String sentryDsn;

  bool get isProd => flavor == AppFlavor.prod;

  /// Android emulators reach the host via [10.0.2.2]; iOS Simulator uses localhost.
  /// Override with `--dart-define=API_BASE_URL=...` (e.g. LAN IP on a physical device).
  static String _devDefaultApiBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:8000";
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => "http://10.0.2.2:8000",
      _ => "http://localhost:8000",
    };
  }

  static AppEnvironment fromDartDefine() {
    final flavorText = const String.fromEnvironment(
      "APP_FLAVOR",
      defaultValue: "dev",
    );
    final flavor = switch (flavorText) {
      "prod" => AppFlavor.prod,
      "staging" => AppFlavor.staging,
      _ => AppFlavor.dev,
    };

    final defaultBaseUrl = switch (flavor) {
      AppFlavor.prod => "https://api.menu.app",
      AppFlavor.staging => "https://staging-api.menu.app",
      AppFlavor.dev => _devDefaultApiBaseUrl(),
    };

    return AppEnvironment(
      flavor: flavor,
      apiBaseUrl:
          const String.fromEnvironment("API_BASE_URL", defaultValue: "").isEmpty
          ? defaultBaseUrl
          : const String.fromEnvironment("API_BASE_URL"),
      sentryDsn: const String.fromEnvironment("SENTRY_DSN", defaultValue: ""),
    );
  }
}

final appEnvironmentProvider = Provider<AppEnvironment>((Ref ref) {
  throw UnimplementedError("AppEnvironment override is required in bootstrap.");
});

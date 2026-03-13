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
      AppFlavor.dev => "http://localhost:8000",
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

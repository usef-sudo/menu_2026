import "dart:async";

import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/app/app.dart";
import "package:menu_2026/app/config/app_environment.dart";
import "package:menu_2026/core/observability/app_logger.dart";
import "package:sentry_flutter/sentry_flutter.dart";

Future<void> bootstrap() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final environment = AppEnvironment.fromDartDefine();

    await SentryFlutter.init(
      (options) {
        options.dsn = environment.sentryDsn;
        options.environment = environment.flavor.name;
        options.tracesSampleRate = environment.isProd ? 0.15 : 1.0;
      },
      appRunner: () {
        runApp(
          ProviderScope(
            overrides: <Override>[
              appEnvironmentProvider.overrideWithValue(environment),
            ],
            child: const MenuApp(),
          ),
        );
      },
    );
  }, (Object error, StackTrace stackTrace) {
    logger.e(
      "Unhandled zone error",
      error: error,
      stackTrace: stackTrace,
    );
    Sentry.captureException(error, stackTrace: stackTrace);
  });
}

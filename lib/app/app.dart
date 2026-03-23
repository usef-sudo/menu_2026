import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/app/router/app_router.dart";
import "package:menu_2026/core/settings/app_settings_controller.dart";
import "package:menu_2026/core/theme/app_theme.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class MenuApp extends ConsumerWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settingsAsync = ref.watch(appSettingsControllerProvider);

    return settingsAsync.when(
      data: (AppSettings settings) {
        return MaterialApp.router(
          title: "Menu 2026",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        ),
      ),
      error: (_, __) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext ctx) => Scaffold(
            body: Center(
              child: Text(
                AppLocalizations.of(ctx).settingsLoadError,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/settings/app_settings_controller.dart";
import "package:menu_2026/features/auth/presentation/pages/login_page.dart";
import "package:menu_2026/features/onboarding/presentation/pages/select_language_page.dart";
import "package:menu_2026/features/shell/presentation/pages/home_shell_page.dart";

class AppEntryPage extends ConsumerWidget {
  const AppEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsControllerProvider);
    final sessionAsync = ref.watch(sessionControllerProvider);

    if (settingsAsync.isLoading || sessionAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final settings = settingsAsync.valueOrNull;
    final session = sessionAsync.valueOrNull;

    if (settings == null || session == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.unableToStartApp)),
      );
    }

    if (!settings.hasSelectedLanguage) {
      return SelectLanguagePage(
        onDone: () {
          // Trigger rebuild after saving locale.
          ref.invalidate(appSettingsControllerProvider);
        },
      );
    }

    if (!session.isAuthenticated) {
      return const LoginPage();
    }

    return const HomeShellPage();
  }
}


import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.localeCode,
    required this.hasSelectedLanguage,
    required this.hasCompletedOnboarding,
  });

  final ThemeMode themeMode;
  final String localeCode;
  final bool hasSelectedLanguage;
  final bool hasCompletedOnboarding;

  Locale get locale => Locale(localeCode);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool? hasSelectedLanguage,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class AppSettingsController extends AutoDisposeAsyncNotifier<AppSettings> {
  static const String _themeKey = "app_theme_mode";
  static const String _localeKey = "app_locale_code";
  static const String _hasSelectedLanguageKey = "app_has_selected_language";
  static const String _hasCompletedOnboardingKey = "app_has_completed_onboarding";
  static const String _onboardingLegacyMigratedKey =
      "app_onboarding_legacy_migrated_v1";

  @override
  Future<AppSettings> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await _migrateOnboardingForLegacyUsers(prefs);

    final String themeString = prefs.getString(_themeKey) ?? "system";
    final String localeCode = prefs.getString(_localeKey) ?? "en";
    final bool hasSelectedLanguage =
        prefs.getBool(_hasSelectedLanguageKey) ?? false;
    final bool hasCompletedOnboarding =
        prefs.getBool(_hasCompletedOnboardingKey) ?? false;

    final ThemeMode themeMode;
    switch (themeString) {
      case "light":
        themeMode = ThemeMode.light;
        break;
      case "dark":
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return AppSettings(
      themeMode: themeMode,
      localeCode: localeCode,
      hasSelectedLanguage: hasSelectedLanguage,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  /// Users who already had a locale before onboarding existed should not see the carousel.
  Future<void> _migrateOnboardingForLegacyUsers(SharedPreferences prefs) async {
    if (prefs.getBool(_onboardingLegacyMigratedKey) ?? false) {
      return;
    }
    if (!prefs.containsKey(_hasCompletedOnboardingKey)) {
      final bool hadLanguage = prefs.getBool(_hasSelectedLanguageKey) ?? false;
      if (hadLanguage) {
        await prefs.setBool(_hasCompletedOnboardingKey, true);
      }
    }
    await prefs.setBool(_onboardingLegacyMigratedKey, true);
  }

  Future<void> toggleDarkMode() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final ThemeMode next =
        current.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      next == ThemeMode.dark ? "dark" : "light",
    );
    state = AsyncData(current.copyWith(themeMode: next));
  }

  Future<void> setOnboardingCompleted() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
    state = AsyncData(current.copyWith(hasCompletedOnboarding: true));
  }

  Future<void> setLocale(String code) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
    await prefs.setBool(_hasSelectedLanguageKey, true);
    state = AsyncData(
      current.copyWith(
        localeCode: code,
        hasSelectedLanguage: true,
      ),
    );
  }
}

final appSettingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<AppSettingsController, AppSettings>(
  AppSettingsController.new,
);


import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.localeCode,
    required this.hasSelectedLanguage,
  });

  final ThemeMode themeMode;
  final String localeCode;
  final bool hasSelectedLanguage;

  Locale get locale => Locale(localeCode);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool? hasSelectedLanguage,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
    );
  }
}

class AppSettingsController extends AutoDisposeAsyncNotifier<AppSettings> {
  static const String _themeKey = "app_theme_mode";
  static const String _localeKey = "app_locale_code";
  static const String _hasSelectedLanguageKey = "app_has_selected_language";

  @override
  Future<AppSettings> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String themeString = prefs.getString(_themeKey) ?? "system";
    final String localeCode = prefs.getString(_localeKey) ?? "en";
    final bool hasSelectedLanguage =
        prefs.getBool(_hasSelectedLanguageKey) ?? false;

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
    );
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


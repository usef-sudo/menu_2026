import "package:menu_2026/l10n/app_localizations.dart";

/// Shared validation for admin create/edit flows (aligned with API varchar limits).
abstract final class AdminFormValidators {
  static const int maxName = 255;
  static const int maxAddress = 500;
  static const int maxPhone = 20;
  static const int maxTime = 16;
  static const int maxLogoUrl = 2048;

  static String? name(String? raw, AppLocalizations l10n) {
    final String t = raw?.trim() ?? "";
    if (t.isEmpty) return l10n.adminCategoryValidationNameRequired;
    if (t.length > maxName) return l10n.adminCategoryValidationNameMax;
    return null;
  }

  static String? optionalPhone(String? raw, AppLocalizations l10n) {
    final String t = raw?.trim() ?? "";
    if (t.isEmpty) return null;
    if (t.length > maxPhone) return l10n.adminValidationPhoneMax;
    return null;
  }

  static String? optionalAddress(String? raw, AppLocalizations l10n) {
    final String t = raw?.trim() ?? "";
    if (t.length > maxAddress) return l10n.adminValidationAddressMax;
    return null;
  }

  /// Empty OK; if non-empty must parse as number (lat/lng).
  static String? optionalCoordinate(String? raw, AppLocalizations l10n) {
    final String t = raw?.trim() ?? "";
    if (t.isEmpty) return null;
    if (double.tryParse(t) == null) return l10n.adminValidationNumberInvalid;
    return null;
  }

  static String? costLevelText(String? raw, AppLocalizations l10n) {
    final String t = raw?.trim() ?? "";
    if (t.isEmpty) return null;
    final int? n = int.tryParse(t);
    if (n == null || n < 1 || n > 5) {
      return l10n.adminValidationCostLevelRange;
    }
    return null;
  }

  static String? optionalTime(String? raw, AppLocalizations l10n) {
    final String t = raw?.trim() ?? "";
    if (t.length > maxTime) return l10n.adminValidationTimeMax;
    return null;
  }

  static String? optionalLogoUrl(String? raw, AppLocalizations l10n) {
    final String t = raw?.trim() ?? "";
    if (t.isEmpty) return null;
    if (t.length > maxLogoUrl) return l10n.adminValidationUrlMax;
    return null;
  }
}

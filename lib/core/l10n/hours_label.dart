import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/l10n/app_localizations.dart";

String localizedHoursRange({
  required AppLocalizations l10n,
  required String locale,
  required String open,
  required String close,
}) {
  return l10n.hoursFromTo(
    BranchEntity.formatHm12(open, locale),
    BranchEntity.formatHm12(close, locale),
  );
}

String? localizedTodaysHours({
  required BranchEntity branch,
  required AppLocalizations l10n,
  required String locale,
  DateTime? now,
}) {
  return branch.todaysHoursRangeLabel(
    now,
    (String open, String close) => localizedHoursRange(
      l10n: l10n,
      locale: locale,
      open: open,
      close: close,
    ),
  );
}

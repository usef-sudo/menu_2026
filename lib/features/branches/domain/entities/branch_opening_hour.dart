import "package:equatable/equatable.dart";

/// Local wall-clock interval for one weekday (1 = Monday … 7 = Sunday).
class BranchOpeningHour extends Equatable {
  const BranchOpeningHour({
    required this.id,
    required this.dayOfWeek,
    required this.slotIndex,
    required this.openTime,
    required this.closeTime,
    required this.closesNextDay,
  });

  final String id;
  final int dayOfWeek;
  final int slotIndex;
  final String openTime;
  final String closeTime;
  final bool closesNextDay;

  static int? _hmToMinutes(String t) {
    final RegExpMatch? m =
        RegExp(r"^(\d{1,2}):(\d{2})(?::\d{2})?$").firstMatch(t.trim());
    if (m == null) return null;
    final int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return h * 60 + min;
  }

  static int _effectiveCloseMinutes(String closeTime, bool closesNextDay) {
    if (!closesNextDay && closeTime.trim() == "00:00") {
      return 24 * 60;
    }
    return _hmToMinutes(closeTime) ?? 0;
  }

  /// Whether [when] falls inside this slot (local [when.weekday] and wall time).
  ///
  /// For [closesNextDay], the interval continues after midnight on the next calendar
  /// day (early morning is matched when [when.weekday] is that next day).
  bool containsLocalMoment(DateTime when) {
    final int minuteOfDay = when.hour * 60 + when.minute;
    final int? o = _hmToMinutes(openTime);
    if (o == null) return false;

    if (closesNextDay) {
      final int cRaw = _hmToMinutes(closeTime) ?? 0;
      if (when.weekday == dayOfWeek) {
        return minuteOfDay >= o;
      }
      final int previousWeekday = when.weekday == 1 ? 7 : when.weekday - 1;
      if (previousWeekday == dayOfWeek && minuteOfDay < cRaw) {
        return true;
      }
      return false;
    }

    if (when.weekday != dayOfWeek) return false;
    final int cEff = _effectiveCloseMinutes(closeTime, false);
    return minuteOfDay >= o && minuteOfDay < cEff;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    dayOfWeek,
    slotIndex,
    openTime,
    closeTime,
    closesNextDay,
  ];
}

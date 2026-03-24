import "package:equatable/equatable.dart";
import "package:intl/intl.dart";
import "package:menu_2026/features/branches/domain/entities/branch_opening_hour.dart";

class BranchEntity extends Equatable {
  const BranchEntity({
    required this.id,
    required this.restaurantId,
    required this.nameEn,
    required this.nameAr,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isOpen,
    required this.upVotes,
    required this.downVotes,
    this.distanceKm,
    this.openTime,
    this.closeTime,
    this.facilities = const <String>[],
    this.openingHours = const <BranchOpeningHour>[],
  });

  final String id;
  final String restaurantId;
  final String nameEn;
  final String nameAr;
  final String address;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final int upVotes;
  final int downVotes;
  final double? distanceKm;
  final String? openTime;
  final String? closeTime;
  final List<String> facilities;
  final List<BranchOpeningHour> openingHours;

  static final RegExp _hm =
      RegExp(r"^([01]?\d|2[0-3]):([0-5]\d)(?::[0-5]\d)?$");

  static String formatHm12(String value) {
    final RegExpMatch? m = _hm.firstMatch(value.trim());
    if (m == null) return value;
    final int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    final DateTime dt = DateTime(2000, 1, 1, h, min);
    return DateFormat("h:mm a").format(dt);
  }

  /// Whether [when] falls inside any weekly interval (ignores admin [isOpen]).
  bool matchesWeeklyScheduleAt(DateTime when) {
    if (openingHours.isEmpty) return false;
    for (final BranchOpeningHour h in openingHours) {
      if (h.containsLocalMoment(when)) return true;
    }
    return false;
  }

  static int? _wallClockToMinutes(String? value) {
    if (value == null) return null;
    final RegExpMatch? m =
        RegExp(r"^(\d{1,2}):(\d{2})(?::\d{2})?$").firstMatch(value.trim());
    if (m == null) return null;
    final int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return h * 60 + min;
  }

  /// Same simple hours every day (legacy [openTime] / [closeTime] on the branch row).
  bool _legacyDailyOpenAt(DateTime when) {
    final int? o = _wallClockToMinutes(openTime);
    final int? c = _wallClockToMinutes(closeTime);
    if (o == null || c == null) {
      return true;
    }
    if (o == 0 && c == 0) {
      return false;
    }
    final int mod = when.hour * 60 + when.minute;
    int cEff = c;
    if (c == 0 && o > 0) {
      cEff = 24 * 60;
    }
    if (cEff > o) {
      return mod >= o && mod < cEff;
    }
    return mod >= o || mod < c;
  }

  /// Admin closed ([isOpen] false) always false. Weekly hours win when present;
  /// otherwise legacy daily [openTime]/[closeTime]; if those are missing, [isOpen] only.
  bool isEffectivelyOpenNow([DateTime? now]) {
    final DateTime when = now ?? DateTime.now();
    if (!isOpen) return false;
    if (openingHours.isNotEmpty) {
      return matchesWeeklyScheduleAt(when);
    }
    return _legacyDailyOpenAt(when);
  }

  /// Today's first slot range like `11:00–23:00`, `""` if closed today, `null` if unknown.
  String? todaysHoursRangeLabel([DateTime? now]) {
    final DateTime when = now ?? DateTime.now();
    final int wd = when.weekday;
    if (openingHours.isEmpty) {
      if (openTime != null &&
          closeTime != null &&
          openTime!.isNotEmpty &&
          closeTime!.isNotEmpty) {
        return "${formatHm12(openTime!)}–${formatHm12(closeTime!)}";
      }
      return null;
    }
    final List<BranchOpeningHour> today = openingHours
        .where((BranchOpeningHour h) => h.dayOfWeek == wd)
        .toList(growable: false)
      ..sort(
        (BranchOpeningHour a, BranchOpeningHour b) =>
            a.slotIndex.compareTo(b.slotIndex),
      );
    if (today.isEmpty) return "";
    return today
        .map(
          (BranchOpeningHour s) =>
              "${formatHm12(s.openTime)}–${formatHm12(s.closeTime)}${s.closesNextDay ? "" : ""}",
        )
        .join(", ");
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    restaurantId,
    nameEn,
    nameAr,
    address,
    latitude,
    longitude,
    isOpen,
    upVotes,
    downVotes,
    distanceKm,
    openTime,
    closeTime,
    facilities,
    openingHours,
  ];
}

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

  static final RegExp _hm = RegExp(r"^([01]?\d|2[0-3]):([0-5]\d)$");

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

  /// Admin closed ([isOpen] false) always false. With weekly hours, requires a matching
  /// interval; with no hours, only [isOpen] matters (legacy branches).
  bool isEffectivelyOpenNow([DateTime? now]) {
    final DateTime when = now ?? DateTime.now();
    if (!isOpen) return false;
    if (openingHours.isEmpty) return true;
    return matchesWeeklyScheduleAt(when);
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

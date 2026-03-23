import "package:equatable/equatable.dart";

/// One opening interval. [dayOfWeek] is 1 = Monday … 7 = Sunday (DateTime.weekday).
class BranchOpeningHourDto extends Equatable {
  const BranchOpeningHourDto({
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

  factory BranchOpeningHourDto.fromJson(Map<String, dynamic> json) {
    final dynamic cnd = json["closesNextDay"] ?? json["closes_next_day"];
    return BranchOpeningHourDto(
      id: (json["id"] ?? "").toString(),
      dayOfWeek: int.tryParse(
            (json["dayOfWeek"] ?? json["day_of_week"] ?? 0).toString(),
          ) ??
          0,
      slotIndex: int.tryParse(
            (json["slotIndex"] ?? json["slot_index"] ?? 0).toString(),
          ) ??
          0,
      openTime: (json["openTime"] ?? json["open_time"] ?? "").toString(),
      closeTime: (json["closeTime"] ?? json["close_time"] ?? "").toString(),
      closesNextDay: cnd == true || cnd == 1 || cnd.toString() == "1",
    );
  }

  Map<String, dynamic> toJsonBody() {
    return <String, dynamic>{
      "dayOfWeek": dayOfWeek,
      "slotIndex": slotIndex,
      "openTime": openTime,
      "closeTime": closeTime,
      "closesNextDay": closesNextDay,
    };
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

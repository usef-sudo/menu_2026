import "package:menu_2026/features/branches/data/models/branch_opening_hour_dto.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/domain/entities/branch_opening_hour.dart";

class BranchDto {
  const BranchDto({
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
    this.areaId,
    this.costLevel,
    this.openingHours = const <BranchOpeningHourDto>[],
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
  final String? areaId;
  final int? costLevel;
  final List<BranchOpeningHourDto> openingHours;

  static List<BranchOpeningHourDto> _parseOpeningHours(dynamic raw) {
    if (raw is! List<dynamic>) return const <BranchOpeningHourDto>[];
    final List<BranchOpeningHourDto> out = <BranchOpeningHourDto>[];
    for (final dynamic item in raw) {
      if (item is Map) {
        out.add(
          BranchOpeningHourDto.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }
    return out;
  }

  factory BranchDto.fromJson(Map<String, dynamic> json) {
    final dynamic isOpenRaw = json["isOpen"] ?? json["is_open"];
    return BranchDto(
      id: (json["id"] ?? "").toString(),
      restaurantId: (json["restaurantId"] ?? json["restaurant_id"] ?? "")
          .toString(),
      nameEn: (json["nameEn"] ?? json["name_en"] ?? json["branchEN"] ?? "")
          .toString(),
      nameAr: (json["nameAr"] ?? json["name_ar"] ?? json["branchAR"] ?? "")
          .toString(),
      address: (json["address"] ?? "").toString(),
      latitude:
          double.tryParse((json["latitude"] ?? json["lat"] ?? 0).toString()) ??
          0,
      longitude:
          double.tryParse((json["longitude"] ?? json["lng"] ?? 0).toString()) ??
          0,
      isOpen: isOpenRaw is bool ? isOpenRaw : isOpenRaw.toString() == "1",
      upVotes:
          int.tryParse((json["upVotes"] ?? json["up_votes"] ?? 0).toString()) ??
          0,
      downVotes:
          int.tryParse(
            (json["downVotes"] ?? json["down_votes"] ?? 0).toString(),
          ) ??
          0,
      distanceKm:
          double.tryParse((json["distanceKm"] ?? 0).toString()) ?? 0,
      openTime: (json["openTime"] ?? json["open_time"] ?? "").toString(),
      closeTime: (json["closeTime"] ?? json["close_time"] ?? "").toString(),
      facilities: ((json["facilities"] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(growable: false),
      areaId: (json["areaId"] ?? json["area_id"])?.toString(),
      costLevel: int.tryParse(
        (json["costLevel"] ?? json["cost_level"] ?? "").toString(),
      ),
      openingHours: _parseOpeningHours(
        json["openingHours"] ?? json["opening_hours"],
      ),
    );
  }

  BranchEntity toEntity() {
    return BranchEntity(
      id: id,
      restaurantId: restaurantId,
      nameEn: nameEn,
      nameAr: nameAr,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isOpen: isOpen,
      upVotes: upVotes,
      downVotes: downVotes,
      distanceKm: distanceKm,
      openTime: openTime?.isEmpty == true ? null : openTime,
      closeTime: closeTime?.isEmpty == true ? null : closeTime,
      facilities: facilities,
      openingHours: openingHours
          .map(
            (BranchOpeningHourDto e) => BranchOpeningHour(
              id: e.id,
              dayOfWeek: e.dayOfWeek,
              slotIndex: e.slotIndex,
              openTime: e.openTime,
              closeTime: e.closeTime,
              closesNextDay: e.closesNextDay,
            ),
          )
          .toList(growable: false),
    );
  }
}

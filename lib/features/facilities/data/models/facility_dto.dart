import "package:menu_2026/features/facilities/domain/entities/facility_entity.dart";

class FacilityDto {
  const FacilityDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.icon,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? icon;

  factory FacilityDto.fromJson(Map<String, dynamic> json) {
    return FacilityDto(
      id: (json["id"] ?? "").toString(),
      nameEn: (json["nameEn"] ?? json["name_en"] ?? "").toString(),
      nameAr: (json["nameAr"] ?? json["name_ar"] ?? "").toString(),
      icon: (json["icon"] ?? "").toString().isEmpty
          ? null
          : (json["icon"] ?? "").toString(),
    );
  }

  FacilityEntity toEntity() {
    return FacilityEntity(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      icon: icon,
    );
  }
}


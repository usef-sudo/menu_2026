import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";

class RestaurantDto {
  const RestaurantDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.logoUrl,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.phone,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String logoUrl;
  final String descriptionEn;
  final String descriptionAr;
  final String phone;

  factory RestaurantDto.fromJson(Map<String, dynamic> json) {
    return RestaurantDto(
      id: (json["id"] ?? "").toString(),
      nameEn: (json["nameEn"] ?? json["name_en"] ?? json["nameEN"] ?? "")
          .toString(),
      nameAr: (json["nameAr"] ?? json["name_ar"] ?? json["nameAR"] ?? "")
          .toString(),
      logoUrl: (json["logoUrl"] ?? json["logo_url"] ?? json["logo"] ?? "")
          .toString(),
      descriptionEn: (json["descriptionEn"] ?? json["description_en"] ?? "")
          .toString(),
      descriptionAr: (json["descriptionAr"] ?? json["description_ar"] ?? "")
          .toString(),
      phone: (json["phone"] ?? "").toString(),
    );
  }

  RestaurantEntity toEntity() {
    return RestaurantEntity(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      logoUrl: logoUrl,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      phone: phone,
    );
  }
}

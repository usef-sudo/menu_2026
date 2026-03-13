import "package:menu_2026/features/categories/domain/entities/category_entity.dart";

class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.isActive,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final bool isActive;

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    final dynamic active = json["isActive"] ?? json["is_active"];
    return CategoryDto(
      id: (json["id"] ?? "").toString(),
      nameEn: (json["nameEn"] ?? json["name_en"] ?? "").toString(),
      nameAr: (json["nameAr"] ?? json["name_ar"] ?? "").toString(),
      imageUrl: (json["imageUrl"] ?? json["image_url"] ?? json["image"] ?? "")
          .toString(),
      isActive: active == null
          ? true
          : (active is bool ? active : active.toString() == "1"),
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      imageUrl: imageUrl,
      isActive: isActive,
    );
  }
}

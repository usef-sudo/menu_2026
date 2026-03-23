import "package:menu_2026/features/categories/domain/entities/category_entity.dart";

class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.isActive,
    this.descriptionEn,
    this.descriptionAr,
    this.displayOrder = 0,
    this.icon,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final bool isActive;
  final String? descriptionEn;
  final String? descriptionAr;
  final int displayOrder;
  final String? icon;

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    final dynamic active = json["isActive"] ?? json["is_active"];
    final String fallbackName = (json["name"] ?? "").toString();
    final dynamic orderRaw = json["displayOrder"] ?? json["display_order"];
    int displayOrder = 0;
    if (orderRaw is int) {
      displayOrder = orderRaw;
    } else if (orderRaw != null) {
      displayOrder = int.tryParse(orderRaw.toString()) ?? 0;
    }
    return CategoryDto(
      id: (json["id"] ?? "").toString(),
      nameEn: (json["nameEn"] ?? json["name_en"] ?? fallbackName).toString(),
      nameAr: (json["nameAr"] ?? json["name_ar"] ?? fallbackName).toString(),
      imageUrl: (json["imageUrl"] ?? json["image_url"] ?? json["image"] ?? "")
          .toString(),
      isActive: active == null
          ? true
          : (active is bool ? active : active.toString() == "1"),
      descriptionEn: _optionalString(json["descriptionEn"] ?? json["description_en"]),
      descriptionAr: _optionalString(json["descriptionAr"] ?? json["description_ar"]),
      displayOrder: displayOrder,
      icon: _optionalString(json["icon"]),
    );
  }

  static String? _optionalString(dynamic v) {
    if (v == null) return null;
    final String s = v.toString();
    return s.isEmpty ? null : s;
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

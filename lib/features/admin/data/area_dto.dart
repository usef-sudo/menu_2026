class AreaDto {
  const AreaDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  factory AreaDto.fromJson(Map<String, dynamic> json) {
    return AreaDto(
      id: (json["id"] ?? "").toString(),
      nameEn: (json["nameEn"] ?? json["name_en"] ?? "").toString(),
      nameAr: (json["nameAr"] ?? json["name_ar"] ?? "").toString(),
    );
  }
}

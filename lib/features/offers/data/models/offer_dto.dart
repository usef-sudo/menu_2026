import "package:menu_2026/features/offers/domain/entities/offer_entity.dart";

class OfferDto {
  const OfferDto({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final String imageUrl;
  final String? startDate;
  final String? endDate;

  factory OfferDto.fromJson(Map<String, dynamic> json) {
    return OfferDto(
      id: (json["id"] ?? "").toString(),
      restaurantId: (json["restaurantId"] ?? json["restaurant_id"] ?? "")
          .toString(),
      title: (json["title"] ?? json["nameEn"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      imageUrl: (json["imageUrl"] ?? json["image_url"] ?? json["image"] ?? "")
          .toString(),
      startDate: (json["startDate"] ?? json["start_date"])?.toString(),
      endDate: (json["endDate"] ?? json["end_date"])?.toString(),
    );
  }

  OfferEntity toEntity() {
    return OfferEntity(
      id: id,
      restaurantId: restaurantId,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );
  }
}

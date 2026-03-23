class RestaurantPhotoEntity {
  const RestaurantPhotoEntity({
    required this.id,
    required this.restaurantId,
    required this.imageUrl,
    required this.caption,
    required this.displayOrder,
    required this.isActive,
  });

  final String id;
  final String restaurantId;
  final String imageUrl;
  final String? caption;
  final int displayOrder;
  final bool isActive;

  factory RestaurantPhotoEntity.fromJson(Map<String, dynamic> json) {
    final dynamic active = json["isActive"] ?? json["is_active"];
    return RestaurantPhotoEntity(
      id: (json["id"] ?? "").toString(),
      restaurantId:
          (json["restaurantId"] ?? json["restaurant_id"] ?? "").toString(),
      imageUrl: (json["imageUrl"] ?? json["image_url"] ?? "").toString(),
      caption: (json["caption"])?.toString(),
      displayOrder: int.tryParse(
            (json["displayOrder"] ?? json["display_order"] ?? 0).toString(),
          ) ??
          0,
      isActive: active == null
          ? true
          : (active is bool ? active : active.toString() == "1"),
    );
  }
}


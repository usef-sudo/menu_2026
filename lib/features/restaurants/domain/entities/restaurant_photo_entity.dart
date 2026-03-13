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
    return RestaurantPhotoEntity(
      id: json["id"].toString(),
      restaurantId: json["restaurantId"].toString(),
      imageUrl: json["imageUrl"]?.toString() ?? "",
      caption: json["caption"]?.toString(),
      displayOrder: int.tryParse(json["displayOrder"]?.toString() ?? "0") ?? 0,
      isActive: (json["isActive"]?.toString() ?? "1") == "1",
    );
  }
}


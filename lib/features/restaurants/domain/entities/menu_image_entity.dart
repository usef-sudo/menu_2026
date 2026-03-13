class MenuImageEntity {
  const MenuImageEntity({
    required this.id,
    required this.branchId,
    required this.imageUrl,
    required this.displayOrder,
    required this.isActive,
  });

  final String id;
  final String branchId;
  final String imageUrl;
  final int displayOrder;
  final bool isActive;

  factory MenuImageEntity.fromJson(Map<String, dynamic> json) {
    return MenuImageEntity(
      id: json["id"].toString(),
      branchId: json["branchId"].toString(),
      imageUrl: json["imageUrl"]?.toString() ?? "",
      displayOrder: int.tryParse(json["displayOrder"]?.toString() ?? "0") ?? 0,
      isActive: (json["isActive"]?.toString() ?? "1") == "1",
    );
  }
}


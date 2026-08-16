import "package:equatable/equatable.dart";

class RestaurantEntity extends Equatable {
  const RestaurantEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.logoUrl,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.phone,
    this.websiteUrl = "",
    this.instagramUrl = "",
    this.facebookUrl = "",
    this.talabatUrl = "",
    this.careemUrl = "",
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String logoUrl;
  final String descriptionEn;
  final String descriptionAr;
  final String phone;
  final String websiteUrl;
  final String instagramUrl;
  final String facebookUrl;
  final String talabatUrl;
  final String careemUrl;

  @override
  List<Object?> get props => <Object?>[
    id,
    nameEn,
    nameAr,
    logoUrl,
    descriptionEn,
    descriptionAr,
    phone,
    websiteUrl,
    instagramUrl,
    facebookUrl,
    talabatUrl,
    careemUrl,
  ];
}

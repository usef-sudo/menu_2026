import "package:equatable/equatable.dart";

class CategoryEntity extends Equatable {
  const CategoryEntity({
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

  @override
  List<Object?> get props => <Object?>[id, nameEn, nameAr, imageUrl, isActive];
}

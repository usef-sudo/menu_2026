import "package:equatable/equatable.dart";

class FacilityEntity extends Equatable {
  const FacilityEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.icon,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? icon;

  @override
  List<Object?> get props => <Object?>[id, nameEn, nameAr, icon];
}


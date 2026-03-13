import "package:equatable/equatable.dart";

class BranchEntity extends Equatable {
  const BranchEntity({
    required this.id,
    required this.restaurantId,
    required this.nameEn,
    required this.nameAr,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isOpen,
    required this.upVotes,
    required this.downVotes,
    this.distanceKm,
    this.openTime,
    this.closeTime,
    this.facilities = const <String>[],
  });

  final String id;
  final String restaurantId;
  final String nameEn;
  final String nameAr;
  final String address;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final int upVotes;
  final int downVotes;
  final double? distanceKm;
  final String? openTime;
  final String? closeTime;
  final List<String> facilities;

  @override
  List<Object?> get props => <Object?>[
    id,
    restaurantId,
    nameEn,
    nameAr,
    address,
    latitude,
    longitude,
    isOpen,
    upVotes,
    downVotes,
    distanceKm,
    openTime,
    closeTime,
    facilities,
  ];
}

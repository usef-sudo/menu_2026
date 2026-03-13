import "package:equatable/equatable.dart";

class OfferEntity extends Equatable {
  const OfferEntity({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final String imageUrl;

  @override
  List<Object?> get props => <Object?>[
    id,
    restaurantId,
    title,
    description,
    imageUrl,
  ];
}

import "package:equatable/equatable.dart";

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.branchId = "",
  });

  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String branchId;

  @override
  List<Object?> get props =>
      <Object?>[id, userId, userName, rating, comment, createdAt, branchId];
}

class ReviewSummary extends Equatable {
  const ReviewSummary({
    required this.avgRating,
    required this.total,
  });

  final double avgRating;
  final int total;

  @override
  List<Object?> get props => <Object?>[avgRating, total];
}

class ReviewsState {
  const ReviewsState({
    required this.reviews,
    required this.summary,
  });

  final List<ReviewEntity> reviews;
  final ReviewSummary summary;
}

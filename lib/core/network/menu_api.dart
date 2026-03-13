import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/api_envelope.dart";
import "package:menu_2026/core/network/dio_client.dart";
import "package:menu_2026/features/auth/data/models/login_response_dto.dart";
import "package:menu_2026/features/branches/data/models/branch_dto.dart";
import "package:menu_2026/features/categories/data/models/category_dto.dart";
import "package:menu_2026/features/offers/data/models/offer_dto.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";
import "package:menu_2026/features/reviews/domain/entities/review_entity.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";

class MenuApi {
  MenuApi(this._dio);
  final Dio _dio;

  Future<List<CategoryDto>> getCategories() async {
    final response = await _dio.get<dynamic>("/categories");
    final envelope = ApiEnvelope.fromDynamic<List<CategoryDto>>(response.data, (
      dynamic data,
    ) {
      final list = data as List<dynamic>;
      return list
          .map(
            (dynamic item) =>
                CategoryDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    });
    return envelope.data;
  }

  Future<List<RestaurantDto>> getRestaurants({
    String? categoryId,
    String? search,
  }) async {
    final response = await _dio.get<dynamic>(
      "/restaurants",
      queryParameters: <String, dynamic>{
        if (categoryId != null && categoryId.isNotEmpty)
          "categoryId": categoryId,
        if (search != null && search.isNotEmpty) "search": search,
      },
    );
    final envelope = ApiEnvelope.fromDynamic<List<RestaurantDto>>(
      response.data,
      (dynamic data) {
        final list = data as List<dynamic>;
        return list
            .map(
              (dynamic item) =>
                  RestaurantDto.fromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false);
      },
    );
    return envelope.data;
  }

  Future<List<BranchDto>> getBranches({
    String? restaurantId,
    String? areaId,
  }) async {
    final response = await _dio.get<dynamic>(
      "/branches",
      queryParameters: <String, dynamic>{
        if (restaurantId != null && restaurantId.isNotEmpty)
          "restaurantId": restaurantId,
        if (areaId != null && areaId.isNotEmpty) "areaId": areaId,
      },
    );
    final envelope = ApiEnvelope.fromDynamic<List<BranchDto>>(response.data, (
      dynamic data,
    ) {
      final list = data as List<dynamic>;
      return list
          .map(
            (dynamic item) => BranchDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    });
    return envelope.data;
  }

  Future<List<OfferDto>> getOffers() async {
    final response = await _dio.get<dynamic>("/offers");
    final envelope = ApiEnvelope.fromDynamic<List<OfferDto>>(response.data, (
      dynamic data,
    ) {
      final list = data as List<dynamic>;
      return list
          .map(
            (dynamic item) => OfferDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    });
    return envelope.data;
  }

  Future<Map<String, int>> getBranchVotes(String branchId) async {
    final response = await _dio.get<dynamic>("/votes/branches/$branchId/votes");
    final payload = response.data as Map<String, dynamic>;
    return <String, int>{
      "upVotes": int.tryParse((payload["upVotes"] ?? 0).toString()) ?? 0,
      "downVotes": int.tryParse((payload["downVotes"] ?? 0).toString()) ?? 0,
    };
  }

  Future<void> voteForBranch(String branchId, int vote) async {
    await _dio.post<dynamic>(
      "/votes/branches/$branchId/vote",
      data: <String, dynamic>{"vote": vote},
    );
  }

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      "/users/login",
      data: <String, dynamic>{"email": email, "password": password},
    );
    return LoginResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _dio.post<dynamic>(
      "/users",
      data: <String, dynamic>{
        "name": name,
        "email": email,
        "password": password,
      },
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _dio.post<dynamic>(
      "/users/forgot-password",
      data: <String, dynamic>{"email": email},
    );
  }

  Future<Set<String>> getFavoriteRestaurantIds() async {
    final Response<dynamic> response = await _dio.get<dynamic>("/favorites");
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (dynamic item) => (item as Map<String, dynamic>)["restaurantId"]
              ?.toString(),
        )
        .whereType<String>()
        .toSet();
  }

  Future<void> addFavorite(String restaurantId) async {
    await _dio.post<dynamic>("/favorites/$restaurantId");
  }

  Future<void> removeFavorite(String restaurantId) async {
    await _dio.delete<dynamic>("/favorites/$restaurantId");
  }

  Future<ReviewsState> getBranchReviews(String branchId) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/reviews/branches/$branchId/reviews");
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final List<dynamic> list = data["reviews"] as List<dynamic>? ?? <dynamic>[];
    final Map<String, dynamic> summary =
        data["summary"] as Map<String, dynamic>? ?? <String, dynamic>{};

    final List<ReviewEntity> reviews = list
        .map(
          (dynamic item) {
            final Map<String, dynamic> map =
                item as Map<String, dynamic>;
            return ReviewEntity(
              id: map["id"].toString(),
              userName: (map["userName"] as String?) ?? "User",
              rating: int.tryParse(map["rating"].toString()) ?? 0,
              comment: (map["comment"] as String?) ?? "",
              createdAt: DateTime.tryParse(
                    map["createdAt"]?.toString() ?? "",
                  ) ??
                  DateTime.now(),
            );
          },
        )
        .toList(growable: false);

    final ReviewSummary summaryEntity = ReviewSummary(
      avgRating:
          double.tryParse(summary["avgRating"]?.toString() ?? "0") ?? 0,
      total: int.tryParse(summary["total"]?.toString() ?? "0") ?? 0,
    );

    return ReviewsState(reviews: reviews, summary: summaryEntity);
  }

  Future<void> submitReview({
    required String branchId,
    required int rating,
    String? comment,
  }) async {
    await _dio.post<dynamic>(
      "/reviews/branches/$branchId/reviews",
      data: <String, dynamic>{
        "rating": rating,
        if (comment != null && comment.isNotEmpty) "comment": comment,
      },
    );
  }

  Future<List<MenuImageEntity>> getBranchMenuImages(String branchId) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/branches/$branchId/menu-images");
    final ApiEnvelope<List<MenuImageEntity>> envelope =
        ApiEnvelope.fromDynamic<List<MenuImageEntity>>(
      response.data,
      (dynamic data) {
        final List<dynamic> list = data as List<dynamic>;
        return list
            .map(
              (dynamic item) => MenuImageEntity.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false);
      },
    );
    return envelope.data;
  }

  Future<List<RestaurantPhotoEntity>> getRestaurantPhotos(
    String restaurantId,
  ) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>("/restaurants/$restaurantId/photos");
    final ApiEnvelope<List<RestaurantPhotoEntity>> envelope =
        ApiEnvelope.fromDynamic<List<RestaurantPhotoEntity>>(
      response.data,
      (dynamic data) {
        final List<dynamic> list = data as List<dynamic>;
        return list
            .map(
              (dynamic item) => RestaurantPhotoEntity.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false);
      },
    );
    return envelope.data;
  }
}

final menuApiProvider = Provider<MenuApi>((Ref ref) {
  return MenuApi(ref.watch(dioProvider));
});

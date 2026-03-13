import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";

class RestaurantFacility {
  const RestaurantFacility({required this.id, required this.nameEn, this.icon});

  final String id;
  final String nameEn;
  final String? icon;
}

class RestaurantDetailsState {
  const RestaurantDetailsState({
    required this.id,
    required this.nameEn,
    required this.descriptionEn,
    required this.categoryName,
    required this.branchesCount,
    required this.totalVotes,
    required this.avgRating,
    required this.reviewsCount,
    required this.facilities,
  });

  final String id;
  final String nameEn;
  final String descriptionEn;
  final String? categoryName;
  final int branchesCount;
  final int totalVotes;
  final double avgRating;
  final int reviewsCount;
  final List<RestaurantFacility> facilities;
}

class RestaurantDetailsController
    extends AutoDisposeFamilyAsyncNotifier<RestaurantDetailsState, String> {
  @override
  Future<RestaurantDetailsState> build(String restaurantId) async {
    final result = await safeRequest<RestaurantDetailsState>(() async {
      final data =
          await ref.read(menuApiProvider).getRestaurantDetails(restaurantId);

      final Map<String, dynamic> category =
          (data["category"] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final List<dynamic> facilitiesJson =
          (data["facilities"] as List<dynamic>?) ?? <dynamic>[];

      final facilities = facilitiesJson
          .map(
            (dynamic item) => RestaurantFacility(
              id: (item as Map<String, dynamic>)["id"].toString(),
              nameEn: (item["nameEn"] ?? "").toString(),
              icon: (item["icon"] ?? "").toString().isEmpty
                  ? null
                  : (item["icon"] ?? "").toString(),
            ),
          )
          .toList(growable: false);

      return RestaurantDetailsState(
        id: (data["id"] ?? restaurantId).toString(),
        nameEn: (data["nameEn"] ?? "").toString(),
        descriptionEn: (data["descriptionEn"] ?? "").toString(),
        categoryName:
            category.isEmpty ? null : (category["nameEn"] ?? "").toString(),
        branchesCount: int.tryParse(
              data["branchesCount"]?.toString() ?? "0",
            ) ??
            0,
        totalVotes: int.tryParse(
              data["totalVotes"]?.toString() ?? "0",
            ) ??
            0,
        facilities: facilities,
        avgRating: double.tryParse(
              data["avgRating"]?.toString() ?? "0",
            ) ??
            0,
        reviewsCount: int.tryParse(
              data["reviewsCount"]?.toString() ?? "0",
            ) ??
            0,
      );
    });

    return result.when(
      success: (RestaurantDetailsState data) => data,
      failure: (failure) => throw failure,
    );
  }
}

final restaurantDetailsControllerProvider = AutoDisposeAsyncNotifierProviderFamily<
    RestaurantDetailsController,
    RestaurantDetailsState,
    String>(RestaurantDetailsController.new);


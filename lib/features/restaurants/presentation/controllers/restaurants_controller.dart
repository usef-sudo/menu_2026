import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";

class RestaurantsFilter {
  const RestaurantsFilter({
    this.categoryId,
    this.search,
    this.minCostLevel,
    this.maxCostLevel,
    this.openOnly,
    this.sort,
    this.facilityIds = const <String>[],
  });
  final String? categoryId;
  final String? search;
  final int? minCostLevel;
  final int? maxCostLevel;
  final bool? openOnly;
  final String? sort;
  final List<String> facilityIds;
}

final restaurantsFilterProvider = StateProvider<RestaurantsFilter>(
  (Ref ref) => const RestaurantsFilter(),
);

class RestaurantsController
    extends AutoDisposeAsyncNotifier<List<RestaurantEntity>> {
  @override
  Future<List<RestaurantEntity>> build() async {
    final filter = ref.watch(restaurantsFilterProvider);
    return _load(filter);
  }

  Future<List<RestaurantEntity>> _load(RestaurantsFilter filter) async {
    final result = await safeRequest<List<RestaurantEntity>>(() async {
      final dtos = await ref
          .read(menuApiProvider)
          .getRestaurants(
            categoryId: filter.categoryId,
            search: filter.search,
            minCostLevel: filter.minCostLevel,
            maxCostLevel: filter.maxCostLevel,
            openOnly: filter.openOnly,
            sort: filter.sort,
            facilityIds: filter.facilityIds,
          );
      return dtos.map((dto) => dto.toEntity()).toList(growable: false);
    });
    return result.when(
      success: (List<RestaurantEntity> data) => data,
      failure: (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final filter = ref.read(restaurantsFilterProvider);
    state = await AsyncValue.guard(() => _load(filter));
  }
}

final restaurantsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      RestaurantsController,
      List<RestaurantEntity>
    >(RestaurantsController.new);

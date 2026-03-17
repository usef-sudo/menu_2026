import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";

/// Category IDs selected for spin filter. Empty = all categories/restaurants.
final spinSelectedCategoryIdsProvider =
    StateProvider<List<String>>((Ref ref) => <String>[]);

/// Categories filtered by spin selection. Empty selection = all.
final spinFilteredCategoriesProvider =
    Provider.autoDispose<AsyncValue<List<CategoryEntity>>>((Ref ref) {
  final categoriesAsync = ref.watch(categoriesControllerProvider);
  final selectedIds = ref.watch(spinSelectedCategoryIdsProvider);

    return categoriesAsync.when(
    data: (List<CategoryEntity> list) {
      if (selectedIds.isEmpty) return AsyncValue.data(list);
      final filtered = list
          .where((CategoryEntity c) => selectedIds.contains(c.id))
          .toList(growable: false);
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Restaurants filtered by spin category selection. Fetches per category and merges.
final spinFilteredRestaurantsProvider =
    FutureProvider.autoDispose<List<RestaurantEntity>>((Ref ref) async {
  final selectedIds = ref.watch(spinSelectedCategoryIdsProvider);
  final api = ref.read(menuApiProvider);

  if (selectedIds.isEmpty) {
    final list = await api.getRestaurants();
    return list.map((d) => d.toEntity()).toList(growable: false);
  }

  final Map<String, RestaurantEntity> seen = <String, RestaurantEntity>{};
  for (final String categoryId in selectedIds) {
    final list = await api.getRestaurants(categoryId: categoryId);
    for (final dto in list) {
      final entity = dto.toEntity();
      if (!seen.containsKey(entity.id)) {
        seen[entity.id] = entity;
      }
    }
  }
  return seen.values.toList(growable: false);
});

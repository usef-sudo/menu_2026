import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";

/// Selected category IDs for map filter. Empty = show all branches.
final mapSelectedCategoryIdsProvider =
    StateProvider<List<String>>((Ref ref) => <String>[]);

/// "Open now only" filter.
final mapOpenOnlyProvider = StateProvider<bool>((Ref ref) => false);

/// Restaurant IDs that belong to any of the given categories (from API).
final restaurantIdsForCategoriesProvider =
    FutureProvider.autoDispose.family<Set<String>, List<String>>(
  (Ref ref, List<String> categoryIds) async {
    if (categoryIds.isEmpty) return <String>{};
    final MenuApi api = ref.read(menuApiProvider);
    final Set<String> ids = <String>{};
    for (final String id in categoryIds) {
      final list = await api.getRestaurants(categoryId: id);
      for (final r in list) {
        ids.add(r.id);
      }
    }
    return ids;
  },
);

/// Branches for the map: from API, filtered by selected categories and open-only.
final mapFilteredBranchesProvider =
    Provider.autoDispose<AsyncValue<List<BranchWithDistance>>>((Ref ref) {
  final branchesAsync = ref.watch(branchesControllerProvider);
  final selectedCategoryIds = ref.watch(mapSelectedCategoryIdsProvider);
  final openOnly = ref.watch(mapOpenOnlyProvider);
  final restaurantIdsAsync =
      ref.watch(restaurantIdsForCategoriesProvider(selectedCategoryIds));

  return branchesAsync.when(
    data: (List<BranchWithDistance> branches) {
      List<BranchWithDistance> out = branches;
      if (openOnly) {
        out = out.where((b) => b.branch.isOpen).toList(growable: false);
      }
      if (selectedCategoryIds.isEmpty) return AsyncValue.data(out);
      return restaurantIdsAsync.when(
        data: (Set<String> ids) {
          final filtered = out
              .where((b) => ids.contains(b.branch.restaurantId))
              .toList(growable: false);
          return AsyncValue.data(filtered);
        },
        loading: () => AsyncValue.data(out),
        error: (e, st) => AsyncValue.data(out),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

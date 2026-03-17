import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";

enum SpinKind {
  category,
  restaurant,
}

class SpinResult {
  const SpinResult({
    required this.name,
    required this.kind,
    this.id,
    this.distanceKm,
    this.reason,
  });

  final String name;
  final SpinKind kind;
  final String? id;
  final double? distanceKm;
  final String? reason;
}

final spinControllerProvider =
    AutoDisposeNotifierProvider<SpinController, SpinResult?>(
      SpinController.new,
    );

class SpinController extends AutoDisposeNotifier<SpinResult?> {
  @override
  SpinResult? build() => null;

  void clearResult() {
    state = null;
  }

  Future<void> spinRestaurantAt(List<RestaurantEntity> restaurants, int index) async {
    final branches = await ref.read(branchesControllerProvider.future);

    if (restaurants.isEmpty || branches.isEmpty) {
      state = null;
      return;
    }

    if (index < 0 || index >= restaurants.length) {
      state = null;
      return;
    }

    final selected = restaurants[index];
    final BranchWithDistance? selectedBranch = branches
        .where((BranchWithDistance b) => b.branch.restaurantId == selected.id)
        .fold<BranchWithDistance?>(
          null,
          (BranchWithDistance? current, BranchWithDistance item) =>
              current == null || item.distanceKm < current.distanceKm
                  ? item
                  : current,
        );

    if (selectedBranch == null) {
      state = null;
      return;
    }

    state = SpinResult(
      name: selected.nameEn,
      kind: SpinKind.restaurant,
      id: selected.id,
      distanceKm: selectedBranch.distanceKm,
      reason: selectedBranch.distanceKm <= 3
          ? "Nearby and discovery-friendly"
          : "Randomized to expand your options",
    );
  }

  Future<void> spinCategoryAt(List<CategoryEntity> categories, int index) async {
    if (categories.isEmpty || index < 0 || index >= categories.length) {
      state = null;
      return;
    }
    final selected = categories[index];
    state = SpinResult(
      name: selected.nameEn,
      kind: SpinKind.category,
      id: selected.id,
      reason: "Great category to explore right now",
    );
  }
}


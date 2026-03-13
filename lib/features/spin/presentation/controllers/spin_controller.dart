import "dart:math";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";

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

  Future<void> spinRestaurant() async {
    final restaurants = await ref.read(restaurantsControllerProvider.future);
    final branches = await ref.read(branchesControllerProvider.future);
    final favorites = await ref.read(favoritesControllerProvider.future);

    if (restaurants.isEmpty || branches.isEmpty) {
      state = null;
      return;
    }

    final random = Random();
    final List<int> weighted = <int>[];
    for (var i = 0; i < restaurants.length; i++) {
      final restaurant = restaurants[i];
      final BranchWithDistance? nearestBranch = branches
          .where((BranchWithDistance b) => b.branch.restaurantId == restaurant.id)
          .fold<BranchWithDistance?>(
            null,
            (BranchWithDistance? current, BranchWithDistance item) =>
                current == null || item.distanceKm < current.distanceKm
                    ? item
                    : current,
          );
      if (nearestBranch == null) {
        continue;
      }
      var weight = 1;
      if (favorites.contains(restaurant.id)) {
        weight += 2;
      }
      if (nearestBranch.distanceKm <= 3) {
        weight += 1;
      }
      weighted.addAll(List<int>.filled(weight, i));
    }

    if (weighted.isEmpty) {
      state = null;
      return;
    }

    final int index = weighted[random.nextInt(weighted.length)];
    final selected = restaurants[index];
    final BranchWithDistance selectedBranch = branches.firstWhere(
      (BranchWithDistance b) => b.branch.restaurantId == selected.id,
      orElse: () => branches.first,
    );
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

  Future<void> spinCategory() async {
    final categories = await ref.read(categoriesControllerProvider.future);
    if (categories.isEmpty) {
      state = null;
      return;
    }
    final random = Random();
    final selected = categories[random.nextInt(categories.length)];
    state = SpinResult(
      name: selected.nameEn,
      kind: SpinKind.category,
      id: selected.id,
      reason: "Great category to explore right now",
    );
  }
}


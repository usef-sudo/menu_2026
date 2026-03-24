import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:geolocator/geolocator.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/branches/data/models/branch_dto.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/map_nearby/presentation/controllers/location_controller.dart";

class BranchWithDistance {
  const BranchWithDistance({required this.branch, required this.distanceKm});

  final BranchEntity branch;
  final double distanceKm;
}

/// Maps API DTOs to entities and sorts by distance from [location].
List<BranchWithDistance> branchDtosToWithDistance(
  List<BranchDto> dtos,
  UserLocation location,
) {
  final List<BranchEntity> branches =
      dtos.map((BranchDto dto) => dto.toEntity()).toList(growable: false);
  final List<BranchWithDistance> mapped = branches
      .map((BranchEntity branch) {
        final double distanceMeters = Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          branch.latitude,
          branch.longitude,
        );
        return BranchWithDistance(
          branch: branch,
          distanceKm: double.parse(
            (distanceMeters / 1000).toStringAsFixed(2),
          ),
        );
      })
      .toList(growable: false)
    ..sort(
      (BranchWithDistance a, BranchWithDistance b) =>
          a.distanceKm.compareTo(b.distanceKm),
    );
  return mapped;
}

/// All branches (map, spin, discovery). Never scoped to a single restaurant.
class BranchesController
    extends AutoDisposeAsyncNotifier<List<BranchWithDistance>> {
  @override
  Future<List<BranchWithDistance>> build() async {
    final UserLocation location =
        await ref.watch(locationControllerProvider.future);
    final result = await safeRequest<List<BranchWithDistance>>(() async {
      final List<BranchDto> dtos =
          await ref.read(menuApiProvider).getBranches();
      return branchDtosToWithDistance(dtos, location);
    });
    return result.when(
      success: (List<BranchWithDistance> data) => data,
      failure: (failure) => throw failure,
    );
  }
}

final branchesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      BranchesController,
      List<BranchWithDistance>
    >(BranchesController.new);

/// Branches for one restaurant — avoids global [restaurantId] state and load races
/// (restaurant details used to set id in a microtask after the first build).
class RestaurantBranchesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<BranchWithDistance>, String> {
  @override
  Future<List<BranchWithDistance>> build(String restaurantId) async {
    if (restaurantId.isEmpty) {
      return <BranchWithDistance>[];
    }
    final UserLocation location =
        await ref.watch(locationControllerProvider.future);
    final result = await safeRequest<List<BranchWithDistance>>(() async {
      final List<BranchDto> dtos = await ref.read(menuApiProvider).getBranches(
            restaurantId: restaurantId,
          );
      return branchDtosToWithDistance(dtos, location);
    });
    return result.when(
      success: (List<BranchWithDistance> data) => data,
      failure: (failure) => throw failure,
    );
  }
}

final restaurantBranchesProvider = AsyncNotifierProvider.autoDispose
    .family<RestaurantBranchesNotifier, List<BranchWithDistance>, String>(
  RestaurantBranchesNotifier.new,
);

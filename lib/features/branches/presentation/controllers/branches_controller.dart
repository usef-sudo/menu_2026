import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:geolocator/geolocator.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/map_nearby/presentation/controllers/location_controller.dart";

class BranchWithDistance {
  const BranchWithDistance({required this.branch, required this.distanceKm});

  final BranchEntity branch;
  final double distanceKm;
}

final selectedRestaurantIdProvider = StateProvider<String?>((Ref ref) => null);

class BranchesController
    extends AutoDisposeAsyncNotifier<List<BranchWithDistance>> {
  @override
  Future<List<BranchWithDistance>> build() async {
    final restaurantId = ref.watch(selectedRestaurantIdProvider);
    final location = await ref.watch(locationControllerProvider.future);
    return _load(restaurantId: restaurantId, location: location);
  }

  Future<List<BranchWithDistance>> _load({
    required String? restaurantId,
    required UserLocation location,
  }) async {
    final result = await safeRequest<List<BranchWithDistance>>(() async {
      final dtos = await ref
          .read(menuApiProvider)
          .getBranches(restaurantId: restaurantId);
      final branches = dtos
          .map((dto) => dto.toEntity())
          .toList(growable: false);

      final mapped =
          branches
              .map((BranchEntity branch) {
                final distanceMeters = Geolocator.distanceBetween(
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
            ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      return mapped;
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

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/map_nearby/presentation/controllers/location_controller.dart";

class NearbyBranchWithDistance {
  const NearbyBranchWithDistance({
    required this.branch,
    required this.distanceKm,
  });

  final BranchEntity branch;
  final double distanceKm;
}

class NearbyBranchesController
    extends AutoDisposeAsyncNotifier<List<NearbyBranchWithDistance>> {
  @override
  Future<List<NearbyBranchWithDistance>> build() async {
    final UserLocation location =
        await ref.watch(locationControllerProvider.future);
    return _load(location: location);
  }

  Future<List<NearbyBranchWithDistance>> _load({
    required UserLocation location,
  }) async {
    final result = await safeRequest<List<NearbyBranchWithDistance>>(() async {
      final dtos = await ref.read(menuApiProvider).getNearbyBranches(
            latitude: location.latitude,
            longitude: location.longitude,
          );
      final branches = dtos
          .map((dto) => dto.toEntity())
          .toList(growable: false);

      // Backend already sorts by distance, but we compute again from fields if present.
      final mapped = branches.map((BranchEntity b) {
        final double distanceKm =
            double.tryParse((b.distanceKm ?? 0).toString()) ?? 0;
        return NearbyBranchWithDistance(branch: b, distanceKm: distanceKm);
      }).toList(growable: false);

      mapped.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return mapped;
    });

    return result.when(
      success: (List<NearbyBranchWithDistance> data) => data,
      failure: (failure) => throw failure,
    );
  }
}

final nearbyBranchesControllerProvider =
    AutoDisposeAsyncNotifierProvider<NearbyBranchesController,
        List<NearbyBranchWithDistance>>(NearbyBranchesController.new);


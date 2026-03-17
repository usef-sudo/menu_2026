import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/facilities/domain/entities/facility_entity.dart";

class FacilitiesController extends AutoDisposeAsyncNotifier<List<FacilityEntity>> {
  @override
  Future<List<FacilityEntity>> build() async {
    final result = await safeRequest<List<FacilityEntity>>(() async {
      final dtos = await ref.read(menuApiProvider).getFacilities();
      return dtos.map((dto) => dto.toEntity()).toList(growable: false);
    });
    return result.when(
      success: (List<FacilityEntity> data) => data,
      failure: (failure) => throw failure,
    );
  }
}

final facilitiesControllerProvider =
    AutoDisposeAsyncNotifierProvider<FacilitiesController, List<FacilityEntity>>(
      FacilitiesController.new,
    );


import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";

final menuImagesControllerProvider = FutureProvider.family<
    List<MenuImageEntity>, String>((Ref ref, String branchId) async {
  final MenuApi api = ref.read(menuApiProvider);
  return api.getBranchMenuImages(branchId);
});


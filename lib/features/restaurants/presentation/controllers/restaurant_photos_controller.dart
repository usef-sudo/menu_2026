import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";

final restaurantPhotosControllerProvider =
    FutureProvider.family<List<RestaurantPhotoEntity>, String>(
  (Ref ref, String restaurantId) async {
    final MenuApi api = ref.read(menuApiProvider);
    return api.getRestaurantPhotos(restaurantId);
  },
);


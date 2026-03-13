import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:shared_preferences/shared_preferences.dart";

class FavoritesController extends AutoDisposeAsyncNotifier<Set<String>> {
  static const String _key = "favorite_restaurant_ids";

  @override
  Future<Set<String>> build() async {
    final session = ref.watch(sessionControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> localIds =
        prefs.getStringList(_key)?.toSet() ?? <String>{};

    if (!isLoggedIn) {
      return localIds;
    }

    final Set<String> remoteIds =
        await ref.read(menuApiProvider).getFavoriteRestaurantIds();
    final Set<String> merged = <String>{...remoteIds, ...localIds};
    await prefs.setStringList(_key, merged.toList(growable: false));
    return merged;
  }

  Future<void> toggle(String restaurantId) async {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session == null || !session.isAuthenticated) {
      return;
    }

    final Set<String> current =
        Set<String>.from(state.valueOrNull ?? <String>{});
    final bool willFavorite = !current.contains(restaurantId);

    if (willFavorite) {
      current.add(restaurantId);
      await ref.read(menuApiProvider).addFavorite(restaurantId);
    } else {
      current.remove(restaurantId);
      await ref.read(menuApiProvider).removeFavorite(restaurantId);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, current.toList(growable: false));
    state = AsyncData(current);
  }

  bool isFavorite(String restaurantId) {
    return state.valueOrNull?.contains(restaurantId) ?? false;
  }
}

final favoritesControllerProvider =
    AutoDisposeAsyncNotifierProvider<FavoritesController, Set<String>>(
      FavoritesController.new,
    );

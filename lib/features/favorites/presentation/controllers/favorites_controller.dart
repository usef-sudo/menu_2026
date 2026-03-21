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

    if (!isLoggedIn) {
      // Clear cached favorites when logged out so stale data
      // does not bleed into the next user's session.
      await prefs.remove(_key);
      return <String>{};
    }

    final Set<String> remoteIds =
        await ref.read(menuApiProvider).getFavoriteRestaurantIds();
    await prefs.setStringList(_key, remoteIds.toList(growable: false));
    return remoteIds;
  }

  Future<bool> toggle(String restaurantId) async {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session == null || !session.isAuthenticated) {
      return false;
    }

    final Set<String> previous =
        Set<String>.from(state.valueOrNull ?? <String>{});
    final bool willFavorite = !previous.contains(restaurantId);
    final Set<String> next = Set<String>.from(previous);

    if (willFavorite) {
      next.add(restaurantId);
      try {
        await ref.read(menuApiProvider).addFavorite(restaurantId);
      } catch (_) {
        state = AsyncData(previous);
        return false;
      }
    } else {
      next.remove(restaurantId);
      try {
        await ref.read(menuApiProvider).removeFavorite(restaurantId);
      } catch (_) {
        state = AsyncData(previous);
        return false;
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList(growable: false));
    state = AsyncData(next);
    return true;
  }

  bool isFavorite(String restaurantId) {
    return state.valueOrNull?.contains(restaurantId) ?? false;
  }
}

final favoritesControllerProvider =
    AutoDisposeAsyncNotifierProvider<FavoritesController, Set<String>>(
      FavoritesController.new,
    );

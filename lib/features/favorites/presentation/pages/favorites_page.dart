import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("Favorites")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.favorite_border, size: 40),
              const SizedBox(height: 12),
              const Text("Sign in to view your favorites"),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push("/auth/login"),
                child: const Text("Sign in"),
              ),
            ],
          ),
        ),
      );
    }

    final favoritesAsync = ref.watch(favoritesControllerProvider);
    final restaurantsAsync = ref.watch(restaurantsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: favoritesAsync.when(
        data: (Set<String> favoriteIds) {
          if (favoriteIds.isEmpty) {
            return const _EmptyFavorites();
          }

          return restaurantsAsync.when(
            data: (List<RestaurantEntity> restaurants) {
              final List<RestaurantEntity> favoriteRestaurants = restaurants
                  .where((RestaurantEntity r) => favoriteIds.contains(r.id))
                  .toList(growable: false);

              if (favoriteRestaurants.isEmpty) {
                return const _EmptyFavorites();
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFF8A4DFF),
                          Color(0xFFFF3F8E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "Favorites",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${favoriteRestaurants.length} saved places",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...favoriteRestaurants.map(
                    (RestaurantEntity restaurant) =>
                        _FavoriteRestaurantCard(restaurant: restaurant),
                  ),
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (_, __) => const _EmptyFavorites(),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, __) => const _EmptyFavorites(),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(Icons.favorite_border, size: 40),
          SizedBox(height: 12),
          Text("You have no favorites yet"),
          SizedBox(height: 4),
          Text(
            "Add restaurants from the details page.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _FavoriteRestaurantCard extends StatelessWidget {
  const _FavoriteRestaurantCard({required this.restaurant});

  final RestaurantEntity restaurant;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push("/restaurant/${restaurant.id}"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 150,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(
                Icons.restaurant_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          restaurant.nameEn,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Open",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.descriptionEn.isEmpty
                        ? "Restaurant"
                        : restaurant.descriptionEn,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


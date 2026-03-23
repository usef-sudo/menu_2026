import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.favoritesPageTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.favorite_border, size: 40),
              const SizedBox(height: 12),
              Text(l10n.favoritesSignInPrompt),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push("/auth/login"),
                child: Text(l10n.favoritesSignInButton),
              ),
            ],
          ),
        ),
      );
    }

    final favoritesAsync = ref.watch(favoritesControllerProvider);
    final restaurantsAsync = ref.watch(restaurantsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesPageTitle)),
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
                        Text(
                          l10n.favoritesPageTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.favoritesSavedCount(favoriteRestaurants.length),
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
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.favorite_border, size: 40),
          const SizedBox(height: 12),
          Text(l10n.favoritesEmpty),
          const SizedBox(height: 4),
          Text(
            l10n.favoritesEmptyHint,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
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
    final l10n = context.l10n;
    final String lang = Localizations.localeOf(context).languageCode;
    final String name = (lang == "ar" && restaurant.nameAr.isNotEmpty)
        ? restaurant.nameAr
        : (restaurant.nameEn.isNotEmpty
            ? restaurant.nameEn
            : restaurant.nameAr);
    final String description = (lang == "ar" && restaurant.descriptionAr.isNotEmpty)
        ? restaurant.descriptionAr
        : (restaurant.descriptionEn.isNotEmpty
            ? restaurant.descriptionEn
            : restaurant.descriptionAr);
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
                          name,
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
                          l10n.openNow,
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
                    description.isEmpty ? l10n.restaurantDetails : description,
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


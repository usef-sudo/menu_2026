import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/offers/presentation/controllers/offers_controller.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";
import "package:menu_2026/features/spin/presentation/pages/spin_page.dart";

class HomeDiscoveryPage extends ConsumerWidget {
  const HomeDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsControllerProvider);
    final categoriesAsync = ref.watch(categoriesControllerProvider);
    final offersAsync = ref.watch(offersControllerProvider);
    final favoritesAsync = ref.watch(favoritesControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(restaurantsControllerProvider.notifier).refresh();
        await ref.read(categoriesControllerProvider.notifier).refresh();
        ref.invalidate(offersControllerProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _DiscoverHeader(
            onSearch: (String value) {
              ref.read(restaurantsFilterProvider.notifier).state =
                  RestaurantsFilter(search: value.trim());
              ref.invalidate(restaurantsControllerProvider);
            },
          ),
          const SizedBox(height: 24),
          _CategoriesSection(
            categoriesAsync: categoriesAsync,
          ),
          const SizedBox(height: 24),
          _TopRestaurantsSection(
            restaurantsAsync: restaurantsAsync,
            favoritesAsync: favoritesAsync,
          ),
          const SizedBox(height: 24),
          // Optional horizontal offers carousel under top section.
          // For now, keep it light-weight and only show when offers exist.
          offersAsync.when(
            data: (offers) {
              if (offers.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Offers",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: offers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return Chip(label: Text(offers[index].title));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          _SpinCtaCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SpinPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
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
            "Discover",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: "Search restaurants or categories",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: onSearch,
              onChanged: (String value) {
                // Trigger live search with trimmed value
                onSearch(value.trim());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection({required this.categoriesAsync});

  final AsyncValue<List<CategoryEntity>> categoriesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Categories",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        categoriesAsync.when(
          data: (List<CategoryEntity> categories) {
            if (categories.isEmpty) {
              return const Text("No categories yet");
            }
            return SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final CategoryEntity category = categories[index];
                  return _CategoryChip(
                    category: category,
                    onTap: () {
                      ref.read(restaurantsFilterProvider.notifier).state =
                          RestaurantsFilter(categoryId: category.id);
                      ref
                          .read(restaurantsControllerProvider.notifier)
                          .refresh();
                      context.push(
                        "/categories/${category.id}",
                        extra: category.nameEn,
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object error, StackTrace stack) =>
              const Text("Unable to load categories"),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final CategoryEntity category;
  final VoidCallback onTap;

  String get _emoji {
    final String name = category.nameEn.toLowerCase();
    if (name.contains("burger")) return "🍔";
    if (name.contains("shawarma")) return "🌯";
    if (name.contains("pizza")) return "🍕";
    if (name.contains("coffee")) return "☕️";
    if (name.contains("dessert")) return "🍰";
    return "🍽️";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              category.nameEn,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopRestaurantsSection extends StatelessWidget {
  const _TopRestaurantsSection({
    required this.restaurantsAsync,
    required this.favoritesAsync,
  });

  final AsyncValue<List<RestaurantEntity>> restaurantsAsync;
  final AsyncValue<Set<String>> favoritesAsync;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Top Restaurants",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        restaurantsAsync.when(
          data: (List<RestaurantEntity> restaurants) {
            if (restaurants.isEmpty) {
              return const Text("No restaurants yet");
            }
            final Set<String> favorites =
                favoritesAsync.valueOrNull ?? <String>{};
            return Column(
              children: restaurants
                  .map(
                    (RestaurantEntity r) => _RestaurantCard(
                      restaurant: r,
                      isFavorite: favorites.contains(r.id),
                    ),
                  )
                  .toList(growable: false),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object error, StackTrace stack) =>
              const Text("Unable to load restaurants"),
        ),
      ],
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.isFavorite,
  });

  final RestaurantEntity restaurant;
  final bool isFavorite;

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
              height: 160,
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
                      if (isFavorite)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.favorite,
                                size: 14,
                                color: Colors.pink.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Favorite",
                                style: TextStyle(
                                  color: Colors.pink.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
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

class _SpinCtaCard extends StatelessWidget {
  const _SpinCtaCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFFFF7B65),
              Color(0xFFFF3F8E),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.casino_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  "Spin to Decide Where to Eat",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}


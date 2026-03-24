import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({
    required this.query,
    super.key,
  });

  final String query;

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      final RestaurantsFilter current = ref.read(restaurantsFilterProvider);
      ref.read(restaurantsFilterProvider.notifier).state = RestaurantsFilter(
        categoryId: current.categoryId,
        search: widget.query.isNotEmpty ? widget.query : current.search,
        minCostLevel: current.minCostLevel,
        maxCostLevel: current.maxCostLevel,
        openOnly: current.openOnly,
        sort: current.sort,
        facilityIds: current.facilityIds,
        openHoursFilter: current.openHoursFilter,
      );
      await ref.read(restaurantsControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AsyncValue<List<RestaurantEntity>> restaurantsAsync =
        ref.watch(restaurantsControllerProvider);

    return Scaffold(
      body: Column(
        children: <Widget>[
          _SearchHeader(query: widget.query),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: restaurantsAsync.when(
                data: (List<RestaurantEntity> restaurants) {
                  if (restaurants.isEmpty) {
                    return Center(child: Text(l10n.restaurantsNoneFound));
                  }
                  return ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (BuildContext context, int index) {
                      final RestaurantEntity restaurant = restaurants[index];
                      return _RestaurantCard(restaurant: restaurant);
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (Object error, StackTrace stack) =>
                    Center(child: Text(l10n.restaurantsLoadError)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 48, bottom: 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF8A4DFF), Color(0xFFFF3F8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty
                ? l10n.searchAllRestaurants
                : l10n.searchResultsFor(query),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});

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
    final String description =
        (lang == "ar" && restaurant.descriptionAr.isNotEmpty)
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
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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


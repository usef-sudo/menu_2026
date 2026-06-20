import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";
import "package:menu_2026/features/restaurants/presentation/widgets/restaurants_results_header.dart";

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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _localSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _localSearchQuery = widget.query.trim().toLowerCase();
    _searchController.addListener(() {
      setState(
        () => _localSearchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AsyncValue<List<RestaurantEntity>> restaurantsAsync =
        ref.watch(restaurantsControllerProvider);
    final String headerTitle = widget.query.isEmpty
        ? l10n.searchAllRestaurants
        : l10n.searchResultsFor(widget.query);

    return Scaffold(
      body: Column(
        children: <Widget>[
          RestaurantsResultsHeader(
            title: headerTitle,
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: restaurantsAsync.when(
                data: (List<RestaurantEntity> restaurants) {
                  final List<RestaurantEntity> filtered =
                      filterRestaurantsByQuery(restaurants, _localSearchQuery);
                  if (restaurants.isEmpty) {
                    return Center(child: Text(l10n.restaurantsNoneFound));
                  }
                  if (filtered.isEmpty) {
                    return Center(child: Text(l10n.searchNoResults));
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (BuildContext context, int index) {
                      final RestaurantEntity restaurant = filtered[index];
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

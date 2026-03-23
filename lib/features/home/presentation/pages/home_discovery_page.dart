import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/presentation/controllers/nearby_branches_controller.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/facilities/domain/entities/facility_entity.dart";
import "package:menu_2026/features/facilities/presentation/controllers/facilities_controller.dart";
import "package:menu_2026/features/home/presentation/controllers/home_places_sort.dart";
import "package:menu_2026/features/home/presentation/widgets/places_widgets.dart";
import "package:menu_2026/features/offers/domain/entities/offer_entity.dart";
import "package:menu_2026/features/offers/presentation/controllers/offers_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";
import "package:menu_2026/features/spin/presentation/pages/spin_page.dart";

class HomeFilter {
  const HomeFilter({
    this.maxDistanceKm,
    this.openOnly = false,
    this.priceMin,
    this.priceMax,
    this.minRating,
    this.categoryId,
    this.dietaryOptions = const <String>[],
  });

  final double? maxDistanceKm;
  final bool openOnly;
  final int? priceMin;
  final int? priceMax;
  final double? minRating;
  final String? categoryId;
  final List<String> dietaryOptions;

  int get activeCount {
    int n = 0;
    if (maxDistanceKm != null) n++;
    if (openOnly) n++;
    if (priceMin != null || priceMax != null) n++;
    if (minRating != null && minRating! > 0) n++;
    if (categoryId != null && categoryId!.isNotEmpty) n++;
    if (dietaryOptions.isNotEmpty) n++;
    return n;
  }

  HomeFilter copyWith({
    double? maxDistanceKm,
    bool? openOnly,
    int? priceMin,
    int? priceMax,
    double? minRating,
    String? categoryId,
    List<String>? dietaryOptions,
  }) {
    return HomeFilter(
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      openOnly: openOnly ?? this.openOnly,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      minRating: minRating ?? this.minRating,
      categoryId: categoryId ?? this.categoryId,
      dietaryOptions: dietaryOptions ?? this.dietaryOptions,
    );
  }
}

final homeFilterProvider = StateProvider<HomeFilter>(
  (Ref ref) => const HomeFilter(),
);

class HomeDiscoveryPage extends ConsumerWidget {
  const HomeDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyBranchesControllerProvider);
    final offersAsync = ref.watch(offersControllerProvider);

    final HomeFilter filter = ref.watch(homeFilterProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(nearbyBranchesControllerProvider);
        ref.invalidate(offersControllerProvider);
      },
      child: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: <Widget>[
              _DiscoverHeader(
                onSearch: (String value) {
                  final String query = value.trim();
                  ref
                      .read(restaurantsFilterProvider.notifier)
                      .state = RestaurantsFilter(
                    search: query.isNotEmpty ? query : null,
                  );
                  ref.invalidate(restaurantsControllerProvider);
                  context.push("/search/results", extra: query);
                },
                onFilterTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) => _SuperFilterSheet(
                      initial: filter,
                      initialRestaurantsFilter:
                          ref.read(restaurantsFilterProvider),
                      onApply: (HomeFilter f) {
                        ref.read(homeFilterProvider.notifier).state = f;
                        Navigator.of(context).pop();
                      },
                      onReset: () {
                        ref.read(homeFilterProvider.notifier).state =
                            const HomeFilter();
                        ref.read(restaurantsFilterProvider.notifier).state =
                            const RestaurantsFilter();
                        ref.read(restaurantsControllerProvider.notifier).refresh();
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _OffersBannerSection(offersAsync: offersAsync),
              const SizedBox(height: 16),
              const _PlacesFilterChips(),
              const SizedBox(height: 16),
              _PlacesResults(nearbyAsync: nearbyAsync),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _SpinCtaCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SpinPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacesFilterChips extends ConsumerWidget {
  const _PlacesFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final HomePlacesSort selected = ref.watch(homePlacesSortProvider);

    Widget chip({
      required String label,
      required IconData icon,
      required HomePlacesSort value,
    }) {
      final bool isSelected = selected == value;
      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: isSelected ? theme.colorScheme.onPrimary : null,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: theme.colorScheme.onPrimary,
        labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimary : null,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) =>
            ref.read(homePlacesSortProvider.notifier).state = value,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              chip(
                label: l10n.homeNearby,
                icon: Icons.near_me_outlined,
                value: HomePlacesSort.nearby,
              ),
              chip(
                label: l10n.homeMostVoted,
                icon: Icons.trending_up_rounded,
                value: HomePlacesSort.mostVoted,
              ),
              chip(
                label: l10n.homeRecommended,
                icon: Icons.auto_awesome_rounded,
                value: HomePlacesSort.recommended,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlacesResults extends ConsumerWidget {
  const _PlacesResults({required this.nearbyAsync});

  final AsyncValue<List<NearbyBranchWithDistance>> nearbyAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomePlacesSort selected = ref.watch(homePlacesSortProvider);
    return switch (selected) {
      HomePlacesSort.nearby => _NearbySection(nearbyAsync: nearbyAsync),
      HomePlacesSort.mostVoted => _MostVotedSection(nearbyAsync: nearbyAsync),
      HomePlacesSort.recommended =>
        _RecommendedSection(nearbyAsync: nearbyAsync),
    };
  }
}

class _OffersBannerSection extends ConsumerStatefulWidget {
  const _OffersBannerSection({required this.offersAsync});

  final AsyncValue<List<OfferEntity>> offersAsync;

  @override
  ConsumerState<_OffersBannerSection> createState() =>
      _OffersBannerSectionState();
}

class _OffersBannerSectionState extends ConsumerState<_OffersBannerSection> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.offersAsync.when(
      data: (offers) {
        final List<OfferEntity> offersWithImages = offers
            .where((o) => o.imageUrl.isNotEmpty)
            .toList(growable: false);
        if (offersWithImages.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: <Widget>[
            //     Text(
            //       "Featured",
            //       style: theme.textTheme.titleMedium?.copyWith(
            //         fontWeight: FontWeight.w700,
            //       ),
            //     ),
            //     Row(
            //       children: List.generate(
            //         dotsCount,
            //         (int i) => AnimatedContainer(
            //           duration: const Duration(milliseconds: 200),
            //           margin: const EdgeInsets.only(left: 6),
            //           width: i == (_index % dotsCount) ? 16 : 6,
            //           height: 6,
            //           decoration: BoxDecoration(
            //             color: i == (_index % dotsCount)
            //                 ? theme.colorScheme.primary
            //                 : theme.colorScheme.outline.withValues(alpha: 0.35),
            //             borderRadius: BorderRadius.circular(999),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),
            //
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _controller,
                itemCount: offersWithImages.length,
                itemBuilder: (BuildContext context, int i) {
                  final OfferEntity offer = offersWithImages[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _OfferBannerCard(
                      imageUrl: offer.imageUrl,
                      title: offer.title,
                      subtitle: offer.description,
                      onTap: () =>
                          context.push("/restaurant/${offer.restaurantId}"),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _OfferBannerCard extends StatelessWidget {
  const _OfferBannerCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      elevation: 10,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: theme.colorScheme.surfaceContainerHighest),
              errorWidget: (context, url, error) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({required this.onSearch, required this.onFilterTap});

  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF8A4DFF), Color(0xFFFF3F8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.homeDiscover,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: l10n.homeSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: onSearch,
                  // Only trigger search when the user presses enter.
                  onChanged: null,
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onFilterTap,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF8A4DFF),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Categories section intentionally removed from Home. We now use banners + chips.

class _NearbySection extends StatelessWidget {
  const _NearbySection({required this.nearbyAsync});

  final AsyncValue<List<NearbyBranchWithDistance>> nearbyAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PlacesListSection(
      title: l10n.homeNearbyPlaces,
      nearbyAsync: nearbyAsync,
      sort: HomePlacesSort.nearby,
      emptyText: l10n.homeNearbyEmpty,
    );
  }
}

class _MostVotedSection extends StatelessWidget {
  const _MostVotedSection({required this.nearbyAsync});

  final AsyncValue<List<NearbyBranchWithDistance>> nearbyAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PlacesListSection(
      title: l10n.homeMostVotedTitle,
      nearbyAsync: nearbyAsync,
      sort: HomePlacesSort.mostVoted,
      emptyText: l10n.homeMostVotedEmpty,
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection({required this.nearbyAsync});

  final AsyncValue<List<NearbyBranchWithDistance>> nearbyAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PlacesListSection(
      title: l10n.homeRecommendedTitle,
      nearbyAsync: nearbyAsync,
      sort: HomePlacesSort.recommended,
      emptyText: l10n.homeRecommendedEmpty,
    );
  }
}

class _SuperFilterSheet extends ConsumerStatefulWidget {
  const _SuperFilterSheet({
    required this.initial,
    this.initialRestaurantsFilter,
    required this.onApply,
    required this.onReset,
  });

  final HomeFilter initial;
  final RestaurantsFilter? initialRestaurantsFilter;
  final ValueChanged<HomeFilter> onApply;
  final VoidCallback onReset;

  @override
  ConsumerState<_SuperFilterSheet> createState() => _SuperFilterSheetState();
}

class _SuperFilterSheetState extends ConsumerState<_SuperFilterSheet> {
  late double _maxDistanceKm;
  late bool _distanceEnabled;
  late bool _openOnly;
  late int? _priceMin;
  late int? _priceMax;
  late double? _minRating;
  late String? _categoryId;

  List<String> _selectedFacilityIds = <String>[];

  @override
  void initState() {
    super.initState();
    _maxDistanceKm = widget.initial.maxDistanceKm ?? 10;
    _distanceEnabled = widget.initial.maxDistanceKm != null;
    _openOnly = widget.initial.openOnly;
    _priceMin = widget.initial.priceMin ?? widget.initialRestaurantsFilter?.minCostLevel;
    _priceMax = widget.initial.priceMax ?? widget.initialRestaurantsFilter?.maxCostLevel;
    _minRating = widget.initial.minRating;
    _categoryId = widget.initial.categoryId ?? widget.initialRestaurantsFilter?.categoryId;
    _selectedFacilityIds = List<String>.from(
      widget.initialRestaurantsFilter?.facilityIds ?? <String>[],
    );
  }

  int get _activeCount {
    int n = 0;
    if (_distanceEnabled) n++;
    if (_openOnly) n++;
    if (_priceMin != null || _priceMax != null) n++;
    if (_minRating != null && _minRating! > 0) n++;
    if (_categoryId != null && _categoryId!.isNotEmpty) n++;
    if (_selectedFacilityIds.isNotEmpty) n++;
    return n;
  }

  HomeFilter get _currentFilter => HomeFilter(
    maxDistanceKm: _distanceEnabled ? _maxDistanceKm : null,
    openOnly: _openOnly,
    priceMin: _priceMin,
    priceMax: _priceMax,
    minRating: _minRating,
    categoryId: _categoryId,
        dietaryOptions: const <String>[],
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mq = MediaQuery.of(context);
    final l10n = context.l10n;
    final int active = _activeCount;
    final AsyncValue<List<CategoryEntity>> categoriesAsync =
        ref.watch(categoriesControllerProvider);
    final AsyncValue<List<FacilityEntity>> facilitiesAsync =
        ref.watch(facilitiesControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: mq.viewPadding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.filtersTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        active == 1
                            ? l10n.filtersActiveOne
                            : l10n.filtersActiveMany(active),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8A4DFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  _FilterExpansionTile(
                    title: l10n.filterPriceRange,
                    value: _priceMin != null || _priceMax != null
                        ? "${_priceMin ?? 1}\$ - ${_priceMax ?? 5}\$"
                        : null,
                    child: Row(
                      children: <Widget>[
                        DropdownButton<int?>(
                          value: _priceMin,
                          hint: Text(l10n.filterMin),
                          items: <DropdownMenuItem<int?>>[
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(l10n.filterAny),
                            ),
                            ...List<int>.generate(5, (int i) => i + 1).map(
                              (int v) => DropdownMenuItem<int?>(
                                value: v,
                                child: Text("$v\$"),
                              ),
                            ),
                          ],
                          onChanged: (int? v) => setState(() => _priceMin = v),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<int?>(
                          value: _priceMax,
                          hint: Text(l10n.filterMax),
                          items: <DropdownMenuItem<int?>>[
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(l10n.filterAny),
                            ),
                            ...List<int>.generate(5, (int i) => i + 1).map(
                              (int v) => DropdownMenuItem<int?>(
                                value: v,
                                child: Text("$v\$"),
                              ),
                            ),
                          ],
                          onChanged: (int? v) => setState(() => _priceMax = v),
                        ),
                      ],
                    ),
                  ),
                  _FilterExpansionTile(
                    title: l10n.filterMinRating,
                    value: _minRating != null && _minRating! > 0
                        ? "${_minRating!.toStringAsFixed(1)}+"
                        : null,
                    child: Slider(
                      value: _minRating ?? 0,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating == null || _minRating == 0
                          ? l10n.filterAny
                          : _minRating!.toStringAsFixed(1),
                      onChanged: (double v) =>
                          setState(() => _minRating = v == 0 ? null : v),
                    ),
                  ),
                  _FilterExpansionTile(
                    title: l10n.filterDistance,
                    value: _distanceEnabled
                        ? l10n.filterWithinKm(
                            _maxDistanceKm.toStringAsFixed(0),
                          )
                        : null,
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _distanceEnabled,
                          title: Text(l10n.filterLimitByDistance),
                          onChanged: (bool v) =>
                              setState(() => _distanceEnabled = v),
                        ),
                        if (_distanceEnabled)
                          Slider(
                            value: _maxDistanceKm,
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: l10n.filterKmShort(
                              _maxDistanceKm.toStringAsFixed(0),
                            ),
                            onChanged: (double v) =>
                                setState(() => _maxDistanceKm = v),
                          ),
                      ],
                    ),
                  ),
                  _FilterExpansionTile(
                    title: l10n.filterAvailability,
                    value: _openOnly ? l10n.filterOpenNowOnly : null,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _openOnly,
                      title: Text(l10n.filterOpenNowOnly),
                      onChanged: (bool v) => setState(() => _openOnly = v),
                    ),
                  ),
                  _FilterExpansionTile(
                    title: l10n.filterCuisineType,
                    value: _categoryId != null ? l10n.filterCuisineSelected : null,
                    child: categoriesAsync.when(
                      data: (List<CategoryEntity> list) {
                        return Column(
                          children: <Widget>[
                            RadioListTile<String?>(
                              value: null,
                              groupValue: _categoryId,
                              title: Text(l10n.filterAny),
                              onChanged: (String? v) =>
                                  setState(() => _categoryId = v),
                            ),
                            ...list.map(
                              (CategoryEntity c) => RadioListTile<String?>(
                                value: c.id,
                                groupValue: _categoryId,
                                title: Text(c.nameEn),
                                onChanged: (String? v) =>
                                    setState(() => _categoryId = v),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Text(l10n.unableToLoad),
                    ),
                  ),
                  _FilterExpansionTile(
                    title: l10n.filterFacilities,
                    value: _selectedFacilityIds.isEmpty
                        ? null
                        : l10n.filterFacilitiesCount(
                            _selectedFacilityIds.length,
                          ),
                    child: facilitiesAsync.when(
                      data: (List<FacilityEntity> facilities) {
                        if (facilities.isEmpty) {
                          return Text(l10n.filterNoFacilities);
                        }
                        return Column(
                          children: facilities
                              .map(
                                (FacilityEntity f) => CheckboxListTile(
                                  value: _selectedFacilityIds.contains(f.id),
                                  title: Text(f.nameEn),
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedFacilityIds = <String>{
                                          ..._selectedFacilityIds,
                                          f.id,
                                        }.toList();
                                      } else {
                                        _selectedFacilityIds = List<String>.from(
                                          _selectedFacilityIds,
                                        )..remove(f.id);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) =>
                          Text(l10n.unableToLoadFacilities),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      onTap: () {
                        // Update branch filters
                        widget.onApply(_currentFilter);
                        // Also update restaurants filter so restaurant lists use same settings
                        ref.read(restaurantsFilterProvider.notifier).state =
                            RestaurantsFilter(
                          categoryId: _categoryId,
                          minCostLevel: _priceMin,
                          maxCostLevel: _priceMax,
                          openOnly: _openOnly,
                          facilityIds: _selectedFacilityIds,
                          sort: _minRating != null && _minRating! > 0
                              ? "votes"
                              : "newest",
                        );
                        ref
                            .read(restaurantsControllerProvider.notifier)
                            .refresh();
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF8A4DFF),
                              Color(0xFFFF3F8E),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        child: Center(
                          child: Text(
                            l10n.filterApply(active),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: widget.onReset,
                    child: Text(l10n.filterResetAll),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterExpansionTile extends StatelessWidget {
  const _FilterExpansionTile({
    required this.title,
    required this.child,
    this.value,
  });

  final String title;
  final String? value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ExpansionTile(
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: value != null
          ? Text(
              value!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8A4DFF),
              ),
            )
          : null,
      trailing: const Icon(Icons.expand_more),
      children: <Widget>[
        Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
      ],
    );
  }
}

// Card moved to `NearbyRestaurantCard` in `places_widgets.dart`.

class _SpinCtaCard extends StatelessWidget {
  const _SpinCtaCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFF7B65), Color(0xFFFF3F8E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.casino_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  l10n.homeSpinBanner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

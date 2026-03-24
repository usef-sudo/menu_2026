import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/presentation/controllers/nearby_branches_controller.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/facilities/domain/entities/facility_entity.dart";
import "package:menu_2026/features/facilities/presentation/controllers/facilities_controller.dart";
import "package:menu_2026/features/home/presentation/controllers/home_filter.dart";
import "package:menu_2026/features/home/presentation/controllers/home_places_sort.dart";
import "package:menu_2026/features/home/presentation/widgets/places_widgets.dart";
import "package:menu_2026/features/offers/domain/entities/offer_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";

class HomeDiscoverHeader extends StatelessWidget {
  const HomeDiscoverHeader({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
  });

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

class HomePlacesFilterChips extends ConsumerWidget {
  const HomePlacesFilterChips({super.key});

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
      child: Wrap(
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
    );
  }
}

class HomePlacesResults extends ConsumerWidget {
  const HomePlacesResults({super.key, required this.nearbyAsync});

  final AsyncValue<List<NearbyBranchWithDistance>> nearbyAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomePlacesSort selected = ref.watch(homePlacesSortProvider);
    final l10n = context.l10n;
    return switch (selected) {
      HomePlacesSort.nearby => PlacesListSection(
        title: l10n.homeNearbyPlaces,
        nearbyAsync: nearbyAsync,
        sort: HomePlacesSort.nearby,
        emptyText: l10n.homeNearbyEmpty,
      ),
      HomePlacesSort.mostVoted => PlacesListSection(
        title: l10n.homeMostVotedTitle,
        nearbyAsync: nearbyAsync,
        sort: HomePlacesSort.mostVoted,
        emptyText: l10n.homeMostVotedEmpty,
      ),
      HomePlacesSort.recommended => PlacesListSection(
        title: l10n.homeRecommendedTitle,
        nearbyAsync: nearbyAsync,
        sort: HomePlacesSort.recommended,
        emptyText: l10n.homeRecommendedEmpty,
      ),
    };
  }
}

class HomeOffersBannerSection extends StatefulWidget {
  const HomeOffersBannerSection({super.key, required this.offersAsync});

  final AsyncValue<List<OfferEntity>> offersAsync;

  @override
  State<HomeOffersBannerSection> createState() => _HomeOffersBannerSectionState();
}

class _HomeOffersBannerSectionState extends State<HomeOffersBannerSection> {
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
        return SizedBox(
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
                  onTap: () => context.push("/restaurant/${offer.restaurantId}"),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, _) => const SizedBox.shrink(),
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

class HomeSuperFilterSheet extends ConsumerStatefulWidget {
  const HomeSuperFilterSheet({
    super.key,
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
  ConsumerState<HomeSuperFilterSheet> createState() => _HomeSuperFilterSheetState();
}

class _HomeSuperFilterSheetState extends ConsumerState<HomeSuperFilterSheet> {
  static final RegExp _hm = RegExp(r"^([01]?\d|2[0-3]):([0-5]\d)$");

  late double _maxDistanceKm;
  late bool _distanceEnabled;
  late bool _openOnly;
  late int? _priceMin;
  late int? _priceMax;
  late double? _minRating;
  late String? _categoryId;
  List<String> _selectedFacilityIds = <String>[];
  late final List<bool> _hoursEnabled;
  late final List<TextEditingController> _hoursFromCtrls;
  late final List<TextEditingController> _hoursToCtrls;

  @override
  void initState() {
    super.initState();
    _maxDistanceKm = widget.initial.maxDistanceKm ?? 10;
    _distanceEnabled = widget.initial.maxDistanceKm != null;
    _openOnly = widget.initial.openOnly;
    _priceMin =
        widget.initial.priceMin ?? widget.initialRestaurantsFilter?.minCostLevel;
    _priceMax =
        widget.initial.priceMax ?? widget.initialRestaurantsFilter?.maxCostLevel;
    _minRating = widget.initial.minRating;
    _categoryId =
        widget.initial.categoryId ?? widget.initialRestaurantsFilter?.categoryId;
    _selectedFacilityIds = List<String>.from(
      widget.initialRestaurantsFilter?.facilityIds ?? <String>[],
    );
    _hoursEnabled = List<bool>.filled(7, false);
    _hoursFromCtrls = List<TextEditingController>.generate(
      7,
      (_) => TextEditingController(text: "09:00"),
    );
    _hoursToCtrls = List<TextEditingController>.generate(
      7,
      (_) => TextEditingController(text: "22:00"),
    );
    final RestaurantOpenHoursFilter? hf =
        widget.initialRestaurantsFilter?.openHoursFilter;
    if (hf != null) {
      for (final RestaurantDayHoursFilter d in hf.days) {
        final int i = d.weekday - 1;
        if (i < 0 || i > 6) continue;
        _hoursEnabled[i] = true;
        _hoursFromCtrls[i].text = d.from;
        _hoursToCtrls[i].text = d.to;
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _hoursFromCtrls) {
      c.dispose();
    }
    for (final TextEditingController c in _hoursToCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  int get _activeCount {
    int n = 0;
    if (_distanceEnabled) n++;
    if (_openOnly) n++;
    if (_priceMin != null || _priceMax != null) n++;
    if (_minRating != null && _minRating! > 0) n++;
    if (_categoryId != null && _categoryId!.isNotEmpty) n++;
    if (_selectedFacilityIds.isNotEmpty) n++;
    if (!_openOnly && _hoursEnabled.any((e) => e)) n++;
    return n;
  }

  RestaurantOpenHoursFilter? _buildOpenHoursFilterOrNull() {
    final List<RestaurantDayHoursFilter> days = <RestaurantDayHoursFilter>[];
    for (int i = 0; i < 7; i++) {
      if (!_hoursEnabled[i]) continue;
      final String from = _hoursFromCtrls[i].text.trim();
      final String to = _hoursToCtrls[i].text.trim();
      if (!_hm.hasMatch(from) || !_hm.hasMatch(to)) {
        return null;
      }
      days.add(RestaurantDayHoursFilter(weekday: i + 1, from: from, to: to));
    }
    if (days.isEmpty) return null;
    return RestaurantOpenHoursFilter(days: days);
  }

  String _weekdayLabel(int weekday) {
    final DateTime anchor = DateTime(2024, 1, weekday);
    return DateFormat.E(Localizations.localeOf(context).toString()).format(anchor);
  }

  TimeOfDay? _parseTimeOfDay(String text) {
    final RegExpMatch? m = _hm.firstMatch(text.trim());
    if (m == null) return null;
    return TimeOfDay(
      hour: int.parse(m.group(1)!),
      minute: int.parse(m.group(2)!),
    );
  }

  String _toHm(TimeOfDay tod) {
    final String h = tod.hour.toString().padLeft(2, "0");
    final String m = tod.minute.toString().padLeft(2, "0");
    return "$h:$m";
  }

  String _displayHm12(String value) {
    return BranchEntity.formatHm12(value);
  }

  Future<void> _pickTime({
    required TextEditingController controller,
  }) async {
    final TimeOfDay initial =
        _parseTimeOfDay(controller.text) ?? const TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      controller.text = _toHm(picked);
    });
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
                    title: l10n.filterAvailability,
                    value: _openOnly ? l10n.filterOpenNowOnly : null,
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _openOnly,
                          title: Text(l10n.filterOpenNowOnly),
                          onChanged: (bool v) => setState(() => _openOnly = v),
                        ),
                        if (!_openOnly) ...<Widget>[
                          const SizedBox(height: 8),
                          for (int i = 0; i < 7; i++) ...<Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 46,
                                  child: Text(
                                    _weekdayLabel(i + 1),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: _hoursEnabled[i],
                                  onChanged: (bool? v) => setState(
                                    () => _hoursEnabled[i] = v ?? false,
                                  ),
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: !_hoursEnabled[i]
                                        ? null
                                        : () => _pickTime(
                                            controller: _hoursFromCtrls[i],
                                          ),
                                    style: OutlinedButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      "${l10n.filterMin}: ${_displayHm12(_hoursFromCtrls[i].text)}",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: !_hoursEnabled[i]
                                        ? null
                                        : () => _pickTime(
                                            controller: _hoursToCtrls[i],
                                          ),
                                    style: OutlinedButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      "${l10n.filterMax}: ${_displayHm12(_hoursToCtrls[i].text)}",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                    ),
                  ),
                  _FilterExpansionTile(
                    title: l10n.filterDistance,
                    value: _distanceEnabled
                        ? l10n.filterWithinKm(_maxDistanceKm.toStringAsFixed(0))
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
                    title: l10n.filterPriceRange,
                    value: _priceMin != null || _priceMax != null
                        ? "${_priceMin ?? 1}\$ - ${_priceMax ?? 5}\$"
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.filterMin,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            ChoiceChip(
                              label: Text(l10n.filterAny),
                              selected: _priceMin == null,
                              onSelected: (_) => setState(() => _priceMin = null),
                            ),
                            ...List<int>.generate(5, (int i) => i + 1).map(
                              (int v) => ChoiceChip(
                                label: Text("$v\$"),
                                selected: _priceMin == v,
                                onSelected: (_) => setState(() {
                                  _priceMin = v;
                                  if (_priceMax != null && _priceMax! < v) {
                                    _priceMax = v;
                                  }
                                }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.filterMax,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            ChoiceChip(
                              label: Text(l10n.filterAny),
                              selected: _priceMax == null,
                              onSelected: (_) => setState(() => _priceMax = null),
                            ),
                            ...List<int>.generate(5, (int i) => i + 1).map(
                              (int v) => ChoiceChip(
                                label: Text("$v\$"),
                                selected: _priceMax == v,
                                onSelected: (_) => setState(() {
                                  _priceMax = v;
                                  if (_priceMin != null && _priceMin! > v) {
                                    _priceMin = v;
                                  }
                                }),
                              ),
                            ),
                          ],
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
                      error: (_, _) => Text(l10n.unableToLoad),
                    ),
                  ),
                  _FilterExpansionTile(
                    title: l10n.filterFacilities,
                    value: _selectedFacilityIds.isEmpty
                        ? null
                        : l10n.filterFacilitiesCount(_selectedFacilityIds.length),
                    child: facilitiesAsync.when(
                      data: (List<FacilityEntity> facilities) {
                        if (facilities.isEmpty) return Text(l10n.filterNoFacilities);
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
                      error: (_, _) => Text(l10n.unableToLoadFacilities),
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
                        final RestaurantOpenHoursFilter? openHoursFilter =
                            _openOnly ? null : _buildOpenHoursFilterOrNull();
                        if (!_openOnly &&
                            _hoursEnabled.any((e) => e) &&
                            openHoursFilter == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Use HH:MM format for selected days"),
                            ),
                          );
                          return;
                        }
                        widget.onApply(_currentFilter);
                        ref.read(restaurantsFilterProvider.notifier).state =
                            RestaurantsFilter(
                          categoryId: _categoryId,
                          minCostLevel: _priceMin,
                          maxCostLevel: _priceMax,
                          openOnly: _openOnly,
                          facilityIds: _selectedFacilityIds,
                          openHoursFilter: openHoursFilter,
                          sort:
                              _minRating != null && _minRating! > 0 ? "votes" : "newest",
                        );
                        ref.read(restaurantsControllerProvider.notifier).refresh();
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[Color(0xFF8A4DFF), Color(0xFFFF3F8E)],
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

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/offers/presentation/controllers/offers_controller.dart";
import "package:menu_2026/features/branches/presentation/controllers/nearby_branches_controller.dart";
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
    final categoriesAsync = ref.watch(categoriesControllerProvider);
    final offersAsync = ref.watch(offersControllerProvider);

    final HomeFilter filter = ref.watch(homeFilterProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(nearbyBranchesControllerProvider);
        await ref.read(categoriesControllerProvider.notifier).refresh();
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
                  ref.read(restaurantsFilterProvider.notifier).state =
                      RestaurantsFilter(search: query.isNotEmpty ? query : null);
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
                      onApply: (HomeFilter f) {
                        ref.read(homeFilterProvider.notifier).state = f;
                        Navigator.of(context).pop();
                      },
                      onReset: () {
                        ref.read(homeFilterProvider.notifier).state =
                            const HomeFilter();
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _CategoriesSection(categoriesAsync: categoriesAsync),
              const SizedBox(height: 24),
              _NearbySection(nearbyAsync: nearbyAsync),
              const SizedBox(height: 24),
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
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return Chip(
                                label: Text(offers[index].title));
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

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({
    required this.onSearch,
    required this.onFilterTap,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
            "Discover",
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
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Search restaurants or categories",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: onSearch,
                  onChanged: (String value) => onSearch(value.trim()),
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
                separatorBuilder:
                    (BuildContext context, int index) =>
                        const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final CategoryEntity category = categories[index];
                  return _CategoryChip(
                    category: category,
                    onTap: () {
                      ref
                          .read(restaurantsFilterProvider.notifier)
                          .state = RestaurantsFilter(categoryId: category.id);
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
          loading:
              () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (Object error, StackTrace stack) =>
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
            Text(_emoji, style: const TextStyle(fontSize: 24)),
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

class _NearbySection extends StatelessWidget {
  const _NearbySection({required this.nearbyAsync});

  final AsyncValue<List<NearbyBranchWithDistance>> nearbyAsync;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, _) {
        final HomeFilter filter = ref.watch(homeFilterProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Nearby places",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {

                  },
                  icon: const Icon(Icons.align_horizontal_left),
                  label: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            nearbyAsync.when(
              data: (List<NearbyBranchWithDistance> branches) {
                Iterable<NearbyBranchWithDistance> filtered = branches;
                if (filter.maxDistanceKm != null) {
                  filtered = filtered.where(
                    (NearbyBranchWithDistance b) =>
                        b.distanceKm <= filter.maxDistanceKm!,
                  );
                }
                if (filter.openOnly) {
                  filtered = filtered.where(
                    (NearbyBranchWithDistance b) => b.branch.isOpen,
                  );
                }
                final List<NearbyBranchWithDistance> list =
                    filtered.toList(growable: false);
                if (list.isEmpty) {
                  return const Text("No nearby places match your filters");
                }
                return Column(
                  children: list
                      .take(10)
                      .map(
                        (NearbyBranchWithDistance b) =>
                            _NearbyCard(branchWithDistance: b),
                      )
                      .toList(growable: false),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              error: (Object error, StackTrace stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Unable to load nearby places",
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (error.toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          error.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => ref
                          .invalidate(nearbyBranchesControllerProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class _SuperFilterSheet extends ConsumerStatefulWidget {
  const _SuperFilterSheet({
    required this.initial,
    required this.onApply,
    required this.onReset,
  });

  final HomeFilter initial;
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
  late List<String> _dietaryOptions;

  static const List<String> _dietaryChoices = <String>[
    "Vegetarian",
    "Vegan",
    "Halal",
    "Gluten-free",
    "Dairy-free",
  ];

  @override
  void initState() {
    super.initState();
    _maxDistanceKm = widget.initial.maxDistanceKm ?? 10;
    _distanceEnabled = widget.initial.maxDistanceKm != null;
    _openOnly = widget.initial.openOnly;
    _priceMin = widget.initial.priceMin;
    _priceMax = widget.initial.priceMax;
    _minRating = widget.initial.minRating;
    _categoryId = widget.initial.categoryId;
    _dietaryOptions = List<String>.from(widget.initial.dietaryOptions);
  }

  int get _activeCount {
    int n = 0;
    if (_distanceEnabled) n++;
    if (_openOnly) n++;
    if (_priceMin != null || _priceMax != null) n++;
    if (_minRating != null && _minRating! > 0) n++;
    if (_categoryId != null && _categoryId!.isNotEmpty) n++;
    if (_dietaryOptions.isNotEmpty) n++;
    return n;
  }

  HomeFilter get _currentFilter => HomeFilter(
        maxDistanceKm: _distanceEnabled ? _maxDistanceKm : null,
        openOnly: _openOnly,
        priceMin: _priceMin,
        priceMax: _priceMax,
        minRating: _minRating,
        categoryId: _categoryId,
        dietaryOptions: _dietaryOptions,
      );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mq = MediaQuery.of(context);
    final int active = _activeCount;
    final AsyncValue<List<CategoryEntity>> categoriesAsync =
        ref.watch(categoriesControllerProvider);

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
                        "Filters",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$active active filter${active == 1 ? "" : "s"}",
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
                    title: "Price Range",
                    value: _priceMin != null || _priceMax != null
                        ? "${_priceMin ?? 1}\$ - ${_priceMax ?? 5}\$"
                        : null,
                    child: Row(
                      children: <Widget>[
                        DropdownButton<int?>(
                          value: _priceMin,
                          hint: const Text("Min"),
                          items: <DropdownMenuItem<int?>>[
                            const DropdownMenuItem<int?>(
                                value: null, child: Text("Any")),
                            ...List<int>.generate(5, (int i) => i + 1)
                                .map(
                                  (int v) => DropdownMenuItem<int?>(
                                    value: v,
                                    child: Text("$v\$"),
                                  ),
                                ),
                          ],
                          onChanged: (int? v) =>
                              setState(() => _priceMin = v),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<int?>(
                          value: _priceMax,
                          hint: const Text("Max"),
                          items: <DropdownMenuItem<int?>>[
                            const DropdownMenuItem<int?>(
                                value: null, child: Text("Any")),
                            ...List<int>.generate(5, (int i) => i + 1)
                                .map(
                                  (int v) => DropdownMenuItem<int?>(
                                    value: v,
                                    child: Text("$v\$"),
                                  ),
                                ),
                          ],
                          onChanged: (int? v) =>
                              setState(() => _priceMax = v),
                        ),
                      ],
                    ),
                  ),
                  _FilterExpansionTile(
                    title: "Minimum Rating",
                    value: _minRating != null && _minRating! > 0
                        ? "${_minRating!.toStringAsFixed(1)}+"
                        : null,
                    child: Slider(
                      value: _minRating ?? 0,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating == null || _minRating == 0
                          ? "Any"
                          : _minRating!.toStringAsFixed(1),
                      onChanged: (double v) =>
                          setState(() => _minRating = v == 0 ? null : v),
                    ),
                  ),
                  _FilterExpansionTile(
                    title: "Distance",
                    value: _distanceEnabled
                        ? "Within ${_maxDistanceKm.toStringAsFixed(0)} km"
                        : null,
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _distanceEnabled,
                          title: const Text("Limit by distance"),
                          onChanged: (bool v) =>
                              setState(() => _distanceEnabled = v),
                        ),
                        if (_distanceEnabled)
                          Slider(
                            value: _maxDistanceKm,
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: "${_maxDistanceKm.toStringAsFixed(0)} km",
                            onChanged: (double v) =>
                                setState(() => _maxDistanceKm = v),
                          ),
                      ],
                    ),
                  ),
                  _FilterExpansionTile(
                    title: "Availability",
                    value: _openOnly ? "Open now only" : null,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _openOnly,
                      title: const Text("Open now only"),
                      onChanged: (bool v) => setState(() => _openOnly = v),
                    ),
                  ),
                  _FilterExpansionTile(
                    title: "Cuisine Type",
                    value: _categoryId != null ? "Selected" : null,
                    child: categoriesAsync.when(
                      data: (List<CategoryEntity> list) {
                        return Column(
                          children: <Widget>[
                            RadioListTile<String?>(
                              value: null,
                              groupValue: _categoryId,
                              title: const Text("Any"),
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
                      error: (_, __) => const Text("Unable to load"),
                    ),
                  ),
                  _FilterExpansionTile(
                    title: "Dietary Options",
                    value: _dietaryOptions.isEmpty
                        ? null
                        : "${_dietaryOptions.length} selected",
                    child: Column(
                      children: _dietaryChoices
                          .map(
                            (String option) => CheckboxListTile(
                              value: _dietaryOptions.contains(option),
                              title: Text(option),
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    _dietaryOptions =
                                        List<String>.from(_dietaryOptions)
                                          ..add(option);
                                  } else {
                                    _dietaryOptions =
                                        List<String>.from(_dietaryOptions)
                                          ..remove(option);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(growable: false),
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
                      onTap: () => widget.onApply(_currentFilter),
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
                          borderRadius:
                              BorderRadius.circular(AppRadii.lg),
                        ),
                        child: Center(
                          child: Text(
                            "Apply Filters ($active)",
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
                    child: const Text("Reset All"),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: child,
        ),
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.branchWithDistance});

  final NearbyBranchWithDistance branchWithDistance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final branch = branchWithDistance.branch;
    return InkWell(
      onTap: () => context.push("/restaurant/${branch.restaurantId}"),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      branch.nameEn,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "${branchWithDistance.distanceKm.toStringAsFixed(1)} km",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  const Icon(Icons.place_outlined, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      branch.address,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            colors: <Color>[Color(0xFFFF7B65), Color(0xFFFF3F8E)],
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

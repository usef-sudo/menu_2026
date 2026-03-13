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
  const HomeFilter({this.maxDistanceKm, this.openOnly = false});

  final double? maxDistanceKm;
  final bool openOnly;

  HomeFilter copyWith({double? maxDistanceKm, bool? openOnly}) {
    return HomeFilter(
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      openOnly: openOnly ?? this.openOnly,
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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(nearbyBranchesControllerProvider);
        await ref.read(categoriesControllerProvider.notifier).refresh();
        ref.invalidate(offersControllerProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _DiscoverHeader(
            onSearch: (String value) {
              final String query = value.trim();
              ref.read(restaurantsFilterProvider.notifier).state =
                  RestaurantsFilter(search: query.isNotEmpty ? query : null);
              ref.invalidate(restaurantsControllerProvider);
              context.push("/search/results", extra: query);
            },
          ),
          const SizedBox(height: 24),
          _CategoriesSection(categoriesAsync: categoriesAsync),
          const SizedBox(height: 24),
          _NearbySection(nearbyAsync: nearbyAsync),
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
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 12),
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
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const SpinPage()));
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
         TextField(
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
              onChanged: (String value) {
                // Trigger live search with trimmed value
                onSearch(value.trim());
              },
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
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (BuildContext context) {
                        return _NearbyFilterSheet(initial: filter);
                      },
                    );
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filter"),
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
              error: (Object error, StackTrace stack) =>
                  const Text("Unable to load nearby places"),
            ),
          ],
        );
      },
    );
  }
}

class _NearbyFilterSheet extends ConsumerStatefulWidget {
  const _NearbyFilterSheet({required this.initial});

  final HomeFilter initial;

  @override
  ConsumerState<_NearbyFilterSheet> createState() =>
      _NearbyFilterSheetState();
}

class _NearbyFilterSheetState extends ConsumerState<_NearbyFilterSheet> {
  late double _maxDistance;
  late bool _enabled;
  late bool _openOnly;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initial.maxDistanceKm != null;
    _maxDistance = widget.initial.maxDistanceKm ?? 10;
    _openOnly = widget.initial.openOnly;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: mq.viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            "Filter nearby places",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _enabled,
            title: const Text("Limit by distance"),
            subtitle: Text(
              _enabled ? "Within ${_maxDistance.toStringAsFixed(1)} km" : "Any",
            ),
            onChanged: (bool value) {
              setState(() {
                _enabled = value;
              });
            },
          ),
          if (_enabled)
            Slider(
              value: _maxDistance,
              min: 1,
              max: 30,
              divisions: 29,
              label: "${_maxDistance.toStringAsFixed(1)} km",
              onChanged: (double value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _openOnly,
            title: const Text("Open now only"),
            onChanged: (bool value) {
              setState(() {
                _openOnly = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: () {
                  ref.read(homeFilterProvider.notifier).state =
                      const HomeFilter();
                  Navigator.of(context).pop();
                },
                child: const Text("Clear"),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ref.read(homeFilterProvider.notifier).state = HomeFilter(
                    maxDistanceKm: _enabled ? _maxDistance : null,
                    openOnly: _openOnly,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
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

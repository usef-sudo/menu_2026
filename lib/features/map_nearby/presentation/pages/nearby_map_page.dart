import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/map_nearby/presentation/controllers/map_filter_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_details_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_photos_controller.dart";
import "package:menu_2026/features/restaurants/presentation/pages/branch_details_page.dart";
import "package:url_launcher/url_launcher.dart";

class NearbyMapPage extends ConsumerStatefulWidget {
  const NearbyMapPage({super.key});

  @override
  ConsumerState<NearbyMapPage> createState() => _NearbyMapPageState();
}

class _NearbyMapPageState extends ConsumerState<NearbyMapPage> {
  GoogleMapController? _mapController;
  BranchWithDistance? _selectedBranch;
  bool _filterChipsVisible = true;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _navigateToBranch(BranchWithDistance branch) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${branch.branch.latitude},${branch.branch.longitude}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(mapFilteredBranchesProvider);
    final ThemeData theme = Theme.of(context);
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;
    final categoriesAsync = ref.watch(categoriesControllerProvider);
    final selectedCategoryIds = ref.watch(mapSelectedCategoryIdsProvider);
    final openOnly = ref.watch(mapOpenOnlyProvider);

    return branchesAsync.when(
      data: (List<BranchWithDistance> filtered) {
        if (filtered.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    openOnly
                        ? "No open branches nearby"
                        : "No branches nearby yet",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final BranchEntity first = filtered.first.branch;
        final LatLng center = LatLng(first.latitude, first.longitude);
        final Set<Marker> markers = _buildMarkers(filtered, theme);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Stack(
            children: [
              GoogleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                mapToolbarEnabled: true,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 14,
                ),
                markers: markers,
                onTap: (_) {
                  if (_selectedBranch != null) {
                    setState(() => _selectedBranch = null);
                  }
                },
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 16,
                left: 16,
                right: 16,
                child: _MapAppBar(
                  theme: theme,
                  total: filtered.length,
                  isMobile: isMobile,
                  openOnly: openOnly,
                  hasCategoryFilter: selectedCategoryIds.isNotEmpty,
                  onFilterTap: () => _showFilterDialog(
                    context,
                    theme,
                    categoriesAsync,
                    selectedCategoryIds,
                    openOnly,
                  ),
                ),
              ),
              if (!isMobile && _filterChipsVisible)
                _FilterChipsPanel(
                  theme: theme,
                  categoriesAsync: categoriesAsync,
                  selectedCategoryIds: selectedCategoryIds,
                  onCategoryTap: (String categoryId) =>
                      _onCategorySelected(categoryId),
                  onClose: () => setState(() => _filterChipsVisible = false),
                ),
              if (_selectedBranch != null && isMobile)
                _BranchBottomSheet(
                  branch: _selectedBranch!,
                  theme: theme,
                  onViewDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            BranchDetailsPage(branch: _selectedBranch!),
                      ),
                    );
                  },
                  onNavigate: () => _navigateToBranch(_selectedBranch!),
                ),
              if (_selectedBranch != null && !isMobile)
                _BranchSidePanel(
                  branch: _selectedBranch!,
                  theme: theme,
                  onClose: () => setState(() => _selectedBranch = null),
                  onViewDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            BranchDetailsPage(branch: _selectedBranch!),
                      ),
                    );
                  },
                  onNavigate: () => _navigateToBranch(_selectedBranch!),
                ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "Loading map…",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (Object error, StackTrace stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                "Unable to load map data",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers(
      List<BranchWithDistance> filtered, ThemeData theme) {
    return filtered.map((BranchWithDistance item) {
      final bool isSelected = _selectedBranch?.branch.id == item.branch.id;
      return Marker(
        markerId: MarkerId(item.branch.id),
        position: LatLng(item.branch.latitude, item.branch.longitude),
        infoWindow: InfoWindow(
          title: item.branch.nameEn,
          snippet: "${item.distanceKm.toStringAsFixed(1)} km away",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          setState(() => _selectedBranch = item);
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
                LatLng(item.branch.latitude, item.branch.longitude)),
          );
        },
      );
    }).toSet();
  }

  void _onCategorySelected(String categoryId) {
    final List<String> current = ref.read(mapSelectedCategoryIdsProvider);
    if (categoryId == "all") {
      ref.read(mapSelectedCategoryIdsProvider.notifier).state = <String>[];
      return;
    }
    final bool isSelected = current.contains(categoryId);
    if (isSelected) {
      ref.read(mapSelectedCategoryIdsProvider.notifier).state =
          current.where((id) => id != categoryId).toList(growable: false);
    } else {
      ref.read(mapSelectedCategoryIdsProvider.notifier).state = [
        ...current.where((id) => id != "all"),
        categoryId,
      ];
    }
  }

  void _showFilterDialog(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    List<String> selectedCategoryIds,
    bool openOnly,
  ) {
    List<String> tempIds = List<String>.from(selectedCategoryIds);
    bool tempOpenOnly = openOnly;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Categories"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text("All"),
                      value: tempIds.isEmpty,
                      onChanged: (bool? value) {
                        setState(() {
                          tempIds = value == true ? <String>[] : tempIds;
                        });
                      },
                    ),
                    categoriesAsync.when(
                      data: (List<CategoryEntity> categories) {
                        return Column(
                          children: categories
                              .map(
                                (CategoryEntity c) => CheckboxListTile(
                                  title: Text(c.nameEn),
                                  value: tempIds.contains(c.id),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        tempIds =
                                            [...tempIds.where((id) => id != "all"), c.id];
                                      } else {
                                        tempIds = tempIds
                                            .where((id) => id != c.id)
                                            .toList(growable: false);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () => const SizedBox(
                          height: 24,
                          child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Divider(),
                    CheckboxListTile(
                      title: const Text("Open now only"),
                      value: tempOpenOnly,
                      onChanged: (bool? value) =>
                          setState(() => tempOpenOnly = value ?? false),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                ref.read(mapSelectedCategoryIdsProvider.notifier).state =
                    tempIds;
                ref.read(mapOpenOnlyProvider.notifier).state = tempOpenOnly;
                setState(() => _selectedBranch = null);
                Navigator.pop(context);
              },
              child: const Text("Apply Filters"),
            ),
          ],
        );
      },
    );
  }
}

class _MapAppBar extends StatelessWidget {
  const _MapAppBar({
    required this.theme,
    required this.total,
    required this.isMobile,
    required this.openOnly,
    required this.hasCategoryFilter,
    required this.onFilterTap,
  });

  final ThemeData theme;
  final int total;
  final bool isMobile;
  final bool openOnly;
  final bool hasCategoryFilter;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      elevation: 8,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.map_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Restaurants Map",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$total ${openOnly ? "open " : ""}branches around you${hasCategoryFilter ? " (filtered)" : ""}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onFilterTap,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 22,
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        Text(
                          "Filter",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipsPanel extends StatelessWidget {
  const _FilterChipsPanel({
    required this.theme,
    required this.categoriesAsync,
    required this.selectedCategoryIds,
    required this.onCategoryTap,
    required this.onClose,
  });

  final ThemeData theme;
  final AsyncValue<List<CategoryEntity>> categoriesAsync;
  final List<String> selectedCategoryIds;
  final void Function(String categoryId) onCategoryTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 80,
      left: 16,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categories",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (List<CategoryEntity> categories) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text("All"),
                        selected: selectedCategoryIds.isEmpty,
                        selectedColor: theme.colorScheme.primary,
                        checkmarkColor: theme.colorScheme.onPrimary,
                        labelStyle: TextStyle(
                          color: selectedCategoryIds.isEmpty
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) => onCategoryTap("all"),
                      ),
                      ...categories.map(
                        (CategoryEntity c) {
                          final isSelected =
                              selectedCategoryIds.contains(c.id);
                          return FilterChip(
                            label: Text(c.nameEn),
                            selected: isSelected,
                            selectedColor: theme.colorScheme.primary,
                            checkmarkColor: theme.colorScheme.onPrimary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (_) => onCategoryTap(c.id),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    height: 24,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchBottomSheet extends StatelessWidget {
  const _BranchBottomSheet({
    required this.branch,
    required this.theme,
    required this.onViewDetails,
    required this.onNavigate,
  });

  final BranchWithDistance branch;
  final ThemeData theme;
  final VoidCallback onViewDetails;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.28,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: _BranchPanelContent(
            branch: branch,
            theme: theme,
            scrollController: scrollController,
            onViewDetails: onViewDetails,
            onNavigate: onNavigate,
          ),
        );
      },
    );
  }
}

class _BranchSidePanel extends StatelessWidget {
  const _BranchSidePanel({
    required this.branch,
    required this.theme,
    required this.onClose,
    required this.onViewDetails,
    required this.onNavigate,
  });

  final BranchWithDistance branch;
  final ThemeData theme;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: MediaQuery.paddingOf(context).top + 88,
      bottom: 16,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 12,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Restaurant details",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _BranchPanelContent(
                  branch: branch,
                  theme: theme,
                  scrollController: null,
                  onViewDetails: onViewDetails,
                  onNavigate: onNavigate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchPanelContent extends ConsumerWidget {
  const _BranchPanelContent({
    required this.branch,
    required this.theme,
    required this.scrollController,
    required this.onViewDetails,
    required this.onNavigate,
  });

  final BranchWithDistance branch;
  final ThemeData theme;
  final ScrollController? scrollController;
  final VoidCallback onViewDetails;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BranchEntity b = branch.branch;
    final AsyncValue<RestaurantDetailsState> detailsAsync =
        ref.watch(restaurantDetailsControllerProvider(b.restaurantId));
    final AsyncValue<List<RestaurantPhotoEntity>> photosAsync =
        ref.watch(restaurantPhotosControllerProvider(b.restaurantId));

    final String? categoryName = detailsAsync.valueOrNull?.categoryName;
    final String? description = detailsAsync.valueOrNull?.descriptionEn;
    final String? imageUrl = photosAsync.valueOrNull?.isNotEmpty == true
        ? photosAsync.valueOrNull!.first.imageUrl
        : null;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (BuildContext context, String url) =>
                          _ImagePlaceholder(theme: theme),
                      errorWidget: (BuildContext context, String url, _) =>
                          _ImagePlaceholder(theme: theme),
                    )
                  : _ImagePlaceholder(theme: theme),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            b.nameEn,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (categoryName != null && categoryName.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                categoryName,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: b.isOpen
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  b.isOpen ? "Open" : "Closed",
                  style: TextStyle(
                    color: b.isOpen
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  b.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${branch.distanceKm.toStringAsFixed(1)} km away",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info_outline_rounded, size: 20),
                  label: const Text("View details"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: onNavigate,
                icon: const Icon(Icons.navigation_rounded),
                tooltip: "Navigate",
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
              ),
          ],
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 56,
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/restaurants/presentation/pages/branch_details_page.dart";

class NearbyMapPage extends ConsumerStatefulWidget {
  const NearbyMapPage({super.key});

  @override
  ConsumerState<NearbyMapPage> createState() => _NearbyMapPageState();
}

class _NearbyMapPageState extends ConsumerState<NearbyMapPage> {
  GoogleMapController? _mapController;
  BranchWithDistance? _selectedBranch;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(branchesControllerProvider);
    final ThemeData theme = Theme.of(context);

    return branchesAsync.when(
      data: (List<BranchWithDistance> branches) {
        if (branches.isEmpty) {
          return const Center(child: Text("No branches nearby yet"));
        }

        final BranchEntity first = branches.first.branch;
        final Set<Marker> markers = branches
            .map(
              (BranchWithDistance item) => Marker(
                markerId: MarkerId(item.branch.id),
                position:
                    LatLng(item.branch.latitude, item.branch.longitude),
                infoWindow: InfoWindow(
                  title: item.branch.nameEn,
                  snippet: "${item.distanceKm.toStringAsFixed(1)} km away",
                ),
                onTap: () {
                  setState(() {
                    _selectedBranch = item;
                  });
                },
              ),
            )
            .toSet();

        return Scaffold(
          body: Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(first.latitude, first.longitude),
                  zoom: 13,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onTap: (_) {
                  setState(() {
                    _selectedBranch = null;
                  });
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: _MapHeader(
                  total: branches.length,
                  theme: theme,
                ),
              ),
              if (_selectedBranch != null)
                _BranchBottomSheet(branch: _selectedBranch!),
            ],
          ),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: Text("Unable to load map data")),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.total, required this.theme});

  final int total;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.place_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Nearby Places",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$total branches around you",
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

class _BranchBottomSheet extends StatelessWidget {
  const _BranchBottomSheet({required this.branch});

  final BranchWithDistance branch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    branch.branch.nameEn,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: branch.branch.isOpen
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    branch.branch.isOpen ? "Open" : "Closed",
                    style: TextStyle(
                      color: branch.branch.isOpen
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                const Icon(Icons.place_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    branch.branch.address,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${branch.distanceKm.toStringAsFixed(1)} km away",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BranchDetailsPage(branch: branch),
                        ),
                      );
                    },
                    child: const Text("View details"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


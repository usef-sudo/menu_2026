import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/features/branches/presentation/controllers/nearby_branches_controller.dart";
import "package:menu_2026/features/home/presentation/controllers/home_places_sort.dart";
import "package:menu_2026/features/home/presentation/widgets/places_widgets.dart";

class PlacesListPage extends ConsumerStatefulWidget {
  const PlacesListPage({super.key, required this.initialSort});

  final HomePlacesSort initialSort;

  @override
  ConsumerState<PlacesListPage> createState() => _PlacesListPageState();
}

class _PlacesListPageState extends ConsumerState<PlacesListPage> {
  late HomePlacesSort _sort;

  @override
  void initState() {
    super.initState();
    _sort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final nearbyAsync = ref.watch(nearbyBranchesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_sort) {
          HomePlacesSort.nearby => "Nearby",
          HomePlacesSort.mostVoted => "Most voted",
          HomePlacesSort.recommended => "Recommended",
        }),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(nearbyBranchesControllerProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _chip(
                    theme,
                    "Nearby",
                    Icons.near_me_outlined,
                    HomePlacesSort.nearby,
                  ),
                  _chip(
                    theme,
                    "Most voted",
                    Icons.trending_up_rounded,
                    HomePlacesSort.mostVoted,
                  ),
                  _chip(
                    theme,
                    "Recommended",
                    Icons.auto_awesome_rounded,
                    HomePlacesSort.recommended,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PlacesListSection(
              title: "",
              nearbyAsync: nearbyAsync,
              sort: _sort,
              emptyText: "No places found",
              showViewAll: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    ThemeData theme,
    String label,
    IconData icon,
    HomePlacesSort value,
  ) {
    final bool selected = _sort == value;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: FilterChip(
        selected: selected,
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: theme.colorScheme.onPrimary,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: selected ? theme.colorScheme.onPrimary : null,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        labelStyle: TextStyle(
          color: selected ? theme.colorScheme.onPrimary : null,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => setState(() => _sort = value),
      ),
    );
  }
}

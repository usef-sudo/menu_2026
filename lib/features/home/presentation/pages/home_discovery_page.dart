import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/features/branches/presentation/controllers/nearby_branches_controller.dart";
import "package:menu_2026/features/home/presentation/controllers/home_filter.dart";
import "package:menu_2026/features/home/presentation/widgets/home_discovery_widgets.dart";
import "package:menu_2026/features/home/presentation/widgets/home_spin_cta_card.dart";
import "package:menu_2026/features/offers/presentation/controllers/offers_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";
import "package:menu_2026/features/spin/presentation/pages/spin_page.dart";

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
              HomeDiscoverHeader(
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
                    builder: (BuildContext context) => HomeSuperFilterSheet(
                      initial: filter,
                      initialRestaurantsFilter:
                          ref.read(restaurantsFilterProvider),
                      onApply: (HomeFilter applied) {
                        ref.read(homeFilterProvider.notifier).state = applied;
                        Navigator.of(context).pop();
                        context.push("/search/results", extra: "");
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
              HomeOffersBannerSection(offersAsync: offersAsync),
              const SizedBox(height: 16),
              const HomePlacesFilterChips(),
              const SizedBox(height: 16),
              HomePlacesResults(nearbyAsync: nearbyAsync),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: HomeSpinCtaCard(
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

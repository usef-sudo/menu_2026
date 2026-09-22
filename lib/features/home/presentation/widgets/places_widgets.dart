import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/l10n/hours_label.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/presentation/controllers/nearby_branches_controller.dart";
import "package:menu_2026/features/home/presentation/controllers/home_filter.dart";
import "package:menu_2026/features/home/presentation/controllers/home_places_sort.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_details_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";
import "package:menu_2026/features/restaurants/presentation/widgets/restaurant_cover_image.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class PlacesListSection extends ConsumerWidget {
  const PlacesListSection({
    super.key,
    required this.title,
    required this.nearbyAsync,
    required this.sort,
    required this.emptyText,
    this.showViewAll = true,
  });

  final String title;
  final AsyncValue<List<NearbyBranchWithDistance>> nearbyAsync;
  final HomePlacesSort sort;
  final String emptyText;
  final bool showViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final HomeFilter filter = ref.watch(homeFilterProvider);
    final AsyncValue<List<RestaurantEntity>> restaurantsAsync = ref.watch(
      restaurantsControllerProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title.trim().isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showViewAll)
                TextButton.icon(
                  onPressed: () => context.push(
                    "/places?sort=${homePlacesSortToQuery(sort)}",
                  ),
                  icon: const Icon(Icons.align_horizontal_left),
                  label: Text(l10n.commonViewAll),
                ),
            ],
          ),
        if (title.trim().isNotEmpty) const SizedBox(height: 12),
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
                (NearbyBranchWithDistance b) => b.branch.isEffectivelyOpenNow(),
              );
            }

            // Category / price / facilities filters apply to Recommended & Most voted only.
            // Nearby stays location-based (distance + openOnly from home filter).
            if (sort != HomePlacesSort.nearby) {
              final Set<String>? allowedRestaurantIds = restaurantsAsync
                  .maybeWhen(
                    data: (List<RestaurantEntity> rests) =>
                        rests.map((RestaurantEntity r) => r.id).toSet(),
                    orElse: () => null,
                  );
              if (allowedRestaurantIds != null) {
                if (allowedRestaurantIds.isEmpty) {
                  filtered = filtered.where((_) => false);
                } else {
                  filtered = filtered.where(
                    (NearbyBranchWithDistance b) =>
                        allowedRestaurantIds.contains(b.branch.restaurantId),
                  );
                }
              }
            }

            final List<NearbyBranchWithDistance> list = filtered.toList(
              growable: true,
            );

            switch (sort) {
              case HomePlacesSort.nearby:
                list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
                break;
              case HomePlacesSort.mostVoted:
                int score(NearbyBranchWithDistance x) =>
                    x.branch.upVotes - x.branch.downVotes;
                list.sort((a, b) => score(b).compareTo(score(a)));
                break;
              case HomePlacesSort.recommended:
                // Prefer open now, active offers, and proximity; votes are a weak tie-breaker
                // so this list diverges from Most voted.
                double score(NearbyBranchWithDistance x) {
                  final int netVotes = x.branch.upVotes - x.branch.downVotes;
                  final double openBoost =
                      x.branch.isEffectivelyOpenNow() ? 20.0 : 0.0;
                  final int offers = x.branch.activeOfferCount ?? 0;
                  final double offerBoost =
                      offers > 0 ? (25.0 + (offers * 3.0)) : 0.0;
                  final double distancePenalty = x.distanceKm * 2.5;
                  final double voteBoost = netVotes * 0.2;
                  return openBoost + offerBoost + voteBoost - distancePenalty;
                }
                list.sort((a, b) => score(b).compareTo(score(a)));
                break;
            }

            if (list.isEmpty) return Text(emptyText);

            final int limit = showViewAll
                ? (sort == HomePlacesSort.recommended ? 8 : 10)
                : 200;

            return Column(
              children: list
                  .take(limit)
                  .map(
                    (NearbyBranchWithDistance b) =>
                        NearbyRestaurantCard(branchWithDistance: b),
                  )
                  .toList(growable: false),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object error, StackTrace stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(l10n.placesLoadError, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(nearbyBranchesControllerProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NearbyRestaurantCard extends ConsumerWidget {
  const NearbyRestaurantCard({super.key, required this.branchWithDistance});

  final NearbyBranchWithDistance branchWithDistance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final branch = branchWithDistance.branch;
    final l10n = context.l10n;
    final String lang = Localizations.localeOf(context).languageCode;
    final String branchName = _localizedEntityName(
      lang: lang,
      nameEn: branch.nameEn,
      nameAr: branch.nameAr,
    );

    final bool openNow = branch.isEffectivelyOpenNow();
    final String locale = Localizations.localeOf(context).toString();
    final String? hoursLine = _todaysHoursLine(branch, l10n, locale);

    final AsyncValue<List<RestaurantEntity>> restaurantsAsync = ref.watch(
      restaurantsControllerProvider,
    );
    final detailsAsync = ref.watch(
      restaurantDetailsControllerProvider(branch.restaurantId),
    );

    final String? categoryName = detailsAsync.valueOrNull?.categoryName;
    String logoUrl = "";

    String? restaurantName = restaurantsAsync.maybeWhen(
      data: (List<RestaurantEntity> rests) {
        for (final RestaurantEntity r in rests) {
          if (r.id == branch.restaurantId) {
            logoUrl = r.logoUrl;
            return _localizedEntityName(
              lang: lang,
              nameEn: r.nameEn,
              nameAr: r.nameAr,
            );
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final String detailsNameEn =
        detailsAsync.valueOrNull?.nameEn.trim() ?? "";
    if ((restaurantName == null || restaurantName.isEmpty) &&
        detailsNameEn.isNotEmpty) {
      restaurantName = detailsNameEn;
    }
    final String titleLine = _placeCardTitle(
      restaurantName: restaurantName,
      branchName: branchName,
    );

    return InkWell(
      onTap: () => context.push("/restaurant/${branch.restaurantId}"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  RestaurantCoverImage(
                    restaurantId: branch.restaurantId,
                    logoUrl: logoUrl,
                    height: 180,
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _StatusPill(isOpen: openNow),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          titleLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (categoryName != null && categoryName.isNotEmpty)
                              ? categoryName
                              : "—",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.65,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.distanceKm(
                            branchWithDistance.distanceKm.toStringAsFixed(1),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hoursLine != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            hoursLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
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

String _localizedEntityName({
  required String lang,
  required String nameEn,
  required String nameAr,
}) {
  return (lang == "ar" && nameAr.isNotEmpty)
      ? nameAr
      : (nameEn.isNotEmpty ? nameEn : nameAr);
}

String _placeCardTitle({
  required String? restaurantName,
  required String branchName,
}) {
  final String restaurant = restaurantName?.trim() ?? "";
  final String branch = branchName.trim();
  if (restaurant.isEmpty) {
    return branch.isNotEmpty ? branch : "—";
  }
  if (branch.isEmpty || branch == restaurant) {
    return restaurant;
  }
  return "$restaurant ($branch)";
}

String? _todaysHoursLine(
  BranchEntity branch,
  AppLocalizations l10n,
  String locale,
) {
  final String? r = localizedTodaysHours(
    branch: branch,
    l10n: l10n,
    locale: locale,
  );
  if (r == null) return null;
  if (r.isEmpty) return l10n.branchClosedToday;
  return r;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF00C853) : const Color(0xFFD50000),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? l10n.openNow : l10n.closed,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

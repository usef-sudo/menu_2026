import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/presentation/controllers/nearby_branches_controller.dart";
import "package:menu_2026/features/home/presentation/controllers/home_filter.dart";
import "package:menu_2026/features/home/presentation/controllers/home_places_sort.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_details_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_photos_controller.dart";
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
    final HomeFilter filter = ref.watch(homeFilterProvider);

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
                  label: const Text("View All"),
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
                (NearbyBranchWithDistance b) =>
                    b.branch.isEffectivelyOpenNow(),
              );
            }

            final List<NearbyBranchWithDistance> list =
                filtered.toList(growable: true);

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
                double score(NearbyBranchWithDistance x) {
                  final int votes = x.branch.upVotes - x.branch.downVotes;
                  final double openBoost =
                      x.branch.isEffectivelyOpenNow() ? 2.0 : 0.0;
                  return votes.toDouble() + openBoost - (x.distanceKm * 0.25);
                }
                list.sort((a, b) => score(b).compareTo(score(a)));
                break;
            }

            if (list.isEmpty) return Text(emptyText);

            final int limit = showViewAll ? (sort == HomePlacesSort.recommended ? 8 : 10) : 200;

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
                Text(
                  "Unable to load places",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(nearbyBranchesControllerProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
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
    final bool openNow = branch.isEffectivelyOpenNow();
    final String? hoursLine = _todaysHoursLine(branch, l10n);

    final detailsAsync = ref.watch(
      restaurantDetailsControllerProvider(branch.restaurantId),
    );
    final photosAsync =
        ref.watch(restaurantPhotosControllerProvider(branch.restaurantId));

    final String? categoryName = detailsAsync.valueOrNull?.categoryName;
    final double rating = detailsAsync.valueOrNull?.avgRating ?? 0;
    final String? imageUrl = photosAsync.valueOrNull?.isNotEmpty == true
        ? photosAsync.valueOrNull!.first.imageUrl
        : null;

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
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _ImageFallback(theme: theme),
                      errorWidget: (context, url, error) =>
                          _ImageFallback(theme: theme),
                    )
                  else
                    _ImageFallback(theme: theme),
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
                          branch.nameEn,
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
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
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (rating > 0.1)
                    _RatingPill(
                      rating: rating,
                      theme: theme,
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

String? _todaysHoursLine(BranchEntity branch, AppLocalizations l10n) {
  final String? r = branch.todaysHoursRangeLabel();
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

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.theme});

  final double rating;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 56,
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}


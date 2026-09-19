import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/jwt_user_id.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/profile/presentation/controllers/user_profile_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/menu_images_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_details_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_photos_controller.dart";
import "package:menu_2026/features/restaurants/presentation/pages/branch_details_page.dart";
import "package:menu_2026/features/restaurants/presentation/widgets/menu_flip_book_viewer.dart";
import "package:menu_2026/features/restaurants/presentation/widgets/restaurant_external_links.dart";
import "package:menu_2026/features/reviews/domain/entities/review_entity.dart";
import "package:menu_2026/features/reviews/presentation/controllers/reviews_controller.dart";
import "package:menu_2026/features/reviews/presentation/widgets/user_review_widgets.dart";

class RestaurantDetailsPage extends ConsumerStatefulWidget {
  const RestaurantDetailsPage({required this.restaurantId, super.key});

  final String restaurantId;

  @override
  ConsumerState<RestaurantDetailsPage> createState() =>
      _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends ConsumerState<RestaurantDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      restaurantDetailsControllerProvider(widget.restaurantId),
    );
    final session = ref.watch(sessionControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;
    final favorites =
        ref.watch(favoritesControllerProvider).valueOrNull ?? <String>{};
    final branchesAsync = ref.watch(
      restaurantBranchesProvider(widget.restaurantId),
    );

    return detailsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (Object error, StackTrace stack) => Builder(
        builder: (BuildContext ctx) => Scaffold(
          body: Center(
            child: Text(ctx.l10n.restaurantLoadError(error.toString())),
          ),
        ),
      ),
      data: (RestaurantDetailsState details) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: _HeroAndCard(
                          restaurantId: details.id,
                          nameEn: details.nameEn,
                          descriptionEn: details.descriptionEn,
                          categoryName: details.categoryName,
                          branchesCount: details.branchesCount,
                          totalVotes: details.totalVotes,
                          avgRating: details.avgRating,
                          facilities: details.facilities,
                          websiteUrl: details.websiteUrl,
                          instagramUrl: details.instagramUrl,
                          facebookUrl: details.facebookUrl,
                          talabatUrl: details.talabatUrl,
                          careemUrl: details.careemUrl,
                          isLoggedIn: isLoggedIn,
                          isFavorite: favorites.contains(details.id),
                          onFavoriteTap: () async {
                            if (!isLoggedIn) {
                              context.push("/auth/login");
                              return;
                            }
                            final bool success = await ref
                                .read(favoritesControllerProvider.notifier)
                                .toggle(details.id);
                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.favoriteUpdateError,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabBarDelegate(
                          child: Material(
                            color: Theme.of(context).colorScheme.surface,
                            child: TabBar(
                              indicatorColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              labelColor: Theme.of(context).colorScheme.primary,
                              unselectedLabelColor: Colors.grey,
                              tabs: <Widget>[
                                Tab(text: context.l10n.tabBranches),
                                Tab(text: context.l10n.tabMenu),
                                Tab(text: context.l10n.tabPhotos),
                                Tab(text: context.l10n.tabReviews),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
              body: TabBarView(
                children: <Widget>[
                  _BranchesTab(
                    restaurantId: details.id,
                    branchesAsync: branchesAsync,
                  ),
                  _MenuTab(restaurantId: details.id),
                  _PhotosTab(restaurantId: details.id),
                  _ReviewsTab(
                    restaurantId: details.id,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _HeroAndCard extends ConsumerWidget {
  const _HeroAndCard({
    required this.restaurantId,
    required this.nameEn,
    required this.descriptionEn,
    required this.categoryName,
    required this.branchesCount,
    required this.totalVotes,
    required this.avgRating,
    required this.facilities,
    required this.websiteUrl,
    required this.instagramUrl,
    required this.facebookUrl,
    required this.talabatUrl,
    required this.careemUrl,
    required this.isLoggedIn,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final String restaurantId;
  final String nameEn;
  final String descriptionEn;
  final String? categoryName;
  final int branchesCount;
  final int totalVotes;
  final double avgRating;
  final List<RestaurantFacility> facilities;
  final String websiteUrl;
  final String instagramUrl;
  final String facebookUrl;
  final String talabatUrl;
  final String careemUrl;
  final bool isLoggedIn;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final AsyncValue<List<RestaurantPhotoEntity>> photosAsync = ref.watch(
      restaurantPhotosControllerProvider(restaurantId),
    );
    final String? heroImageUrl = photosAsync.maybeWhen(
      data: (List<RestaurantPhotoEntity> photos) =>
          photos.isNotEmpty ? photos.first.imageUrl : null,
      orElse: () => null,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: heroImageUrl != null && heroImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: heroImageUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration:  BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        nameEn,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                      //    color: Colors.black87,
                        ),
                      ),
                    ),
                    if (avgRating > 0) ...<Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (descriptionEn.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    descriptionEn,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
                if (RestaurantExternalLinks.hasAny(
                  websiteUrl: websiteUrl,
                  instagramUrl: instagramUrl,
                  facebookUrl: facebookUrl,
                  talabatUrl: talabatUrl,
                  careemUrl: careemUrl,
                )) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RestaurantExternalLinks(
                      websiteUrl: websiteUrl,
                      instagramUrl: instagramUrl,
                      facebookUrl: facebookUrl,
                      talabatUrl: talabatUrl,
                      careemUrl: careemUrl,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _SummaryItem(
                      label: l10n.labelCategory,
                      value: categoryName ?? "-",
                    ),
                    _SummaryItem(
                      label: l10n.labelTotalVotes,
                      value: totalVotes.toString(),
                    ),
                    _SummaryItem(
                      label: l10n.labelBranchesCount,
                      value: branchesCount.toString(),
                    ),
                  ],
                ),
                if (facilities.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    l10n.facilitiesSectionTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: facilities
                        .map(
                          (RestaurantFacility f) =>
                              _FacilityChip(nameEn: f.nameEn, iconName: f.icon),
                        )
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.nameEn, this.iconName});

  final String nameEn;
  final String? iconName;

  static IconData _iconFor(String? name) {
    if (name == null || name.isEmpty) return Icons.place;
    final String n = name.toLowerCase();
    if (n.contains("wifi") || n.contains("wi-fi")) return Icons.wifi;
    if (n.contains("park")) return Icons.local_parking;
    if (n.contains("kid") || n.contains("family")) return Icons.family_restroom;
    if (n.contains("delivery") || n.contains("deliver"))
      return Icons.delivery_dining;
    return Icons.place;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_iconFor(iconName), size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            nameEn,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchesTab extends StatelessWidget {
  const _BranchesTab({required this.restaurantId, required this.branchesAsync});

  final String restaurantId;
  final AsyncValue<List<BranchWithDistance>> branchesAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return branchesAsync.when(
      data: (List<BranchWithDistance> all) {
        final List<BranchWithDistance> branchesForRestaurant = all
            .where(
              (BranchWithDistance b) => b.branch.restaurantId == restaurantId,
            )
            .toList(growable: false);
        if (branchesForRestaurant.isEmpty) {
          return Center(child: Text(l10n.restaurantNoBranches));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: branchesForRestaurant
              .map((BranchWithDistance b) => _BranchCard(branch: b))
              .toList(growable: false),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stack) =>
          Center(child: Text(l10n.restaurantBranchesLoadError)),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final BranchWithDistance branch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final String lang = Localizations.localeOf(context).languageCode;
    final String branchName = (lang == "ar" && branch.branch.nameAr.isNotEmpty)
        ? branch.branch.nameAr
        : (branch.branch.nameEn.isNotEmpty
              ? branch.branch.nameEn
              : branch.branch.nameAr);
    final BranchEntity b = branch.branch;
    final bool openNow = b.isEffectivelyOpenNow();
    final String? todayHours = b.todaysHoursRangeLabel();
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BranchDetailsPage(branch: branch),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              branchName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
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
              l10n.distanceKm(branch.distanceKm.toStringAsFixed(1)),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              openNow ? l10n.openNow : l10n.closed,
              style: theme.textTheme.labelMedium?.copyWith(
                color: openNow
                    ? const Color(0xFF2E7D32)
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (todayHours != null && todayHours.isNotEmpty) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                todayHours,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ] else if (todayHours != null && todayHours.isEmpty) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                l10n.branchClosedToday,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends ConsumerStatefulWidget {
  const _ReviewsTab({
    required this.restaurantId,
  });

  final String restaurantId;

  @override
  ConsumerState<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends ConsumerState<_ReviewsTab> {
  static const String _allBranchesId = "__all__";
  String _selectedBranchId = _allBranchesId;

  double _displayAvg(ReviewsState state) {
    if (state.reviews.isEmpty) {
      return 0;
    }
    if (state.summary.total > 0 &&
        state.reviews.length >= state.summary.total) {
      final int sum = state.reviews.fold<int>(
        0,
        (int acc, ReviewEntity r) => acc + r.rating,
      );
      return sum / state.reviews.length;
    }
    return state.summary.avgRating;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final branchesAsync = ref.watch(
      restaurantBranchesProvider(widget.restaurantId),
    );
    final session = ref.watch(sessionControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;
    return branchesAsync.when(
      data: (List<BranchWithDistance> branches) {
        if (branches.isEmpty) {
          return Center(child: Text(l10n.restaurantNoBranchesReview));
        }
        final bool viewingAll =
            _selectedBranchId == _allBranchesId ||
            !branches.any((b) => b.branch.id == _selectedBranchId);
        final AsyncValue<ReviewsState> reviewsAsync = viewingAll
            ? ref.watch(
                restaurantReviewsControllerProvider(widget.restaurantId),
              )
            : ref.watch(reviewsControllerProvider(_selectedBranchId));
        return reviewsAsync.when(
          data: (ReviewsState state) {
            final String? profileId =
                ref.watch(userProfileControllerProvider).valueOrNull?.id.trim();
            final String? myId =
                (profileId != null && profileId.isNotEmpty)
                    ? profileId
                    : jwtUserId(session.valueOrNull?.token);
            final ReviewEntity? myReview = findMyReview(state.reviews, myId);
            final String writeBranchId =
                (myReview != null && myReview.branchId.isNotEmpty)
                ? myReview.branchId
                : (viewingAll
                    ? branches.first.branch.id
                    : _selectedBranchId);
            final double displayAvg = _displayAvg(state);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (branches.length > 1) ...<Widget>[
                  DropdownButtonFormField<String>(
                    value: viewingAll ? _allBranchesId : _selectedBranchId,
                    decoration: InputDecoration(
                      labelText: l10n.adminBranchTitle,
                    ),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: _allBranchesId,
                        child: Text(l10n.reviewsAllBranches),
                      ),
                      ...branches.map(
                        (BranchWithDistance b) => DropdownMenuItem<String>(
                          value: b.branch.id,
                          child: Text(
                            b.branch.nameEn.isNotEmpty
                                ? b.branch.nameEn
                                : b.branch.nameAr,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (String? id) {
                      if (id == null) return;
                      setState(() => _selectedBranchId = id);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                _ReviewsSummary(
                  avgRating: displayAvg,
                  total: state.summary.total,
                ),
                const SizedBox(height: 12),
                WriteReviewButton(
                  branchId: writeBranchId,
                  restaurantId: widget.restaurantId,
                  isLoggedIn: isLoggedIn,
                  existingReview: myReview,
                ),
                const SizedBox(height: 16),
                if (state.summary.total == 0)
                  Text(l10n.restaurantNoReviewsYet)
                else
                  ...state.reviews.map(
                    (ReviewEntity r) => UserReviewCard(
                      review: r,
                      branchId: r.branchId.isNotEmpty
                          ? r.branchId
                          : writeBranchId,
                      restaurantId: widget.restaurantId,
                      isMine: myId != null && myId == r.userId,
                    ),
                  ),
              ],
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object error, StackTrace stackTrace) =>
              Center(child: Text(l10n.restaurantReviewsLoadError)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stackTrace) =>
          Center(child: Text(l10n.restaurantBranchesForReviewsError)),
    );
  }
}

class _MenuTab extends ConsumerStatefulWidget {
  const _MenuTab({required this.restaurantId});

  final String restaurantId;

  @override
  ConsumerState<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends ConsumerState<_MenuTab> {
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AsyncValue<List<BranchWithDistance>> branchesAsync = ref.watch(
      restaurantBranchesProvider(widget.restaurantId),
    );
    return branchesAsync.when(
      data: (List<BranchWithDistance> branches) {
        if (branches.isEmpty) {
          return Center(child: Text(l10n.restaurantNoBranchesMenu));
        }
        final String effectiveBranchId =
            (_selectedBranchId != null &&
                branches.any((b) => b.branch.id == _selectedBranchId))
            ? _selectedBranchId!
            : branches.first.branch.id;
        final AsyncValue<List<MenuImageEntity>> imagesAsync = ref.watch(
          menuImagesControllerProvider(effectiveBranchId),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (branches.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: DropdownButtonFormField<String>(
                  value: effectiveBranchId,
                  decoration: InputDecoration(
                    labelText: l10n.adminBranchTitle,
                  ),
                  items: branches
                      .map(
                        (BranchWithDistance b) => DropdownMenuItem<String>(
                          value: b.branch.id,
                          child: Text(
                            b.branch.nameEn.isNotEmpty
                                ? b.branch.nameEn
                                : b.branch.nameAr,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (String? id) {
                    if (id == null) return;
                    setState(() => _selectedBranchId = id);
                  },
                ),
              ),
            Expanded(
              child: imagesAsync.when(
                data: (List<MenuImageEntity> images) {
                  if (images.isEmpty) {
                    return Center(child: Text(l10n.restaurantMenuNotAvailable));
                  }
                  return MenuFlipBookViewer(images: images);
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (Object error, StackTrace stackTrace) =>
                    Center(child: Text(l10n.restaurantMenuImagesLoadError)),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stackTrace) =>
          Center(child: Text(l10n.restaurantBranchesForMenuError)),
    );
  }
}

class _PhotosTab extends ConsumerWidget {
  const _PhotosTab({required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final AsyncValue<List<RestaurantPhotoEntity>> photosAsync = ref.watch(
      restaurantPhotosControllerProvider(restaurantId),
    );
    return photosAsync.when(
      data: (List<RestaurantPhotoEntity> photos) {
        if (photos.isEmpty) {
          return Center(child: Text(l10n.restaurantNoPhotosYet));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, int index) {
            final RestaurantPhotoEntity photo = photos[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => _PhotosFullScreenViewer(
                      photos: photos,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: CachedNetworkImage(
                  imageUrl: photo.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stackTrace) =>
          Center(child: Text(l10n.restaurantPhotosLoadError)),
    );
  }
}

class _PhotosFullScreenViewer extends StatefulWidget {
  const _PhotosFullScreenViewer({
    required this.photos,
    required this.initialIndex,
  });

  final List<RestaurantPhotoEntity> photos;
  final int initialIndex;

  @override
  State<_PhotosFullScreenViewer> createState() =>
      _PhotosFullScreenViewerState();
}

class _PhotosFullScreenViewerState extends State<_PhotosFullScreenViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.tabPhotos,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "${_currentIndex + 1}/${widget.photos.length}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.photos.length,
        itemBuilder: (BuildContext context, int index) {
          final RestaurantPhotoEntity photo = widget.photos[index];
          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: photo.imageUrl,
                fit: BoxFit.contain,
                placeholder: (BuildContext context, String url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (BuildContext context, String url, Object error) =>
                    const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewsSummary extends StatelessWidget {
  const _ReviewsSummary({required this.avgRating, required this.total});

  final double avgRating;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: ReviewsSummaryHeader(avgRating: avgRating, total: total),
    );
  }
}

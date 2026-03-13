import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:menu_2026/features/restaurants/presentation/pages/branch_details_page.dart";
import "package:menu_2026/features/reviews/presentation/controllers/reviews_controller.dart";
import "package:menu_2026/features/reviews/domain/entities/review_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/menu_images_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_photos_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";

class RestaurantDetailsPage extends ConsumerWidget {
  const RestaurantDetailsPage({required this.restaurantId, super.key});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;
    final favorites =
        ref.watch(favoritesControllerProvider).valueOrNull ?? <String>{};

    if (restaurantsAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (restaurantsAsync.hasError) {
      return const Scaffold(
        body: Center(child: Text("Unable to load restaurant")),
      );
    }

    final List<RestaurantEntity> restaurants =
        restaurantsAsync.valueOrNull ?? <RestaurantEntity>[];
    RestaurantEntity? restaurant;
    for (final RestaurantEntity item in restaurants) {
      if (item.id == restaurantId) {
        restaurant = item;
        break;
      }
    }
    if (restaurant == null) {
      return const Scaffold(
        body: Center(child: Text("Restaurant not found")),
      );
    }
    final RestaurantEntity selectedRestaurant = restaurant;

    ref.read(selectedRestaurantIdProvider.notifier).state = restaurantId;
    final branchesAsync = ref.watch(branchesControllerProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(selectedRestaurant.nameEn),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                if (!isLoggedIn) {
                  context.push("/auth/login");
                  return;
                }
                ref
                    .read(favoritesControllerProvider.notifier)
                    .toggle(selectedRestaurant.id);
              },
              icon: Icon(
                favorites.contains(selectedRestaurant.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: "Branches"),
              Tab(text: "Menu"),
              Tab(text: "Photos"),
              Tab(text: "Reviews"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _BranchesTab(
              restaurant: selectedRestaurant,
              branchesAsync: branchesAsync,
            ),
            const _MenuTab(),
            _PhotosTab(restaurantId: selectedRestaurant.id),
            _ReviewsTab(),
          ],
        ),
      ),
    );
  }
}

class _BranchesTab extends StatelessWidget {
  const _BranchesTab({
    required this.restaurant,
    required this.branchesAsync,
  });

  final RestaurantEntity restaurant;
  final AsyncValue<List<BranchWithDistance>> branchesAsync;

  @override
  Widget build(BuildContext context) {
    return branchesAsync.when(
      data: (List<BranchWithDistance> all) {
        final List<BranchWithDistance> branchesForRestaurant = all
            .where((BranchWithDistance b) =>
                b.branch.restaurantId == restaurant.id)
            .toList(growable: false);
        if (branchesForRestaurant.isEmpty) {
          return const Center(child: Text("No branches for this restaurant"));
        }
        final int branchesCount = branchesForRestaurant.length;
        final int totalVotes = branchesForRestaurant.fold(
          0,
          (int sum, BranchWithDistance b) =>
              sum + b.branch.upVotes + b.branch.downVotes,
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _RestaurantSummaryHeader(
              restaurant: restaurant,
              branchesCount: branchesCount,
              totalVotes: totalVotes,
            ),
            const SizedBox(height: 16),
            ...branchesForRestaurant.map(
              (BranchWithDistance b) => _BranchCard(branch: b),
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stack) =>
          const Center(child: Text("Unable to load branches")),
    );
  }
}

class _RestaurantSummaryHeader extends StatelessWidget {
  const _RestaurantSummaryHeader({
    required this.restaurant,
    required this.branchesCount,
    required this.totalVotes,
  });

  final RestaurantEntity restaurant;
  final int branchesCount;
  final int totalVotes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 180,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(
              Icons.restaurant_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  restaurant.nameEn,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.descriptionEn.isEmpty
                      ? "Restaurant"
                      : restaurant.descriptionEn,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _SummaryItem(
                      label: "Branches",
                      value: branchesCount.toString(),
                    ),
                    _SummaryItem(
                      label: "Total Votes",
                      value: totalVotes.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
              branch.branch.nameEn,
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
              "${branch.distanceKm.toStringAsFixed(1)} km away",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;
    return branchesAsync.when(
      data: (List<BranchWithDistance> branches) {
        if (branches.isEmpty) {
          return const Center(child: Text("No branches to review yet"));
        }
        final BranchWithDistance first = branches.first;
        final reviewsAsync =
            ref.watch(reviewsControllerProvider(first.branch.id));
        return reviewsAsync.when(
          data: (ReviewsState state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _ReviewsSummary(summary: state.summary),
                const SizedBox(height: 12),
                _WriteReviewButton(
                  branchId: first.branch.id,
                  isLoggedIn: isLoggedIn,
                ),
                const SizedBox(height: 16),
                if (state.summary.total == 0)
                  const Text("No reviews yet")
                else
                  ...state.reviews.map(
                    (ReviewEntity r) => _ReviewCard(review: r),
                  ),
              ],
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object error, StackTrace stackTrace) =>
              const Center(child: Text("Unable to load reviews")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: Text("Unable to load branches for reviews")),
    );
  }
}

class _MenuTab extends ConsumerWidget {
  const _MenuTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BranchWithDistance>> branchesAsync =
        ref.watch(branchesControllerProvider);
    return branchesAsync.when(
      data: (List<BranchWithDistance> branches) {
        if (branches.isEmpty) {
          return const Center(child: Text("No branches to show menu yet"));
        }
        final BranchWithDistance firstBranch = branches.first;
        final AsyncValue<List<MenuImageEntity>> imagesAsync =
            ref.watch(menuImagesControllerProvider(firstBranch.branch.id));
        return imagesAsync.when(
          data: (List<MenuImageEntity> images) {
            if (images.isEmpty) {
              return const Center(child: Text("Menu not available yet"));
            }
            return _MenuImagesGrid(
              images: images,
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object error, StackTrace stackTrace) =>
              const Center(child: Text("Unable to load menu images")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: Text("Unable to load branches for menu")),
    );
  }
}

class _PhotosTab extends ConsumerWidget {
  const _PhotosTab({required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RestaurantPhotoEntity>> photosAsync =
        ref.watch(restaurantPhotosControllerProvider(restaurantId));
    return photosAsync.when(
      data: (List<RestaurantPhotoEntity> photos) {
        if (photos.isEmpty) {
          return const Center(child: Text("No photos yet"));
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
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: Text("Unable to load photos")),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Photos",
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
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
                errorWidget:
                    (BuildContext context, String url, Object error) =>
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
class _MenuImagesGrid extends StatelessWidget {
  const _MenuImagesGrid({required this.images});

  final List<MenuImageEntity> images;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        final MenuImageEntity image = images[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => _FullScreenMenuViewer(
                  images: images,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

class _FullScreenMenuViewer extends StatefulWidget {
  const _FullScreenMenuViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<MenuImageEntity> images;
  final int initialIndex;

  @override
  State<_FullScreenMenuViewer> createState() => _FullScreenMenuViewerState();
}

class _FullScreenMenuViewerState extends State<_FullScreenMenuViewer> {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Menu",
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "${_currentIndex + 1}/${widget.images.length}",
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
        itemCount: widget.images.length,
        itemBuilder: (BuildContext context, int index) {
          final MenuImageEntity image = widget.images[index];
          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.contain,
                placeholder: (BuildContext context, String url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget:
                    (BuildContext context, String url, Object error) =>
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
  const _ReviewsSummary({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                summary.avgRating.toStringAsFixed(1),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List<Widget>.generate(
                  5,
                  (int index) => Icon(
                    index < summary.avgRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Text(
            "${summary.total} reviews",
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : "?",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.userName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: List<Widget>.generate(
                  5,
                  (int index) => Icon(
                    index < review.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _WriteReviewButton extends ConsumerWidget {
  const _WriteReviewButton({
    required this.branchId,
    required this.isLoggedIn,
  });

  final String branchId;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      onPressed: () {
        if (!isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please log in to write a review."),
            ),
          );
          context.push("/auth/login");
          return;
        }
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (BuildContext context) {
            return _ReviewFormSheet(branchId: branchId);
          },
        );
      },
      icon: const Icon(Icons.rate_review_outlined),
      label: Text(
        isLoggedIn ? "Write a review" : "Login to write a review",
      ),
    );
  }
}

class _ReviewFormSheet extends ConsumerStatefulWidget {
  const _ReviewFormSheet({required this.branchId});

  final String branchId;

  @override
  ConsumerState<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends ConsumerState<_ReviewFormSheet> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    final bool success = await ref
        .read(reviewsControllerProvider(widget.branchId).notifier)
        .submitReview(
          branchId: widget.branchId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Review submitted" : "Failed to submit review",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: mediaQuery.viewInsets.bottom + 16,
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
            "Rate this branch",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List<Widget>.generate(
              5,
              (int index) {
                final int starValue = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = starValue;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Write your review (optional)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? "Submitting..." : "Submit review"),
            ),
          ),
        ],
      ),
    );
  }
}


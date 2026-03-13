import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/profile/presentation/controllers/profile_stats_controller.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/menu_images_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:menu_2026/features/voting/presentation/controllers/voting_controller.dart";
import "package:url_launcher/url_launcher.dart";

class BranchDetailsPage extends ConsumerWidget {
  const BranchDetailsPage({required this.branch, super.key});

  final BranchWithDistance branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, int>> votes =
        ref.watch(votingControllerProvider(branch.branch.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(branch.branch.nameEn),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _AddressCard(address: branch.branch.address),
          const SizedBox(height: 12),
          _MapCard(
            lat: branch.branch.latitude,
            lng: branch.branch.longitude,
            onTap: () => _openMaps(branch),
          ),
          const SizedBox(height: 12),
          _OpeningHoursCard(),
          const SizedBox(height: 12),
          const _FacilitiesSection(),
          const SizedBox(height: 12),
          _VotesSummaryCard(votes: votes),
          const SizedBox(height: 16),
          _NavigateButton(onPressed: () => _openMaps(branch)),
          const SizedBox(height: 16),
          _ViewMenuButton(branchId: branch.branch.id),
          const SizedBox(height: 16),
          _VoteButtons(branchId: branch.branch.id),
        ],
      ),
    );
  }

  Future<void> _openMaps(BranchWithDistance b) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${b.branch.latitude},${b.branch.longitude}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Row(
        children: <Widget>[
          const Icon(Icons.place_outlined, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Address",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(address),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.lat, required this.lng, required this.onTap});

  final double lat;
  final double lng;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 140,
          child: Center(
            child: Icon(
              Icons.location_on_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OpeningHoursCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Row(
        children: <Widget>[
          const Icon(Icons.access_time_rounded, color: Colors.purple),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text("Opening Hours"),
              SizedBox(height: 4),
              Text("11:00 AM - 11:00 PM"),
            ],
          ),
        ],
      ),
    );
  }
}

class _FacilitiesSection extends StatelessWidget {
  const _FacilitiesSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const List<String> defaultFacilities = <String>[
      "Wi-Fi",
      "Parking",
      "Family Section",
      "Delivery",
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Services & Facilities",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: defaultFacilities
              .map(
                (String name) => Chip(
                  label: Text(name),
                  backgroundColor: theme.colorScheme.primary
                      .withValues(alpha: 0.06),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _VotesSummaryCard extends StatelessWidget {
  const _VotesSummaryCard({required this.votes});

  final AsyncValue<Map<String, int>> votes;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: votes.when(
        data: (Map<String, int> v) {
          final int up = v["upVotes"] ?? 0;
          final int down = v["downVotes"] ?? 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Icon(Icons.thumb_up_alt_outlined, color: Colors.green),
                  const SizedBox(height: 4),
                  Text("$up Upvotes"),
                ],
              ),
              Column(
                children: <Widget>[
                  const Icon(Icons.thumb_down_alt_outlined, color: Colors.red),
                  const SizedBox(height: 4),
                  Text("$down Downvotes"),
                ],
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (Object error, StackTrace stack) =>
            const Text("Votes unavailable"),
      ),
    );
  }
}

class _NavigateButton extends StatelessWidget {
  const _NavigateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: const Text("Navigate with Google Maps"),
      ),
    );
  }
}

class _ViewMenuButton extends ConsumerWidget {
  const _ViewMenuButton({required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MenuImageEntity>> imagesAsync =
        ref.watch(menuImagesControllerProvider(branchId));

    return imagesAsync.when(
      data: (List<MenuImageEntity> images) {
        final bool hasMenu = images.isNotEmpty;
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: hasMenu
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            _BranchMenuFullScreenViewer(
                          images: images,
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(hasMenu ? "View Menu" : "Menu not available"),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _BranchMenuFullScreenViewer extends StatefulWidget {
  const _BranchMenuFullScreenViewer({required this.images});

  final List<MenuImageEntity> images;

  @override
  State<_BranchMenuFullScreenViewer> createState() =>
      _BranchMenuFullScreenViewerState();
}

class _BranchMenuFullScreenViewerState
    extends State<_BranchMenuFullScreenViewer> {
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
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

class _VoteButtons extends ConsumerWidget {
  const _VoteButtons({required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final bool isAuth =
        session.valueOrNull?.isAuthenticated ?? false;

    Future<void> handleVote(int value) async {
      if (!isAuth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please log in to vote."),
          ),
        );
        context.go("/auth/login");
        return;
      }
      await ref.read(votingControllerProvider(branchId).notifier).vote(value);
      await ref
          .read(profileStatsControllerProvider.notifier)
          .incrementReviews();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => handleVote(1),
            icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.green),
            label: const Text("Upvote"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => handleVote(-1),
            icon: const Icon(Icons.thumb_down_alt_outlined, color: Colors.red),
            label: const Text("Downvote"),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: child,
    );
  }
}


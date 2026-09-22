import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_photos_controller.dart";

/// Cover image: first restaurant photo, then [logoUrl], then a grey placeholder.
class RestaurantCoverImage extends ConsumerWidget {
  const RestaurantCoverImage({
    super.key,
    required this.restaurantId,
    this.logoUrl = "",
    this.height = 160,
    this.borderRadius,
  });

  final String restaurantId;
  final String logoUrl;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final photosAsync = ref.watch(
      restaurantPhotosControllerProvider(restaurantId),
    );
    final String photoUrl = photosAsync.maybeWhen(
      data: (photos) {
        for (final p in photos) {
          if (p.imageUrl.trim().isNotEmpty) return p.imageUrl.trim();
        }
        return "";
      },
      orElse: () => "",
    );
    final String url = photoUrl.isNotEmpty ? photoUrl : logoUrl.trim();

    Widget child;
    if (url.isEmpty) {
      child = _CoverFallback(theme: theme);
    } else {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        placeholder: (BuildContext context, String _) =>
            _CoverFallback(theme: theme),
        errorWidget: (BuildContext context, String _, Object error) =>
            _CoverFallback(theme: theme),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: borderRadius == null
          ? child
          : ClipRRect(borderRadius: borderRadius!, child: child),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

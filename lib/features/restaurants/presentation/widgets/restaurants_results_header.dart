import "package:flutter/material.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/theme_extensions/brand_gradients.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";

List<RestaurantEntity> filterRestaurantsByQuery(
  List<RestaurantEntity> restaurants,
  String query,
) {
  final String trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return restaurants;
  }
  return restaurants
      .where(
        (RestaurantEntity restaurant) =>
            restaurant.nameEn.toLowerCase().contains(trimmed) ||
            restaurant.nameAr.contains(trimmed) ||
            restaurant.descriptionEn.toLowerCase().contains(trimmed) ||
            restaurant.descriptionAr.contains(trimmed),
      )
      .toList(growable: false);
}

class RestaurantsResultsHeader extends StatelessWidget {
  const RestaurantsResultsHeader({
    required this.title,
    required this.searchController,
    required this.searchFocusNode,
    this.searchHint,
    this.onSearchSubmitted,
    super.key,
  });

  final String title;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String? searchHint;
  final ValueChanged<String>? onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final BrandGradients? gradients =
        Theme.of(context).extension<BrandGradients>();

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 48, bottom: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradients?.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
            textInputAction: TextInputAction.search,
            onSubmitted: onSearchSubmitted,
            decoration: InputDecoration(
              hintText: searchHint ?? l10n.restaurantsSearchInResultsHint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey.shade600,
                size: 22,
              ),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (_, TextEditingValue value, __) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      searchController.clear();
                      onSearchSubmitted?.call("");
                    },
                  );
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

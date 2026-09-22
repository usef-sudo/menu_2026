import "package:flutter_riverpod/flutter_riverpod.dart";

class HomeFilter {
  const HomeFilter({
    this.maxDistanceKm,
    this.openOnly = false,
    this.priceMin,
    this.priceMax,
    this.minRating,
    this.categoryId,
    this.dietaryOptions = const <String>[],
  });

  final double? maxDistanceKm;
  final bool openOnly;
  final int? priceMin;
  final int? priceMax;
  final double? minRating;
  final String? categoryId;
  final List<String> dietaryOptions;

  int get activeCount {
    int n = 0;
    if (maxDistanceKm != null) n++;
    if (openOnly) n++;
    if (priceMin != null || priceMax != null) n++;
    if (minRating != null && minRating! > 0) n++;
    if (categoryId != null && categoryId!.isNotEmpty) n++;
    if (dietaryOptions.isNotEmpty) n++;
    return n;
  }

  HomeFilter copyWith({
    double? maxDistanceKm,
    bool clearMaxDistanceKm = false,
    bool? openOnly,
    int? priceMin,
    bool clearPriceMin = false,
    int? priceMax,
    bool clearPriceMax = false,
    double? minRating,
    bool clearMinRating = false,
    String? categoryId,
    bool clearCategoryId = false,
    List<String>? dietaryOptions,
  }) {
    return HomeFilter(
      maxDistanceKm: clearMaxDistanceKm
          ? null
          : (maxDistanceKm ?? this.maxDistanceKm),
      openOnly: openOnly ?? this.openOnly,
      priceMin: clearPriceMin ? null : (priceMin ?? this.priceMin),
      priceMax: clearPriceMax ? null : (priceMax ?? this.priceMax),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      dietaryOptions: dietaryOptions ?? this.dietaryOptions,
    );
  }
}

final homeFilterProvider = StateProvider<HomeFilter>(
  (Ref ref) => const HomeFilter(),
);

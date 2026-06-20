import "package:flutter/material.dart";
import "package:menu_2026/core/theme/tokens/app_colors.dart";

@immutable
class BrandGradients extends ThemeExtension<BrandGradients> {
  const BrandGradients({
    required this.primary,
    required this.background,
  });

  final LinearGradient primary;
  final LinearGradient background;

  @override
  BrandGradients copyWith({
    LinearGradient? primary,
    LinearGradient? background,
  }) {
    return BrandGradients(
      primary: primary ?? this.primary,
      background: background ?? this.background,
    );
  }

  @override
  ThemeExtension<BrandGradients> lerp(
    covariant ThemeExtension<BrandGradients>? other,
    double t,
  ) {
    if (other is! BrandGradients) {
      return this;
    }
    return BrandGradients(
      primary: LinearGradient.lerp(primary, other.primary, t) ?? primary,
      background:
          LinearGradient.lerp(background, other.background, t) ?? background,
    );
  }

  static const BrandGradients light = BrandGradients(
    primary: LinearGradient(
      colors: AppColors.primaryGradient,
      stops: <double>[0.0, 0.55, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    background: LinearGradient(
      colors: AppColors.backgroundGradient,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const BrandGradients dark = BrandGradients(
    primary: LinearGradient(
      colors: <Color>[
        Color(0xFFFFCA28),
        Color(0xFFFF7043),
        Color(0xFFBF360C),
      ],
      stops: <double>[0.0, 0.55, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    background: LinearGradient(
      colors: AppColors.backgroundGradientDark,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}

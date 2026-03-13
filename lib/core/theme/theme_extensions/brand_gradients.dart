import "package:flutter/material.dart";
import "package:menu_2026/core/theme/tokens/app_colors.dart";

@immutable
class BrandGradients extends ThemeExtension<BrandGradients> {
  const BrandGradients({required this.primary});

  final LinearGradient primary;

  @override
  BrandGradients copyWith({LinearGradient? primary}) {
    return BrandGradients(primary: primary ?? this.primary);
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
    );
  }

  static const BrandGradients light = BrandGradients(
    primary: LinearGradient(
      colors: <Color>[AppColors.primary, AppColors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const BrandGradients dark = BrandGradients(
    primary: LinearGradient(
      colors: <Color>[Color(0xFF8E67F0), Color(0xFFFF61C2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

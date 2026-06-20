import "package:flutter/material.dart";
import "package:menu_2026/core/theme/theme_extensions/brand_gradients.dart";
import "package:menu_2026/core/theme/tokens/app_colors.dart";

class GradientPrimaryButton extends StatelessWidget {
  const GradientPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final BrandGradients? gradients =
        Theme.of(context).extension<BrandGradients>();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradients?.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          shadowColor: Colors.transparent,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

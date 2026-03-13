import "package:flutter/material.dart";
import "package:menu_2026/core/theme/theme_extensions/brand_gradients.dart";

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
    final gradients = Theme.of(context).extension<BrandGradients>();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradients?.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(label),
      ),
    );
  }
}

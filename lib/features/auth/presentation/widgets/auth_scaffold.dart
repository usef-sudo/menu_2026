import "package:flutter/material.dart";
import "package:menu_2026/core/widgets/gradient_primary_button.dart";

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.cardTitle,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    required this.form,
    required this.bottomTextButtonLabel,
    required this.onBottomTextButtonPressed,
    required this.onContinueAsGuest,
    this.footer,
    this.showAdminButton = false,
    this.onAdminPressed,
    super.key,
  });

  final String title;
  final String subtitle;
  final String cardTitle;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final Widget form;
  final String bottomTextButtonLabel;
  final VoidCallback onBottomTextButtonPressed;
  final VoidCallback onContinueAsGuest;
  final Widget? footer;
  final bool showAdminButton;
  final VoidCallback? onAdminPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFFDF2FF), Color(0xFFF8F5FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _AppLogo(title: title, subtitle: subtitle),
                  const SizedBox(height: 32),
                  _AuthCard(
                    title: cardTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        form,
                        const SizedBox(height: 20),
                        GradientPrimaryButton(
                          label: primaryButtonLabel,
                          onPressed: onPrimaryPressed,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: onBottomTextButtonPressed,
                          child: Text(
                            bottomTextButtonLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        if (showAdminButton) ...<Widget>[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: onAdminPressed,
                            child: const Text("Admin login"),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onContinueAsGuest,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text("Continue as Guest"),
                    ),
                  ),
                  if (footer != null) ...<Widget>[
                    const SizedBox(height: 16),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF8A4DFF), Color(0xFFFF3F8E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.restaurant_rounded, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

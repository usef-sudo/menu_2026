import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/features/auth/presentation/controllers/auth_controller.dart";
import "package:menu_2026/features/auth/presentation/widgets/auth_scaffold.dart";
import "package:menu_2026/features/auth/presentation/widgets/auth_text_field.dart";

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
    });

    final bool success = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email: _emailController.text.trim());

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
    });

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.forgotSuccessSnack : l10n.forgotFailSnack,
        ),
      ),
    );
    if (success) {
      context.go("/auth/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      title: l10n.appTitle,
      subtitle: l10n.authDiscoverExplore,
      cardTitle: l10n.forgotCardTitle,
      primaryButtonLabel:
          _submitting ? l10n.forgotSending : l10n.forgotSubmit,
      onPrimaryPressed: _submitting ? () {} : _submit,
      bottomTextButtonLabel: l10n.forgotBackToLogin,
      onBottomTextButtonPressed: () => context.go("/auth/login"),
      onContinueAsGuest: () => context.go("/home"),
      form: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            AuthTextField(
              controller: _emailController,
              label: l10n.emailLabel,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (String? value) =>
                  value == null || value.isEmpty ? l10n.enterEmail : null,
            ),
          ],
        ),
      ),
    );
  }
}

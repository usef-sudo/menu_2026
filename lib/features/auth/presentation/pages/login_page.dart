import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/features/auth/presentation/controllers/auth_controller.dart";
import "package:menu_2026/features/auth/presentation/widgets/auth_scaffold.dart";
import "package:menu_2026/features/auth/presentation/widgets/auth_text_field.dart";

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          requireAdmin: widget.isAdmin,
        );

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
          success ? l10n.loginSuccess : l10n.loginFailed,
        ),
      ),
    );

    if (success) {
      if (widget.isAdmin) {
        context.go("/admin");
      } else {
        context.go("/home");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.isAdmin;
    final l10n = context.l10n;
    return AuthScaffold(
      title: l10n.appTitle,
      subtitle: l10n.authDiscoverExplore,
      cardTitle: isAdmin ? l10n.loginAdminTitle : l10n.loginWelcomeBack,
      primaryButtonLabel:
          _submitting ? l10n.loginLoggingIn : l10n.loginButton,
      onPrimaryPressed: _submitting ? () {} : _submit,
      bottomTextButtonLabel: isAdmin
          ? l10n.userLogin
          : l10n.dontHaveAccount,
      onBottomTextButtonPressed: () {
        if (isAdmin) {
          context.go("/auth/login");
        } else {
          context.go("/auth/register");
        }
      },
      onContinueAsGuest: () => context.go("/home"),
      showAdminButton: !isAdmin,
      onAdminPressed: () => context.go("/admin/login"),
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
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              label: l10n.passwordLabel,
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: (String? value) =>
                  value == null || value.isEmpty ? l10n.enterPassword : null,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go("/auth/forgot"),
                child: Text(l10n.forgotPassword),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

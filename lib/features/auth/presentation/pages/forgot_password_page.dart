import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "If an account exists, you'll receive an email shortly."
              : "Could not request password reset.",
        ),
      ),
    );
    if (success) {
      context.go("/auth/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: "Menu",
      subtitle: "Discover & Explore",
      cardTitle: "Reset Password",
      primaryButtonLabel: _submitting ? "Sending..." : "Send reset link",
      onPrimaryPressed: _submitting ? () {} : _submit,
      bottomTextButtonLabel: "Back to login",
      onBottomTextButtonPressed: () => context.go("/auth/login"),
      onContinueAsGuest: () => context.go("/home"),
      form: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            AuthTextField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Enter your email" : null,
            ),
          ],
        ),
      ),
    );
  }
}

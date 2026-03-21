import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Login successful" : "Login failed. Check credentials.",
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
    return AuthScaffold(
      title: "Menu",
      subtitle: "Discover & Explore",
      cardTitle: isAdmin ? "Admin Login" : "Welcome Back",
      primaryButtonLabel: _submitting ? "Logging In..." : "Login",
      onPrimaryPressed: _submitting ? () {} : _submit,
      bottomTextButtonLabel: isAdmin
          ? "User login"
          : "Don't have an account? Sign Up",
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
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Enter your email" : null,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              label: "Password",
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Enter your password" : null,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go("/auth/forgot"),
                child: const Text("Forgot password?"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

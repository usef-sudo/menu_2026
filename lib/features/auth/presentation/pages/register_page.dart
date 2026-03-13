import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/features/auth/presentation/controllers/auth_controller.dart";
import "package:menu_2026/features/auth/presentation/widgets/auth_scaffold.dart";
import "package:menu_2026/features/auth/presentation/widgets/auth_text_field.dart";

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedGender;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
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
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          birthDate: _birthDateController.text.trim(),
          gender: _selectedGender!,
          phoneNumber: _phoneController.text.trim(),
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
          success ? "Account created. You can now log in." : "Sign up failed.",
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
      cardTitle: "Create Account",
      primaryButtonLabel: _submitting ? "Signing Up..." : "Sign Up",
      onPrimaryPressed: _submitting ? () {} : _submit,
      bottomTextButtonLabel: "Already have an account? Login",
      onBottomTextButtonPressed: () => context.go("/auth/login"),
      onContinueAsGuest: () => context.go("/home"),
      showAdminButton: true,
      onAdminPressed: () => context.go("/admin/login"),
      form: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            AuthTextField(
              controller: _nameController,
              label: "Full Name",
              icon: Icons.person_outline_rounded,
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Enter your name" : null,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _birthDateController,
              label: "Birth Date",
              icon: Icons.cake_outlined,
              readOnly: true,
              onTap: () async {
                final DateTime now = DateTime.now();
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(now.year - 18, now.month, now.day),
                  firstDate: DateTime(1900),
                  lastDate: now,
                );
                if (picked != null) {
                  final String formatted =
                      "${picked.year.toString().padLeft(4, "0")}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}";
                  _birthDateController.text = formatted;
                }
              },
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Select your birth date" : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: "Gender",
                prefixIcon: Icon(Icons.wc_outlined),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: "male",
                  child: Text("Male"),
                ),
                DropdownMenuItem<String>(
                  value: "female",
                  child: Text("Female"),
                ),
                DropdownMenuItem<String>(
                  value: "other",
                  child: Text("Other"),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Select your gender" : null,
            ),
            const SizedBox(height: 12),
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
              controller: _phoneController,
              label: "Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (String? value) =>
                  value == null || value.isEmpty ? "Enter your phone number" : null,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              label: "Password",
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: (String? value) =>
                  value == null || value.length < 6 ? "Min 6 characters" : null,
            ),
          ],
        ),
      ),
    );
  }
}

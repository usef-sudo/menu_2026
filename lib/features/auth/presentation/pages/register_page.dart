import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
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

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.registerSuccess : l10n.registerFailed,
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
      cardTitle: l10n.registerTitle,
      primaryButtonLabel:
          _submitting ? l10n.registerSigningUp : l10n.registerButton,
      onPrimaryPressed: _submitting ? () {} : _submit,
      bottomTextButtonLabel: l10n.registerHaveAccount,
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
              label: l10n.registerName,
              icon: Icons.person_outline_rounded,
              validator: (String? value) =>
                  value == null || value.isEmpty ? l10n.enterName : null,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _birthDateController,
              label: l10n.registerBirthDateLabel,
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
                  value == null || value.isEmpty
                      ? l10n.registerSelectBirthDate
                      : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: l10n.registerGender,
                prefixIcon: const Icon(Icons.wc_outlined),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: "male",
                  child: Text(l10n.genderMale),
                ),
                DropdownMenuItem<String>(
                  value: "female",
                  child: Text(l10n.genderFemale),
                ),
                DropdownMenuItem<String>(
                  value: "other",
                  child: Text(l10n.genderOther),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (String? value) =>
                  value == null || value.isEmpty
                      ? l10n.registerSelectGender
                      : null,
            ),
            const SizedBox(height: 12),
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
              controller: _phoneController,
              label: l10n.registerPhoneNumberLabel,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (String? value) =>
                  value == null || value.isEmpty
                      ? l10n.registerEnterPhone
                      : null,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _passwordController,
              label: l10n.passwordLabel,
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: (String? value) =>
                  value == null || value.length < 6
                      ? l10n.registerPasswordMin
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

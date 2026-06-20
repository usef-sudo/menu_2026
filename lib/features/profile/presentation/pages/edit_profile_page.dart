import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/widgets/gradient_primary_button.dart";
import "package:menu_2026/features/auth/presentation/widgets/auth_text_field.dart";
import "package:menu_2026/features/profile/data/user_profile_dto.dart";
import "package:menu_2026/features/profile/presentation/controllers/user_profile_controller.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({required this.profile, super.key});

  final UserProfileDto profile;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _phoneController;
  String? _selectedGender;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name ?? "");
    _emailController = TextEditingController(text: widget.profile.email);
    _birthDateController =
        TextEditingController(text: widget.profile.birthDate ?? "");
    _phoneController =
        TextEditingController(text: widget.profile.phoneNumber ?? "");
    _selectedGender = widget.profile.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);

    final bool success = await ref
        .read(userProfileControllerProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          birthDate: _birthDateController.text.trim(),
          gender: _selectedGender!,
          phoneNumber: _phoneController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.profileUpdateSuccess : l10n.profileUpdateFailed,
        ),
      ),
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileEditProfile),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  controller: _emailController,
                  label: l10n.emailLabel,
                  icon: Icons.email_outlined,
                  readOnly: true,
                  helperText: l10n.profileEmailReadOnly,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _birthDateController,
                  label: l10n.registerBirthDateLabel,
                  icon: Icons.cake_outlined,
                  readOnly: true,
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime initial = _parseBirthDate() ??
                        DateTime(now.year - 18, now.month, now.day);
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1900),
                      lastDate: now,
                    );
                    if (picked != null) {
                      _birthDateController.text =
                          "${picked.year.toString().padLeft(4, "0")}-${picked.month.toString().padLeft(2, "0")}-${picked.day.toString().padLeft(2, "0")}";
                    }
                  },
                  validator: (String? value) =>
                      value == null || value.isEmpty
                          ? l10n.registerSelectBirthDate
                          : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
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
                    setState(() => _selectedGender = value);
                  },
                  validator: (String? value) =>
                      value == null || value.isEmpty
                          ? l10n.registerSelectGender
                          : null,
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
                const SizedBox(height: 24),
                GradientPrimaryButton(
                  label: _submitting
                      ? l10n.profileSaveChanges
                      : l10n.profileSaveChanges,
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseBirthDate() {
    final String raw = _birthDateController.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}

String genderLabel(AppLocalizations l10n, String? gender) {
  switch (gender?.toLowerCase()) {
    case "male":
      return l10n.genderMale;
    case "female":
      return l10n.genderFemale;
    case "other":
      return l10n.genderOther;
    default:
      return gender ?? "—";
  }
}

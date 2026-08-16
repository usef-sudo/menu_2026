import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_editor_header.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_form_validators.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

/// Create restaurant (names + optional contact & descriptions). Matches `POST /api/restaurants`.
Future<RestaurantDto?> showAdminRestaurantEditor({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
}) async {
  return showModalBottomSheet<RestaurantDto?>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _AdminRestaurantEditorBody(l10n: l10n, api: api),
  );
}

class _AdminRestaurantEditorBody extends StatefulWidget {
  const _AdminRestaurantEditorBody({required this.l10n, required this.api});

  final AppLocalizations l10n;
  final MenuApi api;

  @override
  State<_AdminRestaurantEditorBody> createState() =>
      _AdminRestaurantEditorBodyState();
}

class _AdminRestaurantEditorBodyState extends State<_AdminRestaurantEditorBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _descEn = TextEditingController();
  final TextEditingController _descAr = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _logoUrl = TextEditingController();
  final TextEditingController _websiteUrl = TextEditingController();
  final TextEditingController _instagramUrl = TextEditingController();
  final TextEditingController _facebookUrl = TextEditingController();
  final TextEditingController _talabatUrl = TextEditingController();
  final TextEditingController _careemUrl = TextEditingController();
  bool _submitting = false;
  bool _uploadingLogo = false;

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _descEn.dispose();
    _descAr.dispose();
    _phone.dispose();
    _logoUrl.dispose();
    _websiteUrl.dispose();
    _instagramUrl.dispose();
    _facebookUrl.dispose();
    _talabatUrl.dispose();
    _careemUrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() => _uploadingLogo = true);
    try {
      final List<int> bytes = await file.readAsBytes();
      final String url = await widget.api.uploadFile(
        imageBytes: bytes,
        filename: file.name,
      );
      if (!mounted) return;
      setState(() {
        _logoUrl.text = url;
        _uploadingLogo = false;
      });
    } on DioException catch (err) {
      if (!mounted) return;
      setState(() => _uploadingLogo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(err))),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _uploadingLogo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final String nameEn = _nameEn.text.trim();
    final String nameAr = _nameAr.text.trim();
    final String dEn = _descEn.text.trim();
    final String dAr = _descAr.text.trim();
    final String phone = _phone.text.trim();
    final String logo = _logoUrl.text.trim();
    final String website = _websiteUrl.text.trim();
    final String instagram = _instagramUrl.text.trim();
    final String facebook = _facebookUrl.text.trim();
    final String talabat = _talabatUrl.text.trim();
    final String careem = _careemUrl.text.trim();

    try {
      final RestaurantDto r = await widget.api.adminCreateRestaurant(
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn: dEn.isEmpty ? null : dEn,
        descriptionAr: dAr.isEmpty ? null : dAr,
        phone: phone.isEmpty ? null : phone,
        logoUrl: logo.isEmpty ? null : logo,
        websiteUrl: website.isEmpty ? null : website,
        instagramUrl: instagram.isEmpty ? null : instagram,
        facebookUrl: facebook.isEmpty ? null : facebook,
        talabatUrl: talabat.isEmpty ? null : talabat,
        careemUrl: careem.isEmpty ? null : careem,
      );
      if (mounted) Navigator.of(context).pop(r);
    } on DioException catch (err) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(dioErrorMessage(err))),
        );
      }
    } catch (err) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AdminEditorHeader(
                title: l10n.adminNewRestaurant,
                submitting: _submitting,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameEn,
                decoration: InputDecoration(labelText: l10n.adminNameEnglish),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxName,
                validator: (String? v) => AdminFormValidators.name(v, l10n),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameAr,
                decoration: InputDecoration(labelText: l10n.adminNameArabicLabel),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxName,
                validator: (String? v) => AdminFormValidators.name(v, l10n),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descEn,
                decoration: InputDecoration(labelText: l10n.adminLabelDescEn),
                textInputAction: TextInputAction.next,
                minLines: 1,
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descAr,
                decoration: InputDecoration(labelText: l10n.adminLabelDescAr),
                textInputAction: TextInputAction.next,
                minLines: 1,
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.adminLabelPhone),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxPhone,
                validator: (String? v) =>
                    AdminFormValidators.optionalPhone(v, l10n),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: (_submitting || _uploadingLogo) ? null : _pickLogo,
                icon: _uploadingLogo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(
                  _logoUrl.text.trim().isEmpty
                      ? "Upload logo image"
                      : "Replace logo image",
                ),
              ),
              if (_logoUrl.text.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  _logoUrl.text.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              TextFormField(
                controller: _logoUrl,
                decoration: InputDecoration(
                  labelText: l10n.adminLabelLogoUrl,
                  hintText: "https:// or upload above",
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    AdminFormValidators.optionalLogoUrl(v, l10n),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _websiteUrl,
                decoration: const InputDecoration(labelText: "Website URL"),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _instagramUrl,
                decoration: const InputDecoration(labelText: "Instagram URL"),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _facebookUrl,
                decoration: const InputDecoration(labelText: "Facebook URL"),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _talabatUrl,
                decoration: const InputDecoration(labelText: "Talabat URL"),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _careemUrl,
                decoration: const InputDecoration(labelText: "Careem URL"),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _submitting ? null : (_) => _submit(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: (_submitting || _uploadingLogo) ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      )
                    : Text(l10n.commonCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

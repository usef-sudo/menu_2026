import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:image_picker/image_picker.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/categories/data/models/category_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

const int _kMaxCategoryNameLength = 255;

/// Modal bottom sheet to create or update a category (aligned with POST/PUT `/api/categories`).
Future<bool> showAdminCategoryEditor({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
  CategoryDto? existing,
}) async {
  final bool? saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _AdminCategoryEditorBody(
      l10n: l10n,
      api: api,
      existing: existing,
    ),
  );
  return saved == true;
}

class _AdminCategoryEditorBody extends StatefulWidget {
  const _AdminCategoryEditorBody({
    required this.l10n,
    required this.api,
    this.existing,
  });

  final AppLocalizations l10n;
  final MenuApi api;
  final CategoryDto? existing;

  @override
  State<_AdminCategoryEditorBody> createState() => _AdminCategoryEditorBodyState();
}

class _AdminCategoryEditorBodyState extends State<_AdminCategoryEditorBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameEn;
  late final TextEditingController _nameAr;
  late final TextEditingController _descEn;
  late final TextEditingController _descAr;
  late final TextEditingController _icon;
  late final TextEditingController _displayOrder;
  bool _isActive = true;
  bool _submitting = false;
  List<int>? _pickedImageBytes;
  String? _pickedFilename;

  @override
  void initState() {
    super.initState();
    final CategoryDto? e = widget.existing;
    _nameEn = TextEditingController(text: e?.nameEn ?? "");
    _nameAr = TextEditingController(text: e?.nameAr ?? "");
    _descEn = TextEditingController(text: e?.descriptionEn ?? "");
    _descAr = TextEditingController(text: e?.descriptionAr ?? "");
    _icon = TextEditingController(text: e?.icon ?? "");
    _displayOrder = TextEditingController(
      text: e != null && e.displayOrder != 0 ? "${e.displayOrder}" : "",
    );
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _descEn.dispose();
    _descAr.dispose();
    _icon.dispose();
    _displayOrder.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final String t = value?.trim() ?? "";
    if (t.isEmpty) {
      return widget.l10n.adminCategoryValidationNameRequired;
    }
    if (t.length > _kMaxCategoryNameLength) {
      return widget.l10n.adminCategoryValidationNameMax;
    }
    return null;
  }

  int _parseDisplayOrder() {
    final String t = _displayOrder.text.trim();
    if (t.isEmpty) {
      return widget.existing?.displayOrder ?? 0;
    }
    return int.tryParse(t) ?? 0;
  }

  String? _validateDisplayOrder(String? value) {
    final String t = value?.trim() ?? "";
    if (t.isEmpty) return null;
    if (int.tryParse(t) == null) {
      return widget.l10n.adminCategoryValidationDisplayOrder;
    }
    return null;
  }

  Future<void> _pickImage() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    final List<int> bytes = await file.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _pickedFilename = file.name;
    });
  }

  void _clearPickedImage() {
    setState(() {
      _pickedImageBytes = null;
      _pickedFilename = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final String nameEn = _nameEn.text.trim();
    final String nameAr = _nameAr.text.trim();
    final String descEnTrimmed = _descEn.text.trim();
    final String descArTrimmed = _descAr.text.trim();
    final String? dEnCreate =
        descEnTrimmed.isEmpty ? null : descEnTrimmed;
    final String? dArCreate =
        descArTrimmed.isEmpty ? null : descArTrimmed;
    final String? iconCreate =
        _icon.text.trim().isEmpty ? null : _icon.text.trim();
    final String iconUpdate = _icon.text.trim();
    final int order = _parseDisplayOrder();

    try {
      final CategoryDto? e = widget.existing;
      if (e == null) {
        if (_pickedImageBytes != null && _pickedImageBytes!.isNotEmpty) {
          await widget.api.adminCreateCategoryWithImage(
            nameEn: nameEn,
            nameAr: nameAr,
            imageBytes: _pickedImageBytes!,
            filename: _pickedFilename ?? "image.jpg",
            descriptionEn: dEnCreate,
            descriptionAr: dArCreate,
            icon: iconCreate,
            displayOrder: order,
            isActive: _isActive,
          );
        } else {
          await widget.api.adminCreateCategory(
            nameEn: nameEn,
            nameAr: nameAr,
            descriptionEn: dEnCreate,
            descriptionAr: dArCreate,
            icon: iconCreate,
            displayOrder: order,
            isActive: _isActive,
          );
        }
      } else {
        if (_pickedImageBytes != null && _pickedImageBytes!.isNotEmpty) {
          await widget.api.adminUpdateCategoryWithImage(
            e.id,
            nameEn: nameEn,
            nameAr: nameAr,
            descriptionEn: descEnTrimmed,
            descriptionAr: descArTrimmed,
            icon: iconUpdate,
            displayOrder: order,
            isActive: _isActive,
            imageBytes: _pickedImageBytes,
            imageFilename: _pickedFilename,
          );
        } else {
          await widget.api.adminUpdateCategory(
            e.id,
            nameEn: nameEn,
            nameAr: nameAr,
            descriptionEn: descEnTrimmed,
            descriptionAr: descArTrimmed,
            icon: iconUpdate,
            displayOrder: order,
            isActive: _isActive,
          );
        }
      }
      if (mounted) Navigator.of(context).pop(true);
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
    final CategoryDto? e = widget.existing;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final ThemeData theme = Theme.of(context);

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
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      e == null ? l10n.adminNewCategory : l10n.adminEditCategory,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameEn,
                decoration: InputDecoration(labelText: l10n.adminNameEnglish),
                textInputAction: TextInputAction.next,
                maxLength: _kMaxCategoryNameLength,
                validator: _validateName,
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nameAr,
                decoration: InputDecoration(labelText: l10n.adminNameArabicLabel),
                textInputAction: TextInputAction.next,
                maxLength: _kMaxCategoryNameLength,
                validator: _validateName,
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
                controller: _icon,
                decoration: InputDecoration(
                  labelText: l10n.adminIconOptional,
                  hintText: l10n.adminCategoryIconHint,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _displayOrder,
                decoration: InputDecoration(
                  labelText: l10n.adminCategoryDisplayOrderHint,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r"^-?\d*")),
                ],
                validator: _validateDisplayOrder,
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminCategoryActiveLabel),
                subtitle: Text(
                  l10n.adminCategoryActiveSubtitle,
                  style: theme.textTheme.bodySmall,
                ),
                value: _isActive,
                onChanged: _submitting
                    ? null
                    : (bool v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.adminCategoryCoverSectionTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (e != null && e.imageUrl.isNotEmpty && _pickedImageBytes == null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    e.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              if (_pickedImageBytes != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        Uint8List.fromList(_pickedImageBytes!),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: _submitting ? null : _clearPickedImage,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _submitting ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.commonChooseImage),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      )
                    : Text(l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

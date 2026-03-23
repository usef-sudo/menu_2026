import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/facilities/data/models/facility_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

const int _kMaxFacilityNameLength = 255;
const int _kMaxFacilityIconLength = 255;

Future<bool> showAdminFacilityEditor({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
  FacilityDto? existing,
}) async {
  final bool? saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _AdminFacilityEditorBody(
      l10n: l10n,
      api: api,
      existing: existing,
    ),
  );
  return saved == true;
}

class _AdminFacilityEditorBody extends StatefulWidget {
  const _AdminFacilityEditorBody({
    required this.l10n,
    required this.api,
    this.existing,
  });

  final AppLocalizations l10n;
  final MenuApi api;
  final FacilityDto? existing;

  @override
  State<_AdminFacilityEditorBody> createState() =>
      _AdminFacilityEditorBodyState();
}

class _AdminFacilityEditorBodyState extends State<_AdminFacilityEditorBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameEn;
  late final TextEditingController _nameAr;
  late final TextEditingController _icon;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final FacilityDto? e = widget.existing;
    _nameEn = TextEditingController(text: e?.nameEn ?? "");
    _nameAr = TextEditingController(text: e?.nameAr ?? "");
    _icon = TextEditingController(text: e?.icon ?? "");
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _icon.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final String t = value?.trim() ?? "";
    if (t.isEmpty) {
      return widget.l10n.adminCategoryValidationNameRequired;
    }
    if (t.length > _kMaxFacilityNameLength) {
      return widget.l10n.adminCategoryValidationNameMax;
    }
    return null;
  }

  String? _validateIcon(String? value) {
    final String t = value?.trim() ?? "";
    if (t.length > _kMaxFacilityIconLength) {
      return widget.l10n.adminFacilityValidationIconMax;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final String nameEn = _nameEn.text.trim();
    final String nameAr = _nameAr.text.trim();
    final String icon = _icon.text.trim();

    try {
      final FacilityDto? e = widget.existing;
      if (e == null) {
        await widget.api.adminCreateFacility(
          nameEn: nameEn,
          nameAr: nameAr,
          icon: icon.isEmpty ? null : icon,
        );
      } else {
        await widget.api.adminUpdateFacility(
          e.id,
          nameEn: nameEn,
          nameAr: nameAr,
          icon: icon,
        );
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
    final FacilityDto? e = widget.existing;
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
                      e == null ? l10n.adminNewFacility : l10n.adminEditFacility,
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
                maxLength: _kMaxFacilityNameLength,
                validator: _validateName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameAr,
                decoration: InputDecoration(labelText: l10n.adminNameArabicLabel),
                textInputAction: TextInputAction.next,
                maxLength: _kMaxFacilityNameLength,
                validator: _validateName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _icon,
                decoration: InputDecoration(
                  labelText: l10n.adminIconOptional,
                  hintText: l10n.adminCategoryIconHint,
                ),
                textInputAction: TextInputAction.done,
                maxLength: _kMaxFacilityIconLength,
                validator: _validateIcon,
                onFieldSubmitted: _submitting ? null : (_) => _submit(),
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

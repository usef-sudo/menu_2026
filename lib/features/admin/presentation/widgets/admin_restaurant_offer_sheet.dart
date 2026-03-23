import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_editor_header.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_form_validators.dart";
import "package:menu_2026/l10n/app_localizations.dart";

final DateFormat _offerDateFmt = DateFormat("y-MM-dd");

/// Create offer for a restaurant (`POST /api/offers`). Dates default like the API (today → +30 days).
Future<bool> showAdminRestaurantOfferSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
  required String restaurantId,
}) async {
  final bool? ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _AdminRestaurantOfferBody(
      l10n: l10n,
      api: api,
      restaurantId: restaurantId,
    ),
  );
  return ok == true;
}

class _AdminRestaurantOfferBody extends StatefulWidget {
  const _AdminRestaurantOfferBody({
    required this.l10n,
    required this.api,
    required this.restaurantId,
  });

  final AppLocalizations l10n;
  final MenuApi api;
  final String restaurantId;

  @override
  State<_AdminRestaurantOfferBody> createState() =>
      _AdminRestaurantOfferBodyState();
}

class _AdminRestaurantOfferBodyState extends State<_AdminRestaurantOfferBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _imageUrl = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEnd() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.api.adminCreateOffer(
        restaurantId: widget.restaurantId,
        title: _title.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
        startDate: _offerDateFmt.format(_startDate),
        endDate: _offerDateFmt.format(_endDate),
      );
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
                title: l10n.adminNewOffer,
                submitting: _submitting,
                onClose: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: l10n.adminOfferTitlePrompt,
                ),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxName,
                validator: (String? v) => AdminFormValidators.name(v, l10n),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(
                  labelText: l10n.adminOfferDescriptionLabel,
                ),
                textInputAction: TextInputAction.next,
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageUrl,
                decoration: InputDecoration(
                  labelText: l10n.adminOfferImageUrlLabel,
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    AdminFormValidators.optionalLogoUrl(v, l10n),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminOfferStartDate),
                subtitle: Text(_offerDateFmt.format(_startDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _submitting ? null : _pickStart,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminOfferEndDate),
                subtitle: Text(_offerDateFmt.format(_endDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _submitting ? null : _pickEnd,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submitting ? null : _submit,
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

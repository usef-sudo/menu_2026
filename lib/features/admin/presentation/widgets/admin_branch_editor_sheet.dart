import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/data/area_dto.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_editor_header.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_form_validators.dart";
import "package:menu_2026/features/branches/data/models/branch_dto.dart";
import "package:menu_2026/features/facilities/data/models/facility_dto.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

/// Create branch for a restaurant. Matches `POST /api/branches` + optional facility assign.
Future<BranchDto?> showAdminBranchEditor({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
  required List<RestaurantDto> restaurants,
  required List<AreaDto> areas,
  required List<FacilityDto> facilities,
  String? initialRestaurantId,
  bool lockRestaurantId = false,
}) async {
  if (restaurants.isEmpty) return null;
  return showModalBottomSheet<BranchDto?>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _AdminBranchEditorBody(
      l10n: l10n,
      api: api,
      restaurants: restaurants,
      areas: areas,
      facilities: facilities,
      initialRestaurantId: initialRestaurantId,
      lockRestaurantId: lockRestaurantId,
    ),
  );
}

class _AdminBranchEditorBody extends StatefulWidget {
  const _AdminBranchEditorBody({
    required this.l10n,
    required this.api,
    required this.restaurants,
    required this.areas,
    required this.facilities,
    this.initialRestaurantId,
    this.lockRestaurantId = false,
  });

  final AppLocalizations l10n;
  final MenuApi api;
  final List<RestaurantDto> restaurants;
  final List<AreaDto> areas;
  final List<FacilityDto> facilities;
  final String? initialRestaurantId;
  final bool lockRestaurantId;

  @override
  State<_AdminBranchEditorBody> createState() => _AdminBranchEditorBodyState();
}

class _AdminBranchEditorBodyState extends State<_AdminBranchEditorBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String? _restaurantId;
  String? _areaId;
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _lat = TextEditingController();
  final TextEditingController _lng = TextEditingController();
  final TextEditingController _cost = TextEditingController(text: "1");
  final TextEditingController _open = TextEditingController();
  final TextEditingController _close = TextEditingController();
  bool _isOpen = true;
  final Set<String> _facilityIds = <String>{};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _restaurantId = widget.initialRestaurantId;
    if (_restaurantId != null &&
        !widget.restaurants.any((RestaurantDto r) => r.id == _restaurantId)) {
      _restaurantId = widget.restaurants.first.id;
    }
    _restaurantId ??= widget.restaurants.first.id;
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _address.dispose();
    _lat.dispose();
    _lng.dispose();
    _cost.dispose();
    _open.dispose();
    _close.dispose();
    super.dispose();
  }

  String? _validateRestaurant(String? value) {
    if (widget.lockRestaurantId) return null;
    if (value == null || value.isEmpty) {
      return widget.l10n.adminValidationSelectRestaurant;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final String? rid = _restaurantId;
    if (rid == null || rid.isEmpty) return;

    setState(() => _submitting = true);
    final String nameEn = _nameEn.text.trim();
    final String nameAr = _nameAr.text.trim();
    final String address = _address.text.trim();
    final String lat = _lat.text.trim();
    final String lng = _lng.text.trim();
    final String costRaw = _cost.text.trim();
    final int costLevel = int.tryParse(costRaw.isEmpty ? "1" : costRaw) ?? 1;
    final String openT = _open.text.trim();
    final String closeT = _close.text.trim();

    try {
      final BranchDto b = await widget.api.adminCreateBranch(
        restaurantId: rid,
        nameEn: nameEn,
        nameAr: nameAr,
        areaId: _areaId,
        address: address.isEmpty ? null : address,
        latitude: lat.isEmpty ? null : lat,
        longitude: lng.isEmpty ? null : lng,
        costLevel: costLevel,
        isOpen: _isOpen ? 1 : 0,
        openTime: openT.isEmpty ? null : openT,
        closeTime: closeT.isEmpty ? null : closeT,
      );
      if (_facilityIds.isNotEmpty) {
        await widget.api.adminAssignBranchFacilities(
          b.id,
          _facilityIds.toList(growable: false),
        );
      }
      if (mounted) Navigator.of(context).pop(b);
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
    final ThemeData theme = Theme.of(context);
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
                title: l10n.adminNewBranch,
                submitting: _submitting,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.adminBranchSectionDetails,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (widget.lockRestaurantId)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.adminRestaurantPickerTitle,
                  ),
                  child: Text(
                    widget.restaurants
                        .firstWhere((RestaurantDto r) => r.id == _restaurantId)
                        .nameEn,
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _restaurantId,
                  decoration: InputDecoration(
                    labelText: l10n.adminRestaurantPickerTitle,
                  ),
                  items: widget.restaurants
                      .map(
                        (RestaurantDto r) => DropdownMenuItem<String>(
                          value: r.id,
                          child: Text(r.nameEn),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _submitting
                      ? null
                      : (String? v) => setState(() => _restaurantId = v),
                  validator: _validateRestaurant,
                ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _areaId,
                decoration: InputDecoration(labelText: l10n.adminLabelArea),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.commonNone),
                  ),
                  ...widget.areas.map(
                    (AreaDto a) => DropdownMenuItem<String?>(
                      value: a.id,
                      child: Text(a.nameEn),
                    ),
                  ),
                ],
                onChanged: _submitting
                    ? null
                    : (String? v) => setState(() => _areaId = v),
              ),
              TextFormField(
                controller: _nameEn,
                decoration: InputDecoration(labelText: l10n.adminBranchNameEn),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxName,
                validator: (String? v) => AdminFormValidators.name(v, l10n),
              ),
              TextFormField(
                controller: _nameAr,
                decoration: InputDecoration(labelText: l10n.adminBranchNameAr),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxName,
                validator: (String? v) => AdminFormValidators.name(v, l10n),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.adminBranchSectionLocation,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.adminLabelAddress),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxAddress,
                validator: (String? v) =>
                    AdminFormValidators.optionalAddress(v, l10n),
              ),
              TextFormField(
                controller: _lat,
                decoration: InputDecoration(labelText: l10n.adminLabelLatitude),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    AdminFormValidators.optionalCoordinate(v, l10n),
              ),
              TextFormField(
                controller: _lng,
                decoration: InputDecoration(
                  labelText: l10n.adminLabelLongitude,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    AdminFormValidators.optionalCoordinate(v, l10n),
              ),
              TextFormField(
                controller: _cost,
                decoration: InputDecoration(
                  labelText: l10n.adminLabelCostLevel,
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (String? v) =>
                    AdminFormValidators.costLevelText(v, l10n),
              ),
              TextFormField(
                controller: _open,
                decoration: InputDecoration(
                  labelText: l10n.adminLabelOpenTime,
                ),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxTime,
                validator: (String? v) =>
                    AdminFormValidators.optionalTime(v, l10n),
              ),
              TextFormField(
                controller: _close,
                decoration: InputDecoration(
                  labelText: l10n.adminLabelCloseTime,
                ),
                textInputAction: TextInputAction.next,
                maxLength: AdminFormValidators.maxTime,
                validator: (String? v) =>
                    AdminFormValidators.optionalTime(v, l10n),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminBranchIsOpenLabel),
                value: _isOpen,
                onChanged: _submitting
                    ? null
                    : (bool v) => setState(() => _isOpen = v),
              ),
              if (widget.facilities.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  l10n.adminDrawerFacilities,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  l10n.adminBranchFacilitiesHint,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.facilities.map((FacilityDto f) {
                    final bool sel = _facilityIds.contains(f.id);
                    return FilterChip(
                      label: Text(f.nameEn),
                      selected: sel,
                      onSelected: _submitting
                          ? null
                          : (bool v) => setState(() {
                                if (v) {
                                  _facilityIds.add(f.id);
                                } else {
                                  _facilityIds.remove(f.id);
                                }
                              }),
                    );
                  }).toList(growable: false),
                ),
              ],
              const SizedBox(height: 20),
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

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/data/area_dto.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_editor_header.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

Future<bool> showAdminBulkAreasSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
}) async {
  final bool? ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _BulkAreasBody(l10n: l10n, api: api),
  );
  return ok == true;
}

Future<bool> showAdminBulkRestaurantsSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
}) async {
  final bool? ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _BulkRestaurantsBody(l10n: l10n, api: api),
  );
  return ok == true;
}

Future<bool> showAdminBulkBranchesSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
  required List<RestaurantDto> restaurants,
  required List<AreaDto> areas,
  String? initialRestaurantId,
}) async {
  if (restaurants.isEmpty) return false;
  final bool? ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _BulkBranchesBody(
      l10n: l10n,
      api: api,
      restaurants: restaurants,
      areas: areas,
      initialRestaurantId: initialRestaurantId,
    ),
  );
  return ok == true;
}

class _NamePairRow {
  _NamePairRow()
      : nameEn = TextEditingController(),
        nameAr = TextEditingController();

  final TextEditingController nameEn;
  final TextEditingController nameAr;

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}

class _BulkAreasBody extends StatefulWidget {
  const _BulkAreasBody({required this.l10n, required this.api});

  final AppLocalizations l10n;
  final MenuApi api;

  @override
  State<_BulkAreasBody> createState() => _BulkAreasBodyState();
}

class _BulkAreasBodyState extends State<_BulkAreasBody> {
  final List<_NamePairRow> _rows = <_NamePairRow>[_NamePairRow()];
  bool _submitting = false;

  @override
  void dispose() {
    for (final _NamePairRow r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final List<Map<String, String>> items = <Map<String, String>>[];
    for (final _NamePairRow r in _rows) {
      final String en = r.nameEn.text.trim();
      final String ar = r.nameAr.text.trim();
      if (en.isEmpty && ar.isEmpty) continue;
      if (en.isEmpty || ar.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Each filled row needs English and Arabic names"),
          ),
        );
        return;
      }
      items.add(<String, String>{"nameEn": en, "nameAr": ar});
    }
    if (items.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final Map<String, dynamic> result =
          await widget.api.adminBulkCreateAreas(items);
      if (!mounted) return;
      final int created = int.tryParse(result["created"]?.toString() ?? "0") ?? 0;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Created $created area(s)")),
      );
      Navigator.of(context).pop(created > 0);
    } on DioException catch (err) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(err))),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AdminEditorHeader(
              title: "Bulk add areas",
              submitting: _submitting,
              onClose: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < _rows.length; i++) ...<Widget>[
              Text("Row ${i + 1}", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              TextField(
                controller: _rows[i].nameEn,
                decoration: InputDecoration(labelText: widget.l10n.adminNameEnglish),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rows[i].nameAr,
                decoration:
                    InputDecoration(labelText: widget.l10n.adminNameArabicLabel),
              ),
              if (_rows.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(() {
                              _rows.removeAt(i).dispose();
                            });
                          },
                    child: Text(widget.l10n.commonDelete),
                  ),
                ),
              const Divider(height: 24),
            ],
            OutlinedButton.icon(
              onPressed: _submitting
                  ? null
                  : () => setState(() => _rows.add(_NamePairRow())),
              icon: const Icon(Icons.add),
              label: const Text("Add row"),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Text(widget.l10n.commonCreate),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkRestaurantsBody extends StatefulWidget {
  const _BulkRestaurantsBody({required this.l10n, required this.api});

  final AppLocalizations l10n;
  final MenuApi api;

  @override
  State<_BulkRestaurantsBody> createState() => _BulkRestaurantsBodyState();
}

class _BulkRestaurantsBodyState extends State<_BulkRestaurantsBody> {
  final List<_NamePairRow> _rows = <_NamePairRow>[_NamePairRow()];
  bool _submitting = false;

  @override
  void dispose() {
    for (final _NamePairRow r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
    for (final _NamePairRow r in _rows) {
      final String en = r.nameEn.text.trim();
      final String ar = r.nameAr.text.trim();
      if (en.isEmpty && ar.isEmpty) continue;
      if (en.isEmpty || ar.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Each filled row needs English and Arabic names"),
          ),
        );
        return;
      }
      items.add(<String, dynamic>{"nameEn": en, "nameAr": ar});
    }
    if (items.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final Map<String, dynamic> result =
          await widget.api.adminBulkCreateRestaurants(items);
      if (!mounted) return;
      final int created = int.tryParse(result["created"]?.toString() ?? "0") ?? 0;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Created $created restaurant(s)")),
      );
      Navigator.of(context).pop(created > 0);
    } on DioException catch (err) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(err))),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AdminEditorHeader(
              title: "Bulk add restaurants",
              submitting: _submitting,
              onClose: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < _rows.length; i++) ...<Widget>[
              Text("Row ${i + 1}", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              TextField(
                controller: _rows[i].nameEn,
                decoration: InputDecoration(labelText: widget.l10n.adminNameEnglish),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rows[i].nameAr,
                decoration:
                    InputDecoration(labelText: widget.l10n.adminNameArabicLabel),
              ),
              if (_rows.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(() {
                              _rows.removeAt(i).dispose();
                            });
                          },
                    child: Text(widget.l10n.commonDelete),
                  ),
                ),
              const Divider(height: 24),
            ],
            OutlinedButton.icon(
              onPressed: _submitting
                  ? null
                  : () => setState(() => _rows.add(_NamePairRow())),
              icon: const Icon(Icons.add),
              label: const Text("Add row"),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Text(widget.l10n.commonCreate),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchBulkRow {
  _BranchBulkRow({String? restaurantId})
      : restaurantId = restaurantId,
        nameEn = TextEditingController(),
        nameAr = TextEditingController();

  String? restaurantId;
  String? areaId;
  final TextEditingController nameEn;
  final TextEditingController nameAr;

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}

class _BulkBranchesBody extends StatefulWidget {
  const _BulkBranchesBody({
    required this.l10n,
    required this.api,
    required this.restaurants,
    required this.areas,
    this.initialRestaurantId,
  });

  final AppLocalizations l10n;
  final MenuApi api;
  final List<RestaurantDto> restaurants;
  final List<AreaDto> areas;
  final String? initialRestaurantId;

  @override
  State<_BulkBranchesBody> createState() => _BulkBranchesBodyState();
}

class _BulkBranchesBodyState extends State<_BulkBranchesBody> {
  late final List<_BranchBulkRow> _rows;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final String? rid =
        widget.initialRestaurantId ?? widget.restaurants.first.id;
    _rows = <_BranchBulkRow>[_BranchBulkRow(restaurantId: rid)];
  }

  @override
  void dispose() {
    for (final _BranchBulkRow r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
    for (final _BranchBulkRow r in _rows) {
      final String en = r.nameEn.text.trim();
      final String ar = r.nameAr.text.trim();
      if (en.isEmpty && ar.isEmpty) continue;
      if (r.restaurantId == null || r.restaurantId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.adminValidationSelectRestaurant)),
        );
        return;
      }
      if (en.isEmpty || ar.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Each filled row needs English and Arabic names"),
          ),
        );
        return;
      }
      items.add(<String, dynamic>{
        "restaurantId": r.restaurantId,
        "nameEn": en,
        "nameAr": ar,
        if (r.areaId != null && r.areaId!.isNotEmpty) "areaId": r.areaId,
      });
    }
    if (items.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final Map<String, dynamic> result =
          await widget.api.adminBulkCreateBranches(items);
      if (!mounted) return;
      final int created = int.tryParse(result["created"]?.toString() ?? "0") ?? 0;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Created $created branch(es)")),
      );
      Navigator.of(context).pop(created > 0);
    } on DioException catch (err) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(err))),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AdminEditorHeader(
              title: "Bulk add branches",
              submitting: _submitting,
              onClose: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < _rows.length; i++) ...<Widget>[
              Text("Row ${i + 1}", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _rows[i].restaurantId,
                decoration: InputDecoration(
                  labelText: widget.l10n.adminValidationSelectRestaurant,
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
                    : (String? v) => setState(() => _rows[i].restaurantId = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _rows[i].areaId,
                decoration: const InputDecoration(labelText: "Area (optional)"),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text("None"),
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
                    : (String? v) => setState(() => _rows[i].areaId = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rows[i].nameEn,
                decoration: InputDecoration(labelText: widget.l10n.adminNameEnglish),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rows[i].nameAr,
                decoration:
                    InputDecoration(labelText: widget.l10n.adminNameArabicLabel),
              ),
              if (_rows.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(() {
                              _rows.removeAt(i).dispose();
                            });
                          },
                    child: Text(widget.l10n.commonDelete),
                  ),
                ),
              const Divider(height: 24),
            ],
            OutlinedButton.icon(
              onPressed: _submitting
                  ? null
                  : () => setState(
                        () => _rows.add(
                          _BranchBulkRow(
                            restaurantId: widget.initialRestaurantId ??
                                widget.restaurants.first.id,
                          ),
                        ),
                      ),
              icon: const Icon(Icons.add),
              label: const Text("Add row"),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Text(widget.l10n.commonCreate),
            ),
          ],
        ),
      ),
    );
  }
}

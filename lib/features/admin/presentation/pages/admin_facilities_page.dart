import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_facility_editor_sheet.dart";
import "package:menu_2026/features/facilities/data/models/facility_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class AdminFacilitiesPage extends ConsumerStatefulWidget {
  const AdminFacilitiesPage({super.key});

  @override
  ConsumerState<AdminFacilitiesPage> createState() =>
      _AdminFacilitiesPageState();
}

class _AdminFacilitiesPageState extends ConsumerState<AdminFacilitiesPage> {
  bool _loading = true;
  String? _error;
  List<FacilityDto> _items = <FacilityDto>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<FacilityDto> list =
          await ref.read(menuApiProvider).getFacilities();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openEditor(FacilityDto? existing) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MenuApi api = ref.read(menuApiProvider);
    final bool saved = await showAdminFacilityEditor(
      context: context,
      l10n: l10n,
      api: api,
      existing: existing,
    );
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commonSaved)),
    );
    await _load();
  }

  Future<void> _delete(FacilityDto f) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.adminDeleteFacilityTitle),
        content: Text(l10n.adminDeleteFacilityMessage(f.nameEn)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(menuApiProvider).adminDeleteFacility(f.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonDeleted)),
        );
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminFacilitiesTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go("/admin");
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.adminTooltipRefresh,
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(null),
        icon: const Icon(Icons.add),
        label: Text(l10n.commonAdd),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        l10n.adminNoFacilities,
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(height: 1),
                        itemBuilder: (BuildContext context, int i) {
                          final FacilityDto f = _items[i];
                          return ListTile(
                            title: Text(f.nameEn),
                            subtitle: Text(
                              f.nameAr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _openEditor(f),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  onPressed: () => _delete(f),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

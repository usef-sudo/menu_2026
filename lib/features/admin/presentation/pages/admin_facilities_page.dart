import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/facilities/data/models/facility_dto.dart";

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

  Future<void> _edit(FacilityDto? existing) async {
    final String? nameEn = await _prompt(context, "Name (EN)", existing?.nameEn);
    if (nameEn == null || nameEn.isEmpty) return;
    final String? nameAr = await _prompt(context, "Name (AR)", existing?.nameAr);
    if (nameAr == null || nameAr.isEmpty) return;
    final String? icon = await _prompt(context, "Icon (optional)", existing?.icon);
    try {
      final MenuApi api = ref.read(menuApiProvider);
      if (existing == null) {
        await api.adminCreateFacility(nameEn: nameEn, nameAr: nameAr, icon: icon);
      } else {
        await api.adminUpdateFacility(
          existing.id,
          nameEn: nameEn,
          nameAr: nameAr,
          icon: icon,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _delete(FacilityDto f) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text("Delete facility"),
        content: Text("Delete ${f.nameEn}?"),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(menuApiProvider).adminDeleteFacility(f.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facilities"),
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loading ? null : _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, int i) {
                    final FacilityDto f = _items[i];
                    return ListTile(
                      title: Text(f.nameEn),
                      subtitle: Text(f.nameAr),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(f)),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                            onPressed: () => _delete(f),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

Future<String?> _prompt(BuildContext context, String label, String? initial) async {
  final TextEditingController c = TextEditingController(text: initial ?? "");
  final String? r = await showDialog<String>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(label),
      content: TextField(controller: c, decoration: InputDecoration(labelText: label), autofocus: true),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text("OK")),
      ],
    ),
  );
  c.dispose();
  return r;
}

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/data/area_dto.dart";

class AdminAreasPage extends ConsumerStatefulWidget {
  const AdminAreasPage({super.key});

  @override
  ConsumerState<AdminAreasPage> createState() => _AdminAreasPageState();
}

class _AdminAreasPageState extends ConsumerState<AdminAreasPage> {
  bool _loading = true;
  String? _error;
  List<AreaDto> _items = <AreaDto>[];

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
      final List<AreaDto> list = await ref.read(menuApiProvider).getAreas();
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

  Future<void> _edit(AreaDto? existing) async {
    final String? nameEn = await _promptArea(context, "Name (EN)", existing?.nameEn);
    if (nameEn == null || nameEn.isEmpty) return;
    final String? nameAr = await _promptArea(context, "Name (AR)", existing?.nameAr);
    if (nameAr == null || nameAr.isEmpty) return;
    try {
      final MenuApi api = ref.read(menuApiProvider);
      if (existing == null) {
        await api.adminCreateArea(nameEn: nameEn, nameAr: nameAr);
      } else {
        await api.adminUpdateArea(existing.id, nameEn: nameEn, nameAr: nameAr);
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

  Future<void> _delete(AreaDto a) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text("Delete area"),
        content: Text("Delete ${a.nameEn}?"),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(menuApiProvider).adminDeleteArea(a.id);
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
        title: const Text("Areas"),
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
                    final AreaDto a = _items[i];
                    return ListTile(
                      title: Text(a.nameEn),
                      subtitle: Text(a.nameAr),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(a)),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                            onPressed: () => _delete(a),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

Future<String?> _promptArea(BuildContext context, String label, String? initial) async {
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

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";

class AdminRestaurantsPage extends ConsumerStatefulWidget {
  const AdminRestaurantsPage({super.key});

  @override
  ConsumerState<AdminRestaurantsPage> createState() => _AdminRestaurantsPageState();
}

class _AdminRestaurantsPageState extends ConsumerState<AdminRestaurantsPage> {
  bool _loading = true;
  String? _error;
  List<RestaurantDto> _items = <RestaurantDto>[];

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
      final List<RestaurantDto> list =
          await ref.read(menuApiProvider).getRestaurants(limit: 200);
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

  Future<void> _create() async {
    final String? nameEn = await _prompt(context, "Name (EN)");
    if (nameEn == null || nameEn.isEmpty) return;
    final String? nameAr = await _prompt(context, "Name (AR)");
    if (nameAr == null || nameAr.isEmpty) return;
    try {
      final RestaurantDto r =
          await ref.read(menuApiProvider).adminCreateRestaurant(nameEn: nameEn, nameAr: nameAr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Created")));
        await _load();
        context.push("/admin/restaurants/${r.id}");
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
        title: const Text("Restaurants"),
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
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text("New restaurant"),
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
                    final RestaurantDto r = _items[i];
                    return ListTile(
                      title: Text(r.nameEn),
                      subtitle: Text(r.nameAr),
                      onTap: () => context.push("/admin/restaurants/${r.id}"),
                      trailing: const Icon(Icons.chevron_right),
                    );
                  },
                ),
    );
  }
}

Future<String?> _prompt(BuildContext context, String label) async {
  final TextEditingController c = TextEditingController();
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

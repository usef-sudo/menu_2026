import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/branches/data/models/branch_dto.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";

class AdminBranchesPage extends ConsumerStatefulWidget {
  const AdminBranchesPage({super.key});

  @override
  ConsumerState<AdminBranchesPage> createState() => _AdminBranchesPageState();
}

class _AdminBranchesPageState extends ConsumerState<AdminBranchesPage> {
  bool _loading = true;
  String? _error;
  List<BranchDto> _branches = <BranchDto>[];
  List<RestaurantDto> _restaurants = <RestaurantDto>[];
  String? _filterRestaurantId;

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
      final MenuApi api = ref.read(menuApiProvider);
      final List<RestaurantDto> rests = await api.getRestaurants(limit: 200);
      final List<BranchDto> br = await api.getBranches(
        restaurantId: _filterRestaurantId,
      );
      if (!mounted) return;
      setState(() {
        _restaurants = rests;
        _branches = br;
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
    if (_restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create a restaurant first")),
      );
      return;
    }
    String? rid = _filterRestaurantId;
    rid ??= await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => SimpleDialog(
        title: const Text("Restaurant"),
        children: _restaurants
            .map(
              (RestaurantDto r) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, r.id),
                child: Text(r.nameEn),
              ),
            )
            .toList(),
      ),
    );
    if (rid == null) return;
    final String? nameEn = await _prompt(context, "Branch name (EN)");
    if (nameEn == null || nameEn.isEmpty) return;
    final String? nameAr = await _prompt(context, "Branch name (AR)");
    if (nameAr == null || nameAr.isEmpty) return;
    try {
      final BranchDto b = await ref.read(menuApiProvider).adminCreateBranch(
            restaurantId: rid,
            nameEn: nameEn,
            nameAr: nameAr,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Created")));
        await _load();
        context.push("/admin/branches/${b.id}");
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
        title: const Text("Branches"),
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
        label: const Text("New branch"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String?>(
              decoration: const InputDecoration(labelText: "Filter by restaurant"),
              value: _filterRestaurantId,
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(value: null, child: Text("All")),
                ..._restaurants.map(
                  (RestaurantDto r) => DropdownMenuItem<String?>(
                    value: r.id,
                    child: Text(r.nameEn),
                  ),
                ),
              ],
              onChanged: (String? v) {
                setState(() => _filterRestaurantId = v);
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _error != null
                    ? Center(child: Text(_error!))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _branches.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, int i) {
                          final BranchDto b = _branches[i];
                          return ListTile(
                            title: Text(b.nameEn),
                            subtitle: Text(b.address.isEmpty ? b.nameAr : b.address),
                            onTap: () => context.push("/admin/branches/${b.id}"),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
          ),
        ],
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
      content: TextField(controller: c, autofocus: true),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text("OK")),
      ],
    ),
  );
  c.dispose();
  return r;
}

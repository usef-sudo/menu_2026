import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_restaurant_editor_sheet.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class AdminRestaurantsPage extends ConsumerStatefulWidget {
  const AdminRestaurantsPage({super.key});

  @override
  ConsumerState<AdminRestaurantsPage> createState() =>
      _AdminRestaurantsPageState();
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final RestaurantDto? r = await showAdminRestaurantEditor(
      context: context,
      l10n: l10n,
      api: ref.read(menuApiProvider),
    );
    if (!mounted || r == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commonCreated)),
    );
    await _load();
    if (mounted) context.push("/admin/restaurants/${r.id}");
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminRestaurantsTitle),
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
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: Text(l10n.adminNewRestaurant),
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
                        l10n.adminNoRestaurants,
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
                          final RestaurantDto r = _items[i];
                          return ListTile(
                            title: Text(r.nameEn),
                            subtitle: Text(
                              r.nameAr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => context.push("/admin/restaurants/${r.id}"),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
                    ),
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/data/area_dto.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_branch_editor_sheet.dart";
import "package:menu_2026/features/branches/data/models/branch_dto.dart";
import "package:menu_2026/features/facilities/data/models/facility_dto.dart";
import "package:menu_2026/features/restaurants/data/models/restaurant_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

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
  List<AreaDto> _areas = <AreaDto>[];
  List<FacilityDto> _facilities = <FacilityDto>[];
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
      final List<AreaDto> areas = await api.getAreas();
      final List<FacilityDto> fac = await api.getFacilities();
      if (!mounted) return;
      setState(() {
        _restaurants = rests;
        _branches = br;
        _areas = areas;
        _facilities = fac;
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
    if (_restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminCreateRestaurantFirst)),
      );
      return;
    }
    final MenuApi api = ref.read(menuApiProvider);
    final bool lockRestaurant = _filterRestaurantId != null;
    final BranchDto? b = await showAdminBranchEditor(
      context: context,
      l10n: l10n,
      api: api,
      restaurants: _restaurants,
      areas: _areas,
      facilities: _facilities,
      initialRestaurantId: _filterRestaurantId,
      lockRestaurantId: lockRestaurant,
    );
    if (!mounted || b == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commonCreated)),
    );
    await _load();
    if (mounted) context.push("/admin/branches/${b.id}");
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminBranchesTitle),
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
        label: Text(l10n.adminNewBranch),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: DropdownButtonFormField<String?>(
              decoration: InputDecoration(
                labelText: l10n.adminFilterRestaurant,
              ),
              value: _filterRestaurantId,
              items: <DropdownMenuItem<String?>>[
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.commonAll),
                ),
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
                    : _branches.isEmpty
                        ? Center(
                            child: Text(
                              l10n.adminNoBranches,
                              style: theme.textTheme.bodyLarge,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _branches.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(height: 1),
                              itemBuilder: (BuildContext context, int i) {
                                final BranchDto b = _branches[i];
                                return ListTile(
                                  title: Text(b.nameEn),
                                  subtitle: Text(
                                    b.address.isEmpty ? b.nameAr : b.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () =>
                                      context.push("/admin/branches/${b.id}"),
                                  trailing: const Icon(Icons.chevron_right),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

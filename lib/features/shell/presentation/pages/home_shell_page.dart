import "package:flutter/material.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/features/categories/presentation/pages/categories_page.dart";
import "package:menu_2026/features/home/presentation/pages/home_discovery_page.dart";
import "package:menu_2026/features/map_nearby/presentation/pages/nearby_map_page.dart";
import "package:menu_2026/features/offers/presentation/pages/offers_page.dart";
import "package:menu_2026/features/profile/presentation/pages/profile_page.dart";
import "package:menu_2026/features/spin/presentation/pages/spin_page.dart";

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _index = 0;

  static const List<Widget> _tabs = <Widget>[
    HomeDiscoveryPage(),
    CategoriesPage(),
    NearbyMapPage(),
    SpinPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.shellHotDealsTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const OffersPage(),
              ),
            ),
            icon: const Icon(
              Icons.local_fire_department_outlined,
              color: Colors.deepOrange,
              size: 30,
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            label: l10n.navCategories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.casino_outlined),
            label: l10n.navSpin,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

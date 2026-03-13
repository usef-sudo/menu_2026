import "package:flutter/material.dart";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const OffersPage())),
            icon: const Icon(Icons.local_offer_outlined),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: "Categories",
          ),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: "Map"),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            label: "Spin",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

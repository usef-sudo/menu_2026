import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.go("/home"),
            child: const Text("Open app"),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Menu admin",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text("Categories"),
              onTap: () {
                Navigator.of(context).pop();
                context.push("/admin/categories");
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined),
              title: const Text("Facilities"),
              onTap: () {
                Navigator.of(context).pop();
                context.push("/admin/facilities");
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text("Areas"),
              onTap: () {
                Navigator.of(context).pop();
                context.push("/admin/areas");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restaurant_outlined),
              title: const Text("Restaurants"),
              onTap: () {
                Navigator.of(context).pop();
                context.push("/admin/restaurants");
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text("Branches"),
              onTap: () {
                Navigator.of(context).pop();
                context.push("/admin/branches");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text("Users"),
              onTap: () {
                Navigator.of(context).pop();
                context.push("/admin/users");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign out"),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(sessionControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go("/admin/login");
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "Admin dashboard",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Use the drawer to open each section.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () => context.push("/admin/categories"),
                    icon: const Icon(Icons.category_outlined),
                    label: const Text("Categories"),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push("/admin/facilities"),
                    icon: const Icon(Icons.local_offer_outlined),
                    label: const Text("Facilities"),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push("/admin/areas"),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Areas"),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push("/admin/restaurants"),
                    icon: const Icon(Icons.restaurant_outlined),
                    label: const Text("Restaurants"),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push("/admin/branches"),
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text("Branches"),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push("/admin/users"),
                    icon: const Icon(Icons.people_outline),
                    label: const Text("Users"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

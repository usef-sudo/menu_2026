import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/legal/legal_urls.dart";
import "package:menu_2026/core/settings/app_settings_controller.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/favorites/presentation/pages/favorites_page.dart";
import "package:menu_2026/features/map_nearby/presentation/pages/nearby_map_page.dart";
import "package:menu_2026/features/profile/presentation/controllers/profile_stats_controller.dart";
import "package:url_launcher/url_launcher.dart";

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static Future<void> _openLegalUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final bool ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final stats = ref.watch(profileStatsControllerProvider);
    final bool isLoggedIn = session.valueOrNull?.isAuthenticated ?? false;
    final bool isAdmin = session.valueOrNull?.isAdmin ?? false;
    final int favoritesCount = favorites.valueOrNull?.length ?? 0;
    final int visitedCount =
        isLoggedIn ? (stats.valueOrNull?.visitedCount ?? 0) : 0;
    final int reviewCount =
        isLoggedIn ? (stats.valueOrNull?.reviewCount ?? 0) : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _ProfileHeader(
          isLoggedIn: isLoggedIn,
          favoritesCount: favoritesCount,
          visitedCount: visitedCount,
          reviewCount: reviewCount,
        ),
        const SizedBox(height: 24),
        if (isLoggedIn) ...<Widget>[
          Text(
            "My Activity",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.favorite_outline,
            label: "My Favorites",
            subtitle: "View saved restaurants",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FavoritesPage(),
                ),
              );
            },
          ),
          _ProfileTile(
            icon: Icons.place_outlined,
            label: "Nearby Places",
            subtitle: "Explore on map",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NearbyMapPage(),
                ),
              );
            },
          ),
          if (isAdmin) ...<Widget>[
            _ProfileTile(
              icon: Icons.admin_panel_settings_outlined,
              label: "Admin dashboard",
              subtitle: "Manage categories and content",
              onTap: () => context.push("/admin"),
            ),
          ],
          const SizedBox(height: 24),
        ],
        Text(
          "Settings",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _ProfileTile(
          icon: Icons.language_outlined,
          label: "Language",
          subtitle: "Choose your language",
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Text(
              "English",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const _DarkModeTile(),
        const SizedBox(height: 24),
        Text(
          "Legal",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _ProfileTile(
          icon: Icons.privacy_tip_outlined,
          label: "Privacy policy",
          subtitle: "How we handle your data",
          onTap: () => _openLegalUrl(context, LegalUrls.privacyPolicy),
        ),
        _ProfileTile(
          icon: Icons.article_outlined,
          label: "Terms of service",
          subtitle: "Rules for using the app",
          onTap: () => _openLegalUrl(context, LegalUrls.termsOfService),
        ),
        if (isLoggedIn) ...<Widget>[
          _ProfileTile(
            icon: Icons.person_outline,
            label: "Edit Profile",
            subtitle: "Update your information",
            onTap: () {
              // Profile editing flow can be added later.
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref
                .read(sessionControllerProvider.notifier)
                .logout(),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push("/auth/login"),
            child: const Text("Sign in or create account"),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isLoggedIn,
    required this.favoritesCount,
    required this.visitedCount,
    required this.reviewCount,
  });

  final bool isLoggedIn;
  final int favoritesCount;
  final int visitedCount;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF8A4DFF),
            Color(0xFFFF3F8E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isLoggedIn ? "Logged in user" : "Guest User",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn
                          ? "Tap settings to manage your account"
                          : "Sign in to sync your favorites",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _HeaderStat(
                label: "Visited",
                value: isLoggedIn ? visitedCount.toString() : "0",
              ),
              _HeaderStat(
                label: "Favorites",
                value: isLoggedIn ? favoritesCount.toString() : "0",
              ),
              _HeaderStat(
                label: "Reviews",
                value: isLoggedIn ? reviewCount.toString() : "0",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            size: 20,
          ),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatefulWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(widget.icon, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(
        widget.label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        widget.subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Switch(
        value: widget.value,
        onChanged: widget.onChanged,
      ),
      onTap: () => widget.onChanged(!widget.value),
    );
  }
}

class _DarkModeTile extends ConsumerWidget {
  const _DarkModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsControllerProvider);
    final ThemeData theme = Theme.of(context);

    return settings.when(
      data: (AppSettings value) {
        final bool isDark = value.themeMode == ThemeMode.dark;
        return _SwitchTile(
          icon: Icons.dark_mode_outlined,
          label: "Dark Mode",
          subtitle: "Toggle dark theme",
          value: isDark,
          onChanged: (_) =>
              ref.read(appSettingsControllerProvider.notifier).toggleDarkMode(),
        );
      },
      loading: () => ListTile(
        leading: const CircularProgressIndicator.adaptive(strokeWidth: 2),
        title: Text(
          "Dark Mode",
          style: theme.textTheme.bodyLarge,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}



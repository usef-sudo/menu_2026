import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/legal/legal_urls.dart";
import "package:menu_2026/core/settings/app_settings_controller.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/favorites/presentation/controllers/favorites_controller.dart";
import "package:menu_2026/features/favorites/presentation/pages/favorites_page.dart";
import "package:menu_2026/features/map_nearby/presentation/pages/nearby_map_page.dart";
import "package:menu_2026/features/onboarding/presentation/pages/select_language_page.dart";
import "package:menu_2026/features/profile/presentation/controllers/profile_stats_controller.dart";
import "package:menu_2026/l10n/app_localizations.dart";
import "package:url_launcher/url_launcher.dart";

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static Future<void> _openLegalUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final bool ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileCouldNotOpenLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settingsAsync = ref.watch(appSettingsControllerProvider);
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
          l10n: l10n,
        ),
        const SizedBox(height: 24),
        if (isLoggedIn) ...<Widget>[
          Text(
            l10n.profileMyActivity,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.favorite_outline,
            label: l10n.profileMyFavorites,
            subtitle: l10n.profileMyFavoritesSubtitle,
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
            label: l10n.profileNearbyPlaces,
            subtitle: l10n.profileNearbySubtitle,
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
              label: l10n.profileAdminDashboard,
              subtitle: l10n.profileAdminSubtitle,
              onTap: () => context.push("/admin"),
            ),
          ],
          const SizedBox(height: 24),
        ],
        Text(
          l10n.profileSettings,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _ProfileTile(
          icon: Icons.language_outlined,
          label: l10n.profileLanguage,
          subtitle: l10n.profileLanguageSubtitle,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Text(
              settingsAsync.maybeWhen(
                data: (AppSettings s) =>
                    s.localeCode == "ar" ? l10n.languageArabic : l10n.languageEnglish,
                orElse: () => l10n.languageEnglish,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext sheetCtx) => SelectLanguagePage(
                  onDone: () {
                    ref.invalidate(appSettingsControllerProvider);
                    Navigator.of(sheetCtx).pop();
                  },
                ),
              ),
            );
          },
        ),
        const _DarkModeTile(),
        const SizedBox(height: 24),
        Text(
          l10n.profileLegal,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _ProfileTile(
          icon: Icons.privacy_tip_outlined,
          label: l10n.profilePrivacy,
          subtitle: l10n.profilePrivacySubtitle,
          onTap: () => _openLegalUrl(context, LegalUrls.privacyPolicy),
        ),
        _ProfileTile(
          icon: Icons.article_outlined,
          label: l10n.profileTerms,
          subtitle: l10n.profileTermsSubtitle,
          onTap: () => _openLegalUrl(context, LegalUrls.termsOfService),
        ),
        if (isLoggedIn) ...<Widget>[
          _ProfileTile(
            icon: Icons.person_outline,
            label: l10n.profileEditProfile,
            subtitle: l10n.profileEditSubtitle,
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
            label: Text(l10n.profileLogout),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push("/auth/login"),
            child: Text(l10n.profileSignInCreate),
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
    required this.l10n,
  });

  final bool isLoggedIn;
  final int favoritesCount;
  final int visitedCount;
  final int reviewCount;
  final AppLocalizations l10n;

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
                      isLoggedIn
                          ? l10n.profileLoggedInUser
                          : l10n.profileGuestUser,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn
                          ? l10n.profileTapSettings
                          : l10n.profileSignInSync,
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
                label: l10n.profileVisited,
                value: isLoggedIn ? visitedCount.toString() : "0",
              ),
              _HeaderStat(
                label: l10n.profileFavoritesStat,
                value: isLoggedIn ? favoritesCount.toString() : "0",
              ),
              _HeaderStat(
                label: l10n.profileReviewsStat,
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
          label: context.l10n.profileDarkMode,
          subtitle: context.l10n.profileDarkModeSubtitle,
          value: isDark,
          onChanged: (_) =>
              ref.read(appSettingsControllerProvider.notifier).toggleDarkMode(),
        );
      },
      loading: () => ListTile(
        leading: const CircularProgressIndicator.adaptive(strokeWidth: 2),
        title: Text(
          context.l10n.profileDarkMode,
          style: theme.textTheme.bodyLarge,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}



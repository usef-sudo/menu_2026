import "package:flutter/material.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/core/utils/http_url.dart";
import "package:menu_2026/features/restaurants/presentation/pages/in_app_web_view_page.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class RestaurantExternalLinks extends StatelessWidget {
  const RestaurantExternalLinks({
    super.key,
    this.websiteUrl = "",
    this.instagramUrl = "",
    this.facebookUrl = "",
    this.talabatUrl = "",
    this.careemUrl = "",
    this.showTitle = true,
    this.inCard = false,
  });

  final String websiteUrl;
  final String instagramUrl;
  final String facebookUrl;
  final String talabatUrl;
  final String careemUrl;
  final bool showTitle;
  final bool inCard;

  static bool hasAny({
    String websiteUrl = "",
    String instagramUrl = "",
    String facebookUrl = "",
    String talabatUrl = "",
    String careemUrl = "",
  }) {
    return <String>[
      websiteUrl,
      instagramUrl,
      facebookUrl,
      talabatUrl,
      careemUrl,
    ].any((String value) => value.trim().isNotEmpty);
  }

  List<_RestaurantLinkSpec> _specs(AppLocalizations l10n) {
    return <_RestaurantLinkSpec>[
      _RestaurantLinkSpec(
        label: l10n.restaurantLinkWebsite,
        url: websiteUrl,
        icon: Icons.language_rounded,
        color: const Color(0xFF2563EB),
      ),
      _RestaurantLinkSpec(
        label: l10n.restaurantLinkInstagram,
        url: instagramUrl,
        icon: Icons.camera_alt_rounded,
        color: const Color(0xFFE1306C),
      ),
      _RestaurantLinkSpec(
        label: l10n.restaurantLinkFacebook,
        url: facebookUrl,
        icon: Icons.facebook,
        color: const Color(0xFF1877F2),
      ),
      _RestaurantLinkSpec(
        label: l10n.restaurantLinkTalabat,
        url: talabatUrl,
        icon: Icons.delivery_dining_rounded,
        color: const Color(0xFFFF5A00),
      ),
      _RestaurantLinkSpec(
        label: l10n.restaurantLinkCareem,
        url: careemUrl,
        icon: Icons.local_taxi_rounded,
        color: const Color(0xFF00A651),
      ),
    ].where((_RestaurantLinkSpec spec) => spec.url.trim().isNotEmpty).toList();
  }

  Future<void> _openLink(
    BuildContext context,
    _RestaurantLinkSpec spec,
  ) async {
    final Uri? uri = normalizeHttpUrl(spec.url);
    if (uri == null) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.restaurantLinkOpenFailed)),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => InAppWebViewPage(
          title: spec.label,
          uri: uri,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<_RestaurantLinkSpec> links = _specs(l10n);
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showTitle) ...<Widget>[
          Text(
            l10n.restaurantLinksTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: links
              .map(
                (_RestaurantLinkSpec spec) => _RestaurantLinkTile(
                  spec: spec,
                  onTap: () => _openLink(context, spec),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );

    if (!inCard) {
      return body;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: body,
    );
  }
}

class _RestaurantLinkSpec {
  const _RestaurantLinkSpec({
    required this.label,
    required this.url,
    required this.icon,
    required this.color,
  });

  final String label;
  final String url;
  final IconData icon;
  final Color color;
}

class _RestaurantLinkTile extends StatelessWidget {
  const _RestaurantLinkTile({
    required this.spec,
    required this.onTap,
  });

  final _RestaurantLinkSpec spec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: spec.color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: spec.color,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(spec.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                spec.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

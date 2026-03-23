import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/features/onboarding/presentation/pages/onboarding_page.dart";
import "package:menu_2026/l10n/app_localizations.dart";

void main() {
  testWidgets("Onboarding shows first slide and primary CTA", (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: "/",
      routes: <RouteBase>[
        GoRoute(
          path: "/",
          builder: (BuildContext context, GoRouterState state) =>
              const OnboardingPage(),
        ),
        GoRoute(
          path: "/auth/login",
          builder: (BuildContext context, GoRouterState state) =>
              const SizedBox.shrink(),
        ),
        GoRoute(
          path: "/home",
          builder: (BuildContext context, GoRouterState state) =>
              const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale("en"),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Discover Restaurants"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
    expect(find.text("Skip for now"), findsOneWidget);
  });
}

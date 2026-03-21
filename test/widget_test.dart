import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_2026/features/onboarding/presentation/pages/onboarding_page.dart";

void main() {
  testWidgets("Onboarding shows first slide and primary CTA", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: OnboardingPage()),
    );

    expect(find.text("Discover Restaurants"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
    expect(find.text("Skip for now"), findsOneWidget);
  });
}

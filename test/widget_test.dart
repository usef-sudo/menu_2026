import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_2026/app/config/app_environment.dart';
import 'package:menu_2026/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  testWidgets('Onboarding renders discovery CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appEnvironmentProvider.overrideWithValue(
            const AppEnvironment(
              flavor: AppFlavor.dev,
              apiBaseUrl: 'http://localhost:8000',
              sentryDsn: '',
            ),
          ),
        ],
        child: const MaterialApp(home: OnboardingPage()),
      ),
    );

    expect(find.text('Start exploring'), findsOneWidget);
    expect(find.text('Admin login'), findsOneWidget);
  });
}

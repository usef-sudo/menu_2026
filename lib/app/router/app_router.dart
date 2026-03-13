import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/features/auth/presentation/pages/forgot_password_page.dart";
import "package:menu_2026/features/auth/presentation/pages/login_page.dart";
import "package:menu_2026/features/auth/presentation/pages/register_page.dart";
import "package:menu_2026/features/categories/presentation/pages/category_restaurants_page.dart";
import "package:menu_2026/features/onboarding/presentation/pages/onboarding_page.dart";
import "package:menu_2026/features/restaurants/presentation/pages/restaurant_details_page.dart";
import "package:menu_2026/features/restaurants/presentation/pages/search_results_page.dart";
import "package:menu_2026/features/shell/presentation/pages/home_shell_page.dart";

final appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: "/",
    routes: <RouteBase>[
      GoRoute(path: "/", builder: (context, state) => const OnboardingPage()),
      GoRoute(
        path: "/auth/login",
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: "/auth/register",
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: "/auth/forgot",
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: "/admin/login",
        builder: (context, state) => const LoginPage(isAdmin: true),
      ),
      GoRoute(
        path: "/home",
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: "/restaurant/:id",
        builder: (context, state) {
          return RestaurantDetailsPage(
            restaurantId: state.pathParameters["id"] ?? "",
          );
        },
      ),
      GoRoute(
        path: "/categories/:id",
        builder: (context, state) {
          final String id = state.pathParameters["id"] ?? "";
          final String name = (state.extra as String?) ?? "Category";
          return CategoryRestaurantsPage(
            categoryId: id,
            categoryName: name,
          );
        },
      ),
      GoRoute(
        path: "/search/results",
        builder: (context, state) {
          final String query = (state.extra as String?) ?? "";
          return SearchResultsPage(query: query);
        },
      ),
    ],
  );
});

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_areas_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_branch_detail_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_branches_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_categories_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_dashboard_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_facilities_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_restaurant_detail_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_restaurants_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_user_detail_page.dart";
import "package:menu_2026/features/admin/presentation/pages/admin_users_page.dart";
import "package:menu_2026/features/auth/presentation/pages/forgot_password_page.dart";
import "package:menu_2026/features/auth/presentation/pages/login_page.dart";
import "package:menu_2026/features/auth/presentation/pages/register_page.dart";
import "package:menu_2026/features/categories/presentation/pages/category_restaurants_page.dart";
import "package:menu_2026/features/home/presentation/controllers/home_places_sort.dart";
import "package:menu_2026/features/home/presentation/pages/places_list_page.dart";
import "package:menu_2026/features/onboarding/presentation/pages/app_entry_page.dart";
import "package:menu_2026/features/onboarding/presentation/pages/onboarding_page.dart";
import "package:menu_2026/features/restaurants/presentation/pages/restaurant_details_page.dart";
import "package:menu_2026/features/restaurants/presentation/pages/search_results_page.dart";
import "package:menu_2026/features/shell/presentation/pages/home_shell_page.dart";

/// Bumps when [sessionControllerProvider] changes so [GoRouter] re-runs [GoRouter.redirect].
final goRouterRefreshProvider = Provider<ValueNotifier<int>>((Ref ref) {
  final ValueNotifier<int> notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  ref.listen<AsyncValue<SessionState>>(
    sessionControllerProvider,
    (_, __) {
      notifier.value = notifier.value + 1;
    },
  );
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    initialLocation: "/",
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final ProviderContainer container = ProviderScope.containerOf(context);
      final AsyncValue<SessionState> sessionAsync =
          container.read(sessionControllerProvider);
      if (sessionAsync.isLoading) {
        return null;
      }
      final SessionState? s = sessionAsync.valueOrNull;
      final String path = state.matchedLocation;
      final bool onAdminLogin = path == "/admin/login";
      final bool inAdminArea = path.startsWith("/admin");

      if (inAdminArea && !onAdminLogin) {
        if (s == null || !s.isAuthenticated) {
          return "/admin/login";
        }
        if (!s.isAdmin) {
          return "/home";
        }
      }
      if (onAdminLogin && s != null && s.isAuthenticated && s.isAdmin) {
        return "/admin";
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: "/", builder: (context, state) => const AppEntryPage()),
      GoRoute(
        path: "/onboarding",
        builder: (context, state) => const OnboardingPage(),
      ),
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
        path: "/admin/categories",
        builder: (context, state) => const AdminCategoriesPage(),
      ),
      GoRoute(
        path: "/admin/facilities",
        builder: (context, state) => const AdminFacilitiesPage(),
      ),
      GoRoute(
        path: "/admin/areas",
        builder: (context, state) => const AdminAreasPage(),
      ),
      GoRoute(
        path: "/admin/restaurants",
        builder: (context, state) => const AdminRestaurantsPage(),
        routes: <RouteBase>[
          GoRoute(
            path: ":id",
            builder: (BuildContext context, GoRouterState state) {
              return AdminRestaurantDetailPage(
                restaurantId: state.pathParameters["id"] ?? "",
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: "/admin/branches",
        builder: (context, state) => const AdminBranchesPage(),
        routes: <RouteBase>[
          GoRoute(
            path: ":id",
            builder: (BuildContext context, GoRouterState state) {
              return AdminBranchDetailPage(
                branchId: state.pathParameters["id"] ?? "",
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: "/admin/users",
        builder: (context, state) => const AdminUsersPage(),
        routes: <RouteBase>[
          GoRoute(
            path: ":id",
            builder: (BuildContext context, GoRouterState state) {
              return AdminUserDetailPage(
                userId: state.pathParameters["id"] ?? "",
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: "/admin",
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: "/home",
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: "/places",
        builder: (context, state) {
          final HomePlacesSort sort = homePlacesSortFromQuery(
            state.uri.queryParameters["sort"],
          );
          return PlacesListPage(initialSort: sort);
        },
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

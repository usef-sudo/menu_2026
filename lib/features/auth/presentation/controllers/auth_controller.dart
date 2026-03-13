import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/auth/data/models/login_response_dto.dart";
import "package:menu_2026/core/network/safe_request.dart";

class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> login({
    required String email,
    required String password,
    bool requireAdmin = false,
  }) async {
    final result = await safeRequest<LoginResponseDto>(() async {
      final payload =
          await ref.read(menuApiProvider).login(email: email, password: password);
      return payload;
    });

    return result.when(
      success: (LoginResponseDto payload) async {
        if (requireAdmin && payload.role != "admin") {
          return false;
        }

        await ref
            .read(sessionControllerProvider.notifier)
            .saveToken(payload.token);
        if (payload.refreshToken.isNotEmpty) {
          await ref
              .read(tokenStoreProvider)
              .saveRefreshToken(payload.refreshToken);
        }
        return true;
      },
      failure: (_) async => false,
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await safeRequest<void>(() async {
      await ref.read(menuApiProvider).register(
            name: name,
            email: email,
            password: password,
          );
    });

    return result.when(
      success: (_) async => true,
      failure: (_) async => false,
    );
  }

  Future<bool> requestPasswordReset({required String email}) async {
    final result = await safeRequest<void>(() async {
      await ref.read(menuApiProvider).forgotPassword(email: email);
    });

    return result.when(
      success: (_) async => true,
      failure: (_) async => false,
    );
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);

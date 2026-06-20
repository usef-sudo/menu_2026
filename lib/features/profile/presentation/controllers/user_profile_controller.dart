import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/profile/data/user_profile_dto.dart";

class UserProfileController extends AsyncNotifier<UserProfileDto?> {
  @override
  Future<UserProfileDto?> build() async {
    final SessionState? session =
        ref.watch(sessionControllerProvider).valueOrNull;
    if (session == null || !session.isAuthenticated) {
      return null;
    }
    final result = await safeRequest<UserProfileDto>(() async {
      return ref.read(menuApiProvider).getCurrentUser();
    });
    return result.when(
      success: (UserProfileDto profile) => profile,
      failure: (_) => null,
    );
  }

  Future<UserProfileDto?> _fetchProfile() async {
    final result = await safeRequest<UserProfileDto>(() async {
      return ref.read(menuApiProvider).getCurrentUser();
    });
    return result.when(
      success: (UserProfileDto profile) => profile,
      failure: (_) => null,
    );
  }

  Future<void> refreshProfile() async {
    final SessionState? session = ref.read(sessionControllerProvider).valueOrNull;
    if (session == null || !session.isAuthenticated) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading<UserProfileDto?>();
    state = await AsyncValue.guard(_fetchProfile);
  }

  Future<bool> updateProfile({
    required String name,
    required String birthDate,
    required String gender,
    required String phoneNumber,
  }) async {
    final result = await safeRequest<UserProfileDto>(() async {
      return ref.read(menuApiProvider).updateCurrentUser(
            name: name,
            birthDate: birthDate,
            gender: gender,
            phoneNumber: phoneNumber,
          );
    });

    return result.when(
      success: (UserProfileDto profile) {
        state = AsyncData(profile);
        return true;
      },
      failure: (_) => false,
    );
  }
}

final userProfileControllerProvider =
    AsyncNotifierProvider<UserProfileController, UserProfileDto?>(
      UserProfileController.new,
    );

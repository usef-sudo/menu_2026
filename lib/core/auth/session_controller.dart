import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/auth/token_store.dart";

final tokenStoreProvider = Provider<TokenStore>((Ref ref) {
  return TokenStore(TokenStore.createDefault());
});

class SessionState {
  const SessionState({this.token, this.role});

  final String? token;
  final String? role;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  bool get isAdmin => role == "admin";

  SessionState copyWith({
    String? token,
    String? role,
    bool clear = false,
  }) {
    if (clear) {
      return const SessionState(token: null, role: null);
    }
    return SessionState(
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}

class SessionController extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    try {
      final token = await ref.read(tokenStoreProvider).readToken();
      final String? roleRaw = await ref.read(tokenStoreProvider).readUserRole();
      final String? role = switch (roleRaw?.trim()) {
        null || "" => null,
        final String r => r.toLowerCase(),
      };
      return SessionState(token: token, role: role);
    } catch (_) {
      // Never block app start on storage failures.
      return const SessionState(token: null, role: null);
    }
  }

  Future<void> saveToken(String token) async {
    await ref.read(tokenStoreProvider).saveToken(token);
    state = AsyncData(SessionState(token: token, role: state.valueOrNull?.role));
  }

  /// Persists access token, optional user role (e.g. "admin"), and updates state.
  Future<void> saveSession({
    required String token,
    String? role,
  }) async {
    final String? normalizedRole = switch (role?.trim()) {
      null || "" => null,
      final String r => r.toLowerCase(),
    };
    final store = ref.read(tokenStoreProvider);
    await store.saveToken(token);
    await store.saveUserRole(normalizedRole);
    state = AsyncData(SessionState(token: token, role: normalizedRole));
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(SessionState(token: null, role: null));
  }
}

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, SessionState>(
      SessionController.new,
    );

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:menu_2026/core/auth/token_store.dart";

final tokenStoreProvider = Provider<TokenStore>((Ref ref) {
  return TokenStore(const FlutterSecureStorage());
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

class SessionController extends AutoDisposeAsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    final token = await ref.read(tokenStoreProvider).readToken();
    final role = await ref.read(tokenStoreProvider).readUserRole();
    return SessionState(token: token, role: role);
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
    final store = ref.read(tokenStoreProvider);
    await store.saveToken(token);
    await store.saveUserRole(role);
    state = AsyncData(SessionState(token: token, role: role));
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(SessionState(token: null, role: null));
  }
}

final sessionControllerProvider =
    AutoDisposeAsyncNotifierProvider<SessionController, SessionState>(
      SessionController.new,
    );

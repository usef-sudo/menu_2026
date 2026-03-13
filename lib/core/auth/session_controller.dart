import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:menu_2026/core/auth/token_store.dart";

final tokenStoreProvider = Provider<TokenStore>((Ref ref) {
  return TokenStore(const FlutterSecureStorage());
});

class SessionState {
  const SessionState({this.token});
  final String? token;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  SessionState copyWith({String? token, bool clear = false}) {
    if (clear) {
      return const SessionState(token: null);
    }
    return SessionState(token: token ?? this.token);
  }
}

class SessionController extends AutoDisposeAsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    final token = await ref.read(tokenStoreProvider).readToken();
    return SessionState(token: token);
  }

  Future<void> saveToken(String token) async {
    await ref.read(tokenStoreProvider).saveToken(token);
    state = AsyncData(SessionState(token: token));
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(SessionState(token: null));
  }
}

final sessionControllerProvider =
    AutoDisposeAsyncNotifierProvider<SessionController, SessionState>(
      SessionController.new,
    );

import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/app/config/app_environment.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/network/interceptors/auth_interceptor.dart";
import "package:menu_2026/core/network/interceptors/error_interceptor.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";

final dioProvider = Provider<Dio>((Ref ref) {
  final env = ref.watch(appEnvironmentProvider);
  final tokenStore = ref.watch(tokenStoreProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: "${env.apiBaseUrl}/api",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: <String, String>{
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(tokenStore));
  dio.interceptors.add(ErrorInterceptor(tokenStore));
  dio.interceptors.add(
    PrettyDioLogger(
      requestBody: !env.isProd,
      requestHeader: !env.isProd,
      responseBody: !env.isProd,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );
  return dio;
});

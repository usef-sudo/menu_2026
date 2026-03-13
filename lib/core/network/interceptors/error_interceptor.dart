import "package:dio/dio.dart";
import "package:menu_2026/core/auth/token_store.dart";
import "package:menu_2026/core/errors/failure.dart";

class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this._tokenStore);

  final TokenStore _tokenStore;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final Response<dynamic>? response = err.response;
    final dynamic data = response?.data;

    if (response?.statusCode == 401) {
      final RequestOptions requestOptions = err.requestOptions;
      final bool alreadyRetried =
          (requestOptions.extra["retriedWithRefresh"] as bool?) ?? false;

      if (!alreadyRetried) {
        final String? refreshToken = await _tokenStore.readRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            final Dio refreshDio = Dio(
              BaseOptions(
                baseUrl: requestOptions.baseUrl,
                headers: <String, String>{
                  "Accept": "application/json",
                  "Content-Type": "application/json",
                },
              ),
            );

            final Response<dynamic> refreshResponse = await refreshDio.post(
              "/users/refresh",
              data: <String, dynamic>{"refreshToken": refreshToken},
            );

            final dynamic body = refreshResponse.data;
            if (body is Map<String, dynamic>) {
              final String newAccessToken =
                  (body["accessToken"] ?? body["token"] ?? "").toString();
              final String newRefreshToken =
                  (body["refreshToken"] ?? "").toString();

              if (newAccessToken.isNotEmpty && newRefreshToken.isNotEmpty) {
                await _tokenStore.saveToken(newAccessToken);
                await _tokenStore.saveRefreshToken(newRefreshToken);

                requestOptions.headers["Authorization"] =
                    "Bearer $newAccessToken";
                requestOptions.extra["retriedWithRefresh"] = true;

                final Response<dynamic> retryResponse =
                    await refreshDio.fetch<dynamic>(requestOptions);

                handler.resolve(retryResponse);
                return;
              }
            }
          } catch (_) {
            // fall through to auth failure
          }
        }
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const AuthFailure("Unauthorized request", code: 401),
          type: err.type,
          response: err.response,
        ),
      );
      return;
    }

    if (data is Map<String, dynamic>) {
      final String message = data["message"] as String? ?? "Unknown API error";
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: NetworkFailure(
            message,
            code: response?.statusCode,
            details: data["error"],
          ),
          type: err.type,
          response: response,
        ),
      );
      return;
    }

    handler.next(err);
  }
}

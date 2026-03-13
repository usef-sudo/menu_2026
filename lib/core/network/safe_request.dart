import "package:dio/dio.dart";
import "package:menu_2026/core/errors/failure.dart";
import "package:menu_2026/core/network/api_result.dart";

Future<ApiResult<T>> safeRequest<T>(Future<T> Function() request) async {
  try {
    final data = await request();
    return Success<T>(data);
  } on DioException catch (error) {
    final wrapped = error.error;
    if (wrapped is Failure) {
      return Error<T>(wrapped);
    }
    final message = error.message ?? "Request failed";
    return Error<T>(
      NetworkFailure(message, code: error.response?.statusCode, details: error),
    );
  } catch (error) {
    return Error<T>(NetworkFailure("Unexpected error", details: error));
  }
}

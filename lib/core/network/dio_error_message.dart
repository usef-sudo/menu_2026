import "package:dio/dio.dart";

/// Best-effort user-facing message from API error responses.
String dioErrorMessage(DioException e) {
  final Object? data = e.response?.data;
  if (data is Map<dynamic, dynamic>) {
    final Object? msg = data["message"];
    if (msg != null && msg.toString().isNotEmpty) {
      return msg.toString();
    }
  }
  if (data is String && data.isNotEmpty) {
    return data;
  }
  return e.message?.isNotEmpty == true ? e.message! : "Request failed";
}

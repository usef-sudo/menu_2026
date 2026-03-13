class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String? message;
  final T data;

  static ApiEnvelope<T> fromDynamic<T>(
    dynamic payload,
    T Function(dynamic input) parseData,
  ) {
    if (payload is Map<String, dynamic> && payload.containsKey("data")) {
      return ApiEnvelope<T>(
        success: payload["success"] as bool? ?? true,
        message: payload["message"] as String?,
        data: parseData(payload["data"]),
      );
    }
    return ApiEnvelope<T>(
      success: true,
      message: null,
      data: parseData(payload),
    );
  }
}

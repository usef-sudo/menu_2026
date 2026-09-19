import "dart:convert";

String? jwtUserId(String? token) {
  if (token == null || token.isEmpty) {
    return null;
  }
  final List<String> parts = token.split(".");
  if (parts.length < 2) {
    return null;
  }
  try {
    final String normalized = base64Url.normalize(parts[1]);
    final Object? decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final String id =
        (decoded["id"] ?? decoded["userId"] ?? decoded["sub"] ?? "").toString();
    return id.isEmpty ? null : id;
  } catch (_) {
    return null;
  }
}

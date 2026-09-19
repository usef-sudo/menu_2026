Uri? normalizeHttpUrl(String raw) {
  String value = raw.trim();
  if (value.isEmpty) {
    return null;
  }
  if (value.startsWith("@")) {
    value = "https://www.instagram.com/${value.substring(1)}";
  } else if (!value.contains("://")) {
    value = "https://$value";
  }
  final Uri? uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) {
    return null;
  }
  if (uri.scheme != "http" && uri.scheme != "https") {
    return null;
  }
  return uri;
}

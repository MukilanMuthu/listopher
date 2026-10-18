/// the one spelling of a server url: trimmed, lowercase scheme and host, no trailing slash.
/// stored and parsed urls go through here so exact string match works.
/// not a url at all: returned trimmed, the login will fail on it.
String normalizeServerUrl(String url) {
  final text = url.trim();
  final uri = Uri.tryParse(text);
  if (uri == null) return text;
  final s = uri.toString(); // Uri already lowercases scheme and host
  return s.endsWith('/') ? s.substring(0, s.length - 1) : s;
}

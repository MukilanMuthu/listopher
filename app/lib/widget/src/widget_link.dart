/// return the target space from a widget launch URI.
String? widgetSpaceFromUri(Uri? uri) {
  if (uri?.scheme != 'listopher' || uri?.host != 'space') return null;
  final id = uri!.queryParameters['id'];
  return id == null || id.isEmpty ? null : id;
}

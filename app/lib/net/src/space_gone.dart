import 'package:http/http.dart' as http;

/// the server answered 404 for a space: it was deleted there (ADR 8).
class SpaceGone extends http.ClientException {
  SpaceGone(String spaceId) : super('space gone: $spaceId');
}

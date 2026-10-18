import 'package:http/http.dart' as http;

/// the server answered 403 to a join: wrong or rotated invite (ADR 8).
class BadInvite extends http.ClientException {
  BadInvite(String spaceId) : super('bad invite: $spaceId');
}

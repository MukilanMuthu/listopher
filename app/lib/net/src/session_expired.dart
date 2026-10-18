import 'package:http/http.dart' as http;

/// the server answered 401: my token is dead (revoked or expired). log in again.
class SessionExpired extends http.ClientException {
  SessionExpired() : super('session expired');
}

import 'package:shelf/shelf.dart';

// token from "Authorization: Bearer <token>". null if missing or other scheme.
String? bearerToken(Request req) {
  final h = req.headers['authorization'];
  if (h == null || !h.startsWith('Bearer ')) return null;
  return h.substring(7);
}

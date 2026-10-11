import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../accounts/accounts.dart';
import 'json_error.dart';
import 'json_response.dart';

// POST /auth/login {username, password}.
// 200 session, 401 bad credentials (same for unknown user), 429 locked.
Future<Response> loginRoute(Database db, Request req, DateTime now) async {
  final body = jsonDecode(await req.readAsString()) as Map<String, Object?>;
  try {
    final session = login(db, body['username'] as String, body['password'] as String, now);
    return session == null ? jsonError(401, 'bad credentials') : jsonResponse(200, session);
  } on LoginLocked {
    return jsonError(429, 'locked');
  }
}

import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../accounts/accounts.dart';
import 'bearer_token.dart';
import 'json_error.dart';

// run fn as the logged-in account. no / unknown token → 401.
Future<Response> authed(
  Database db,
  Request req,
  FutureOr<Response> Function(String me) fn,
) async {
  final token = bearerToken(req);
  final me = token == null ? null : authenticate(db, token);
  if (me == null) return jsonError(401, 'unauthorized');
  return fn(me);
}

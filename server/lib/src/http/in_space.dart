import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../spaces/spaces.dart';
import 'authed.dart';
import 'json_error.dart';

// authed + space checks. unknown space 404 (checked first, so deleted
// spaces say 404 to old members), not a member 403, ownerOnly and not owner 403.
Future<Response> inSpace(
  Database db,
  Request req,
  String spaceId,
  FutureOr<Response> Function(String me) fn, {
  bool ownerOnly = false,
}) =>
    authed(db, req, (me) {
      if (!spaceExists(db, spaceId)) return jsonError(404, 'no such space');
      final role = memberRole(db, spaceId, me);
      if (role == null) return jsonError(403, 'not a member');
      if (ownerOnly && role != 'owner') return jsonError(403, 'owner only');
      return fn(me);
    });

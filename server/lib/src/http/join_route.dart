import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../spaces/spaces.dart';
import 'authed.dart';
import 'json_error.dart';
import 'json_response.dart';

// POST /spaces/:id/join {invite}. 404 no space, 403 wrong invite.
Future<Response> joinRoute(Database db, Request req, String spaceId, DateTime now) =>
    authed(db, req, (me) async {
      final body = jsonDecode(await req.readAsString()) as Map<String, Object?>;
      if (!spaceExists(db, spaceId)) return jsonError(404, 'no such space');
      return joinSpace(db, spaceId, me, body['invite'] as String, now)
          ? jsonResponse(200, {})
          : jsonError(403, 'bad invite');
    });

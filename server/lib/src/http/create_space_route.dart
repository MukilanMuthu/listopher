import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../spaces/spaces.dart';
import 'authed.dart';
import 'json_error.dart';
import 'json_response.dart';

// POST /spaces {space_id}. caller becomes owner. 409 if id taken.
Future<Response> createSpaceRoute(Database db, Request req, DateTime now) =>
    authed(db, req, (me) async {
      final body = jsonDecode(await req.readAsString()) as Map<String, Object?>;
      final id = body['space_id'] as String;
      return createSpace(db, id, me, now)
          ? jsonResponse(201, {'space_id': id})
          : jsonError(409, 'space exists');
    });

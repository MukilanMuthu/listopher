import 'dart:convert';

import 'package:listopher_core/core.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../oplog/oplog.dart';
import 'in_space.dart';
import 'json_error.dart';
import 'json_response.dart';

// POST /spaces/:id/ops [op…]. member only. returns {op id: seq}.
// parse every op first: one bad op → 400 (by middleware), nothing stored.
// space_id must match url, user_id must be caller, else 403.
Future<Response> postOpsRoute(Database db, Request req, String spaceId, DateTime now) =>
    inSpace(db, req, spaceId, (me) async {
      final list = jsonDecode(await req.readAsString()) as List<Object?>;
      final ops = [for (final j in list) opFromJson(j as Map<String, Object?>)];
      if (ops.any((o) => o.spaceId != spaceId || o.userId != me)) {
        return jsonError(403, 'op not yours or wrong space');
      }
      return jsonResponse(200, appendOps(db, spaceId, ops, now));
    });

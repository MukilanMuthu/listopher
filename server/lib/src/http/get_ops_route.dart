import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../oplog/oplog.dart';
import 'in_space.dart';
import 'json_response.dart';

// GET /spaces/:id/ops?after=N. member only. missing or bad N → 0.
Future<Response> getOpsRoute(Database db, Request req, String spaceId) =>
    inSpace(db, req, spaceId, (me) {
      final after = int.tryParse(req.url.queryParameters['after'] ?? '') ?? 0;
      return jsonResponse(200, {'ops': opsAfter(db, spaceId, after)});
    });

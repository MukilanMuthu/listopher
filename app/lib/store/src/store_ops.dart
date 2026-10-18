import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:listopher_core/core.dart';

import 'app_db.dart';

/// keep ops pulled from the server (they carry a server seq).
/// op I already have (my own, or pulled twice): just set its seq.
Future<void> storeOps(AppDb db, List<Op> ops) {
  return db.transaction(() async {
    for (final op in ops) {
      final updated = await (db.update(db.ops)..where((o) => o.id.equals(op.id)))
          .write(OpsCompanion(serverSeq: Value(op.serverSeq)));
      if (updated > 0) continue;
      await db.into(db.ops).insert(OpsCompanion.insert(
            id: op.id,
            spaceId: op.spaceId,
            serverSeq: Value(op.serverSeq),
            json: jsonEncode(opToJson(op)),
          ));
    }
  });
}

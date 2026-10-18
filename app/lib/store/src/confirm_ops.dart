import 'package:drift/drift.dart';

import 'app_db.dart';

/// server took these ops: store their seq. {op id: server seq}. leaves the outbox.
Future<void> confirmOps(AppDb db, Map<String, int> seqs) {
  return db.transaction(() async {
    for (final e in seqs.entries) {
      await (db.update(db.ops)..where((o) => o.id.equals(e.key)))
          .write(OpsCompanion(serverSeq: Value(e.value)));
    }
  });
}

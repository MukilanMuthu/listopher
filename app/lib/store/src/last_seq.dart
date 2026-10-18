import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;

import 'app_db.dart';

/// last server seq of a space that I hold with no gap before it. 0 = none.
/// gap can happen: my push got seq 3 but ops 1-2 of others were not pulled yet.
/// ponytail: reads all seqs of the space; fine for shopping lists.
Future<int> lastSeq(AppDb db, String spaceId) async {
  final rows = await (db.select(db.ops)
        ..where((o) => o.spaceId.equals(spaceId) & o.serverSeq.isNotNull())
        ..orderBy([(o) => OrderingTerm.asc(o.serverSeq)]))
      .get();
  var last = 0;
  for (final r in rows) {
    if (r.serverSeq != last + 1) break; // gap: pull again from before it
    last = r.serverSeq!;
  }
  return last;
}

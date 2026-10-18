import 'package:drift/drift.dart' show innerJoin, BooleanExpressionOperators;

import 'app_db.dart';

/// live local seq of the newest op waiting in the outbox of any shared space, null = outbox empty.
/// goes UP when a local op is recorded; a confirm only lowers it or nulls it.
/// private spaces never count: their ops never leave the phone.
Stream<int?> watchNewestUnsentSeq(AppDb db) {
  // ops joined with their space; only shared spaces have a server url
  final query = db.select(db.ops).join([
    innerJoin(db.spaces, db.spaces.id.equalsExp(db.ops.spaceId)),
  ])
    ..where(db.ops.serverSeq.isNull() & db.spaces.serverUrl.isNotNull());
  // ponytail: loads the rows to find the max; lists are small
  return query.watch().map((rows) {
    int? newest;
    for (final r in rows) {
      final seq = r.readTable(db.ops).seq;
      if (newest == null || seq > newest) newest = seq;
    }
    return newest;
  }).distinct();
}

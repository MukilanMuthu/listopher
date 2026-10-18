import 'package:drift/drift.dart' show innerJoin, BooleanExpressionOperators;

import 'app_db.dart';

/// live count of ops waiting in the outbox of any shared space.
/// private spaces never count: their ops never leave the phone.
Stream<int> watchUnsentCount(AppDb db) {
  // ops joined with their space; only shared spaces have a server url
  final query = db.select(db.ops).join([
    innerJoin(db.spaces, db.spaces.id.equalsExp(db.ops.spaceId)),
  ])
    ..where(db.ops.serverSeq.isNull() & db.spaces.serverUrl.isNotNull());
  // ponytail: loads the rows to count them; lists are small
  return query.watch().map((rows) => rows.length).distinct();
}

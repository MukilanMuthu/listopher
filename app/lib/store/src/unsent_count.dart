import 'package:drift/drift.dart' show BooleanExpressionOperators;

import 'app_db.dart';

/// how many ops of the spaces on [serverUrl] are not on the server yet.
Future<int> unsentCount(AppDb db, String serverUrl) async {
  final spaces = await (db.select(db.spaces)..where((s) => s.serverUrl.equals(serverUrl))).get();
  final unsent = await (db.select(db.ops)
        ..where((o) => o.serverSeq.isNull() & o.spaceId.isIn([for (final s in spaces) s.id])))
      .get();
  return unsent.length; // ponytail: loads the rows to count them; lists are small
}

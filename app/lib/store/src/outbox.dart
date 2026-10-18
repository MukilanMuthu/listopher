import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm, BooleanExpressionOperators;

import 'package:listopher_core/core.dart';

import 'app_db.dart';

/// ops of one shared space not yet on the server, oldest first.
/// private space = StateError: its ops must never leave the phone.
Future<List<Op>> outbox(AppDb db, String spaceId) async {
  final space = await (db.select(db.spaces)..where((s) => s.id.equals(spaceId))).getSingleOrNull();
  if (space == null || space.private || space.serverUrl == null) {
    throw StateError('space $spaceId is not shared');
  }
  final rows = await (db.select(db.ops)
        ..where((o) => o.spaceId.equals(spaceId) & o.serverSeq.isNull())
        ..orderBy([(o) => OrderingTerm.asc(o.seq)]))
      .get();
  return [for (final r in rows) opFromJson(jsonDecode(r.json) as Map<String, Object?>)];
}

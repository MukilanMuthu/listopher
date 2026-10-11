import 'dart:convert';

import 'package:listopher_core/core.dart';
import 'package:sqlite3/sqlite3.dart';

import '../db/db.dart';

// store ops, all or nothing. returns {op id: server seq}.
// op id seen before → its old seq, nothing new stored (safe to resend).
// seq = max + 1 per space. never reads op bodies.
// ponytail: sqlite = one writer, fine for shopping lists. big scale → postgres sequences.
// ponytail: same op id in two spaces would hit the unique index → 500. uuids, so ignored.
Map<String, int> appendOps(Database db, String spaceId, List<Op> ops, DateTime now) =>
    inTransaction(db, () {
      final seqs = <String, int>{};
      for (final op in ops) {
        final known = db.select(
          'SELECT seq FROM ops WHERE space_id = ? AND id = ?',
          [spaceId, op.id],
        );
        if (known.isNotEmpty) {
          seqs[op.id] = known.first['seq'] as int; // resend
          continue;
        }
        final max = db.select(
          'SELECT COALESCE(MAX(seq), 0) AS m FROM ops WHERE space_id = ?',
          [spaceId],
        ).first['m'] as int;
        final seq = max + 1;
        // stored json carries the assigned seq so readers see it
        final json = opToJson(op)..['server_seq'] = seq;
        db.execute(
          'INSERT INTO ops (space_id, seq, id, account_id, json, received_at) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [spaceId, seq, op.id, op.userId, jsonEncode(json), now.toUtc().toIso8601String()],
        );
        seqs[op.id] = seq;
      }
      return seqs;
    });

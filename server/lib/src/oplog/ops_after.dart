import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

// ops with seq > after, oldest first. max 500 per call, client loops.
List<Object?> opsAfter(Database db, String spaceId, int after) => [
      for (final r in db.select(
        'SELECT json FROM ops WHERE space_id = ? AND seq > ? ORDER BY seq LIMIT 500',
        [spaceId, after],
      ))
        jsonDecode(r['json'] as String),
    ];

import 'package:drift/drift.dart';
import 'package:listopher_core/core.dart';

import 'app_db.dart';

/// make the owner profile of this phone. once only.
Future<void> createMe(AppDb db, String displayName) async {
  final name = displayName.trim();
  if (name.isEmpty) throw ArgumentError('name empty');
  // one me per phone
  final existing = await (db.select(db.users)..where((u) => u.isMe.equals(true)))
      .getSingleOrNull();
  if (existing != null) throw StateError('me already exists');
  await db.into(db.users).insert(
      UsersCompanion.insert(id: newId(), displayName: name, isMe: const Value(true)));
}

import 'package:drift/drift.dart';
import 'package:listopher_core/core.dart';

import 'app_db.dart';
import 'record.dart';

/// make the owner profile of this phone + its private space. once only.
Future<void> createMe(AppDb db, String displayName) async {
  final name = displayName.trim();
  if (name.isEmpty) throw ArgumentError('name empty');
  await db.transaction(() async {
    // one me per phone
    final existing = await (db.select(db.users)..where((u) => u.isMe.equals(true)))
        .getSingleOrNull();
    if (existing != null) throw StateError('me already exists');
    await db.into(db.users).insert(
        UsersCompanion.insert(id: newId(), displayName: name, isMe: const Value(true)));
    // private space comes with the user. stored name is a placeholder:
    // UI shows a localized label for private spaces, never this name.
    await record(db,
        spaceId: newId(), body: const SpaceCreate(name: 'private', private: true));
  });
}

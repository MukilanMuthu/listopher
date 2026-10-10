import 'app_db.dart';

/// live me user. null = not set up yet (UI asks for name).
Stream<UserRow?> watchMe(AppDb db) {
  return (db.select(db.users)..where((u) => u.isMe.equals(true)))
      .watchSingleOrNull();
}

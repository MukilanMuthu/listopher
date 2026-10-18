import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'app_db.dart';

/// is this user id me? true for the local id and any server account id.
Future<bool> isMe(AppDb db, String userId) async {
  // local id (private space)
  final local = await (db.select(db.users)
        ..where((u) => u.isMe.equals(true) & u.id.equals(userId)))
      .getSingleOrNull();
  if (local != null) return true;
  // account id on any server (shared spaces)
  final account = await (db.select(db.serverAccounts)
        ..where((a) => a.accountId.equals(userId)))
      .get();
  return account.isNotEmpty;
}

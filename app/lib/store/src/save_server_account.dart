import 'package:drift/drift.dart' show InsertMode;

import 'app_db.dart';

/// remember my account on one server. same url again = replace (re-login).
Future<void> saveServerAccount(
  AppDb db, {
  required String url,
  required String accountId,
  required String displayName,
  required String token,
}) {
  return db.into(db.serverAccounts).insert(
        ServerAccountRow(
            url: url, accountId: accountId, displayName: displayName, token: token),
        mode: InsertMode.insertOrReplace,
      );
}

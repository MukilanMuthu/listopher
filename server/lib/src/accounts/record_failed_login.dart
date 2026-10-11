import 'package:sqlite3/sqlite3.dart';

// count a bad password. 5th in a row → lock 15 min and restart the count.
void recordFailedLogin(Database db, String accountId, int failedBefore, DateTime now) {
  if (failedBefore + 1 >= 5) {
    final until = now.add(const Duration(minutes: 15)).toUtc().toIso8601String();
    db.execute(
      'UPDATE accounts SET failed_logins = 0, locked_until = ? WHERE id = ?',
      [until, accountId],
    );
  } else {
    db.execute(
      'UPDATE accounts SET failed_logins = ? WHERE id = ?',
      [failedBefore + 1, accountId],
    );
  }
}

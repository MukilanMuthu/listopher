import 'package:listopher_core/core.dart';
import 'package:sqlite3/sqlite3.dart';

// new invite token. old one dies. uuid v4 = 122 random bits, enough.
String rotateInvite(Database db, String spaceId) {
  final token = newId();
  db.execute('UPDATE spaces SET invite_token = ? WHERE id = ?', [token, spaceId]);
  return token;
}

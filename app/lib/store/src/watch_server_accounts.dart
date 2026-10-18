import 'app_db.dart';

/// live list of servers I am signed in to.
Stream<List<ServerAccountRow>> watchServerAccounts(AppDb db) {
  return db.select(db.serverAccounts).watch();
}

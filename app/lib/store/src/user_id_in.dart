import 'app_db.dart';

/// my user id inside [space]: the account id on its server (shared),
/// or the local id (private). ops and item rows blame this id.
Future<String> userIdIn(AppDb db, SpaceRow space, UserRow me) async {
  if (space.private) return me.id;
  final account = await (db.select(db.serverAccounts)
        ..where((a) => a.url.equals(space.serverUrl!)))
      .getSingle();
  return account.accountId;
}

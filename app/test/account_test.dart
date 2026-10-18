// logout and delete account end to end: phone db + real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database serverDb;
  late http.Client client;
  late AppDb db;
  late String accountId;
  late String token;

  setUp(() async {
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      final res = await handler(
          Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
    final r = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
    accountId = r.accountId;
    token = r.token;
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
    await saveServerAccount(db,
        url: 'http://srv', accountId: accountId, displayName: 'Alice', token: token);
  });
  tearDown(() async {
    await db.close();
    serverDb.close();
  });

  Future<List<String>> spaceNames() async =>
      [for (final s in await watchSpaces(db).first) s.name];

  test('logout: session dies on server, account and its spaces leave the phone', () async {
    await shareNewSpace(db, client, 'http://srv', 'Home');

    await logOut(db, client, 'http://srv');

    expect(await watchServerAccounts(db).first, isEmpty);
    expect(await spaceNames(), isNot(contains('Home')));
    expect(await spaceNames(), hasLength(1)); // private space stays
    await expectLater(listMySpaces(client, 'http://srv', token), throwsA(isA<http.ClientException>()));
  });

  test('logout keeps spaces of other servers', () async {
    await shareNewSpace(db, client, 'http://srv', 'Home');
    await db.into(db.spaces).insert(SpaceRow(
        id: 'other',
        name: 'Other',
        private: false,
        serverUrl: 'http://elsewhere',
        createdBy: 'x',
        createdAt: DateTime.now()));

    await logOut(db, client, 'http://srv');

    expect(await spaceNames(), contains('Other'));
  });

  test('preview: owned space with a member is transferred, a lone one is deleted', () async {
    await shareNewSpace(db, client, 'http://srv', 'Solo');
    await shareNewSpace(db, client, 'http://srv', 'Team');
    final ids = {for (final s in await watchSpaces(db).first) s.name: s.id};
    addUser(serverDb, 'bob', 'Bob', 'pw');
    final bob = serverDb.select("select id from accounts where display_name = 'Bob'").first['id'];
    serverDb.execute(
        "insert into members (space_id, account_id, role, joined_at) values ('${ids['Team']}', '$bob', 'member', 0)");

    final p = await deletePreview(client, 'http://srv', token);

    expect(p.transfer, [ids['Team']]);
    expect(p.delete, [ids['Solo']]);
  });

  test('delete account: gone on server, session dead, phone cleaned like logout', () async {
    await shareNewSpace(db, client, 'http://srv', 'Home');

    await deleteMyAccount(db, client, 'http://srv');

    expect(serverDb.select('select 1 from accounts where id = ?', [accountId]), isEmpty);
    expect(await watchServerAccounts(db).first, isEmpty);
    expect(await spaceNames(), hasLength(1));
    await expectLater(listMySpaces(client, 'http://srv', token), throwsA(isA<http.ClientException>()));
  });

  test('server refuses: phone keeps account and spaces', () async {
    await shareNewSpace(db, client, 'http://srv', 'Home');
    await saveServerAccount(db,
        url: 'http://srv', accountId: accountId, displayName: 'Alice', token: 'stale');

    await expectLater(deleteMyAccount(db, client, 'http://srv'), throwsA(isA<http.ClientException>()));

    expect(await watchServerAccounts(db).first, hasLength(1));
    expect(await spaceNames(), contains('Home'));
  });
}

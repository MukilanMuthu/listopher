// delete space end to end: two phone dbs, same account, one real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';
import 'package:listopher_core/core.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database serverDb;
  late http.Client client;
  late String accountId;
  late String token;
  late AppDb a; // owner phone
  late AppDb b; // member phone

  // one login for the whole file: argon2 is slow
  setUpAll(() async {
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
  });
  tearDownAll(() => serverDb.close());

  Future<AppDb> phone() async {
    final db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
    await saveServerAccount(db,
        url: 'http://srv', accountId: accountId, displayName: 'Alice', token: token);
    return db;
  }

  setUp(() async {
    a = await phone();
    b = await phone();
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  // shared space on A with one item, synced, then B holds it too (join comes later)
  Future<String> sharedOnBoth(String name) async {
    await shareNewSpace(a, client, 'http://srv', name);
    final id = (await watchSpaces(a).first).firstWhere((s) => s.name == name).id;
    await record(a,
        spaceId: id,
        itemId: newId(),
        body: ItemAdd(name: 'milk', quantity: null, unit: null, note: null, requestedBy: accountId));
    await sync(a, client);
    await b.into(b.spaces).insert(SpaceRow(
        id: id,
        name: '?',
        private: false,
        serverUrl: 'http://srv',
        createdBy: accountId,
        createdAt: DateTime.now()));
    await sync(b, client);
    return id;
  }

  Future<List<String>> spaceNames(AppDb db) async =>
      [for (final s in await watchSpaces(db).first) s.name];

  test('owner deletes: gone on server and on owner phone, ops and items too', () async {
    final id = await sharedOnBoth('Home');
    await deleteSharedSpace(a, client, id);

    expect(await spaceNames(a), isNot(contains('Home')));
    expect(await a.select(a.items).get(), isEmpty);
    expect(await a.select(a.ops).get(), hasLength(1)); // only the private space's op is left
    expect(serverDb.select('select 1 from spaces where id = ?', [id]), isEmpty);
  });

  test('member sync removes the deleted space and still syncs the others', () async {
    final gone = await sharedOnBoth('Gone');
    final kept = await sharedOnBoth('Kept');
    // B has unsent work in the doomed space: it dies with it
    await record(b,
        spaceId: gone,
        itemId: newId(),
        body: ItemAdd(name: 'eggs', quantity: null, unit: null, note: null, requestedBy: accountId));
    await deleteSharedSpace(a, client, gone);
    await record(a,
        spaceId: kept,
        itemId: newId(),
        body: ItemAdd(name: 'bread', quantity: null, unit: null, note: null, requestedBy: accountId));
    await sync(a, client);

    await sync(b, client); // does not throw

    expect(await spaceNames(b), isNot(contains('Gone')));
    expect(await spaceNames(b), contains('Kept'));
    final items = await b.select(b.items).get();
    expect({for (final i in items) i.spaceId}, {kept});
    expect(items.map((i) => i.name), containsAll(['milk', 'bread']));
    expect([for (final o in await b.select(b.ops).get()) o.spaceId], isNot(contains(gone)));
  });
}

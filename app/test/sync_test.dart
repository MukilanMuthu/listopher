// sync end to end: two phone dbs, same account, one real server handler, in-process.
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
  late AppDb a; // phone A
  late AppDb b; // phone B, same account

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

  Future<List<String>> names(AppDb db) async =>
      [for (final i in await watchItems(db).first) i.name];

  // phone B knows the space id only (join comes later): bare row, sync fills it in
  Future<void> bareSpace(AppDb db, String id) => db.into(db.spaces).insert(SpaceRow(
      id: id,
      name: '?',
      private: false,
      serverUrl: 'http://srv',
      createdBy: accountId,
      createdAt: DateTime.now()));

  Future<String> sharedOnA() async {
    await shareNewSpace(a, client, 'http://srv', 'Home');
    return (await watchSpaces(a).first).firstWhere((s) => !s.private).id;
  }

  Future<void> add(AppDb db, String spaceId, String name) => record(db,
      spaceId: spaceId, itemId: newId(), body: ItemAdd(name: name, quantity: null, unit: null, note: null, requestedBy: accountId));

  test('item added on A shows on B after sync', () async {
    final id = await sharedOnA();
    await add(a, id, 'milk');
    await sync(a, client);
    await bareSpace(b, id);
    await sync(b, client);

    expect(await names(b), ['milk']);
    expect((await watchSpaces(b).first).firstWhere((s) => s.id == id).name, 'Home');
  });

  test('pulls past the 500-op page', () async {
    final id = await sharedOnA();
    for (var i = 0; i < 600; i++) {
      await add(a, id, 'item $i');
    }
    await sync(a, client);
    await bareSpace(b, id);
    await sync(b, client);

    expect(await names(b), hasLength(600));
  });

  test('lost response: resend makes no duplicates', () async {
    final id = await sharedOnA();
    await add(a, id, 'milk');
    // server takes the ops, answer is lost
    final lossy = MockClient((req) async {
      final res = await client.send(http.Request(req.method, req.url)
        ..body = req.body
        ..headers.addAll(req.headers));
      await res.stream.drain<void>();
      throw http.ClientException('lost');
    });
    await expectLater(sync(a, lossy), throwsA(isA<http.ClientException>()));
    expect(await outbox(a, id), hasLength(1)); // phone still thinks it is unsent

    await sync(a, client);
    expect(await outbox(a, id), isEmpty);
    expect(await names(a), ['milk']);
    final n = serverDb.select('select count(*) c from ops where space_id = ?', [id]);
    expect(n.single['c'], 2); // create + add, once each
  });

  test('pending op goes on top of newer confirmed ops (last writer wins)', () async {
    final id = await sharedOnA();
    final item = newId();
    await record(a,
        spaceId: id,
        itemId: item,
        body: ItemAdd(name: 'milk', quantity: null, unit: null, note: null, requestedBy: accountId));
    await sync(a, client);
    await bareSpace(b, id);
    await sync(b, client);

    // B checks and syncs; A unchecks offline after that
    await record(b, spaceId: id, itemId: item, body: ItemCheck(fulfilledBy: accountId));
    await sync(b, client);
    await record(a, spaceId: id, itemId: item, body: const ItemUncheck());
    expect((await watchItems(a).first).single.checked, false); // visible at once

    await sync(a, client);
    await sync(b, client);
    expect((await watchItems(a).first).single.checked, false);
    expect((await watchItems(b).first).single.checked, false);
  });

  test('pull failing after a push leaves no hole: next sync gets missed ops', () async {
    final id = await sharedOnA();
    await sync(a, client);
    await bareSpace(b, id);
    await add(b, id, 'from B');
    await sync(b, client);
    await add(a, id, 'from A'); // gets seq 3 on the server, B's op is seq 2
    final noPull = MockClient((req) async {
      if (req.method == 'GET') throw http.ClientException('down');
      return client.send(http.Request(req.method, req.url)
            ..body = req.body
            ..headers.addAll(req.headers))
          .then(http.Response.fromStream);
    });
    await expectLater(sync(a, noPull), throwsA(isA<http.ClientException>()));

    await sync(a, client);
    expect(await names(a), unorderedEquals(['from A', 'from B']));
  });
}

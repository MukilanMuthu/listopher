// check / uncheck must reach the other phone: two accounts, one shared space,
// real server handler in-process. manual sync and auto sync.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/autosync/autosync.dart';
import 'package:listopher/join/join.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';
import 'package:listopher_core/core.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // auto sync listens to app lifecycle
  late Database serverDb;
  late http.Client client;
  late LoginOk alice;
  late LoginOk bob;
  late AppDb a;
  late AppDb b;
  late String space;
  late String item; // added by alice

  setUpAll(() async {
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    addUser(serverDb, 'bob', 'Bob', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      final res = await handler(
          Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
    alice = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
    bob = await login(client, 'http://srv', 'bob', 'pw') as LoginOk;
  });
  tearDownAll(() => serverDb.close());

  Future<AppDb> phone(LoginOk who) async {
    final db = AppDb(NativeDatabase.memory());
    await createMe(db, who.displayName);
    await saveServerAccount(db,
        url: 'http://srv',
        accountId: who.accountId,
        displayName: who.displayName,
        token: who.token);
    return db;
  }

  Future<ItemRow> row(AppDb db) async =>
      (await watchItems(db).first).firstWhere((i) => i.id == item);

  // a shares a space, b joins, a adds one item, both synced
  setUp(() async {
    a = await phone(alice);
    b = await phone(bob);
    await shareNewSpace(a, client, 'http://srv', 'Home');
    space = (await watchSpaces(a).first).firstWhere((s) => !s.private).id;
    await joinByLink(b, client, parseInviteLink(await makeInviteLink(a, client, space)));
    item = newId();
    await record(a,
        spaceId: space,
        itemId: item,
        body: ItemAdd(
            name: 'milk', quantity: null, unit: null, note: null, requestedBy: alice.accountId));
    await sync(a, client);
    await sync(b, client);
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  test('a checks an item a added: b sees it checked by a', () async {
    await record(a, spaceId: space, itemId: item, body: const ItemCheck());
    await sync(a, client);
    await sync(b, client);
    final r = await row(b);
    expect(r.checked, isTrue);
    expect(r.checkedBy, alice.accountId);
  });

  test('b checks an item a added: a sees it checked by b', () async {
    await record(b, spaceId: space, itemId: item, body: const ItemCheck());
    await sync(b, client);
    await sync(a, client);
    final r = await row(a);
    expect(r.checked, isTrue);
    expect(r.checkedBy, bob.accountId);
  });

  test('uncheck reaches the other phone', () async {
    await record(a, spaceId: space, itemId: item, body: const ItemCheck());
    await sync(a, client);
    await sync(b, client);
    await record(b, spaceId: space, itemId: item, body: const ItemUncheck());
    await sync(b, client);
    await sync(a, client);
    final r = await row(a);
    expect(r.checked, isFalse);
    expect(r.checkedBy, isNull);
  });

  test('auto sync sends a check after the debounce and pulls it on the other phone', () async {
    final autoA = startAutoSync(a, client,
        onError: (_) {},
        poll: const Duration(milliseconds: 300),
        debounce: const Duration(milliseconds: 100));
    final autoB = startAutoSync(b, client,
        onError: (_) {},
        poll: const Duration(milliseconds: 300),
        debounce: const Duration(milliseconds: 100));
    addTearDown(() async {
      autoA.stop();
      autoB.stop();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await record(a, spaceId: space, itemId: item, body: const ItemCheck());
    var seen = false;
    for (var i = 0; i < 60 && !seen; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      seen = (await row(b)).checked;
    }
    expect(seen, isTrue);
    expect((await row(b)).checkedBy, alice.accountId);
  });
}

// restore after reinstall: fresh phone db + same account = shared spaces come back.
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

  test('wiped phone logs in again: shared spaces and items are back, private is not', () async {
    // old phone: shared space with an item
    final old = await phone();
    await shareNewSpace(old, client, 'http://srv', 'Home');
    final id = (await watchSpaces(old).first).firstWhere((s) => !s.private).id;
    await record(old,
        spaceId: id,
        itemId: newId(),
        body: ItemAdd(name: 'milk', quantity: null, unit: null, note: null, requestedBy: accountId));
    await sync(old, client);
    await old.close();

    // fresh install: empty store, log in again, restore
    final fresh = await phone();
    await restoreSpaces(fresh, client, 'http://srv');
    await restoreSpaces(fresh, client, 'http://srv'); // twice: no duplicates

    final shared = (await watchSpaces(fresh).first).where((s) => !s.private).toList();
    expect(shared.map((s) => s.name), ['Home']);
    expect([for (final i in await watchItems(fresh).first) i.name], ['milk']);
    await fresh.close();
  });

  test('one space fails: others still restored, one error at the end, bare row is not owner', () async {
    final old = await phone();
    await shareNewSpace(old, client, 'http://srv', 'Home');
    await shareNewSpace(old, client, 'http://srv', 'Work');
    final spaces = (await watchSpaces(old).first).where((s) => !s.private).toList();
    final home = spaces.firstWhere((s) => s.name == 'Home').id;
    await old.close();

    // pulling Home dies, everything else works
    final homeDown = MockClient((req) async {
      if (req.method == 'GET' && req.url.path == '/spaces/$home/ops') {
        throw http.ClientException('down');
      }
      final res = await client.send(http.Request(req.method, req.url)
        ..body = req.body
        ..headers.addAll(req.headers));
      return http.Response.fromStream(res);
    });
    final fresh = await phone();
    await expectLater(restoreSpaces(fresh, homeDown, 'http://srv'), throwsA(isA<SyncFailed>()));

    final got = {for (final s in await watchSpaces(fresh).first) s.id: s};
    expect(got.values.where((s) => s.name == 'Work'), hasLength(1)); // restored despite Home
    expect(got[home]!.createdBy, ''); // placeholder: nobody looks like the owner yet

    await restoreSpaces(fresh, client, 'http://srv'); // retry heals
    expect((await watchSpaces(fresh).first).where((s) => s.id == home).single.name, 'Home');
    await fresh.close();
  });
}

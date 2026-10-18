// invite + join end to end: owner phone and joiner phone, one real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
  late Database serverDb;
  late http.Client client;
  late LoginOk alice;
  late LoginOk bob;
  late AppDb owner; // phone of alice
  late AppDb joiner; // phone of bob
  late String spaceId;

  // one login each for the whole file: argon2 is slow
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

  // owner has a shared space "Home" holding one item, already on the server
  setUp(() async {
    owner = await phone(alice);
    joiner = await phone(bob);
    await shareNewSpace(owner, client, 'http://srv', 'Home');
    spaceId = (await watchSpaces(owner).first).firstWhere((s) => !s.private).id;
    await record(owner,
        spaceId: spaceId,
        itemId: newId(),
        body: ItemAdd(
            name: 'milk', quantity: null, unit: null, note: null, requestedBy: alice.accountId));
    await sync(owner, client);
  });
  tearDown(() async {
    await owner.close();
    await joiner.close();
  });

  // names of this test's space on a phone (the server is shared by all tests,
  // and restore brings back every space of the account, so filter by id)
  Future<List<String>> sharedNames(AppDb db) async =>
      [for (final s in await watchSpaces(db).first) if (s.id == spaceId) s.name];

  test('joiner with a valid link gets the space and its items', () async {
    final link = await makeInviteLink(owner, client, spaceId);
    await joinByLink(joiner, client, parseInviteLink(link));
    expect(await sharedNames(joiner), ['Home']);
    expect([for (final i in await watchItems(joiner).first) i.name], ['milk']);
  });

  test('joining twice changes nothing', () async {
    final link = parseInviteLink(await makeInviteLink(owner, client, spaceId));
    await joinByLink(joiner, client, link);
    await joinByLink(joiner, client, link);
    expect(await sharedNames(joiner), ['Home']);
  });

  test('a new invite kills the old link', () async {
    final old = parseInviteLink(await makeInviteLink(owner, client, spaceId));
    final fresh = parseInviteLink(await makeInviteLink(owner, client, spaceId));
    await expectLater(joinByLink(joiner, client, old), throwsA(isA<BadInvite>()));
    expect(await sharedNames(joiner), isEmpty); // nothing half-added
    await joinByLink(joiner, client, fresh);
    expect(await sharedNames(joiner), ['Home']);
  });

  test('a made-up invite is refused', () async {
    await makeInviteLink(owner, client, spaceId);
    final bad = InviteLink('http://srv', spaceId, 'nope');
    await expectLater(joinByLink(joiner, client, bad), throwsA(isA<BadInvite>()));
  });

  test('only the owner can make a link', () async {
    final link = parseInviteLink(await makeInviteLink(owner, client, spaceId));
    await joinByLink(joiner, client, link);
    final id = (await watchSpaces(joiner).first).firstWhere((s) => !s.private).id;
    await expectLater(makeInviteLink(joiner, client, id), throwsA(isA<http.ClientException>()));
  });
}

// member names cached on sync: two phones, one real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/join/join.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database serverDb;
  late http.Client client;
  late LoginOk alice;
  late LoginOk bob;

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

  test('sync caches member names; they stay after the server is gone', () async {
    final a = await phone(alice);
    final b = await phone(bob);
    addTearDown(a.close);
    addTearDown(b.close);
    await shareNewSpace(a, client, 'http://srv', 'Home');
    final id = (await watchSpaces(a).first).firstWhere((s) => !s.private).id;
    await joinByLink(b, client, parseInviteLink(await makeInviteLink(a, client, id)));
    await sync(b, client);
    final expected = {alice.accountId: 'Alice', bob.accountId: 'Bob'};
    expect((await watchMembers(b).first)[id], expected);
    // offline: the cache is local, no client needed to read it
    expect((await watchMembers(b).first)[id], expected);
  });
}

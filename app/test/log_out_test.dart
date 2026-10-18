// logging out: dead token, unsent ops, chunked push. phone db + real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher_core/core.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDb db;
  late Database serverDb;
  late http.Client client;
  late LoginOk alice;
  final posts = <Uri>[]; // every POST the phone made

  setUp(() async {
    posts.clear();
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      if (req.method == 'POST') posts.add(req.url);
      final res = await handler(
          Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
    alice = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
    await saveServerAccount(db,
        url: 'http://srv', accountId: alice.accountId, displayName: 'Alice', token: alice.token);
  });
  tearDown(() async {
    await db.close();
    serverDb.close();
  });

  Future<String> sharedSpace() async {
    await shareNewSpace(db, client, 'http://srv', 'Home');
    return (await watchSpaces(db).first).firstWhere((s) => !s.private).id;
  }

  Future<void> add(String spaceId, int n) async {
    for (var i = 0; i < n; i++) {
      await record(db,
          spaceId: spaceId,
          itemId: newId(),
          body: ItemAdd(
              name: 'item $i',
              quantity: null,
              unit: null,
              note: null,
              requestedBy: alice.accountId));
    }
  }

  final down = MockClient((_) async => throw http.ClientException('down'));

  test('flushServer sends the outbox; nothing left unsent', () async {
    final id = await sharedSpace();
    await add(id, 3);
    expect(await unsentCount(db, 'http://srv'), 3);

    await flushServer(db, client, 'http://srv');

    expect(await unsentCount(db, 'http://srv'), 0);
  });

  test('flushServer offline: no throw, ops still counted as unsent', () async {
    final id = await sharedSpace();
    await add(id, 2);

    await flushServer(db, down, 'http://srv');

    expect(await unsentCount(db, 'http://srv'), 2);
  });

  test('push goes in chunks of 200 ops', () async {
    final id = await sharedSpace();
    await add(id, 450);
    posts.clear();

    await pushSpace(db, client, id);

    expect(posts.where((u) => u.path.endsWith('/ops')), hasLength(3)); // 200+200+50
    expect(await outbox(db, id), isEmpty);
  });

  test('dead token (401) still logs out locally', () async {
    await shareNewSpace(db, client, 'http://srv', 'Home');
    await logout(client, 'http://srv', alice.token); // session revoked behind our back

    await logOut(db, client, 'http://srv');

    expect(await watchServerAccounts(db).first, isEmpty);
    expect((await watchSpaces(db).first).where((s) => !s.private), isEmpty);
  });
}

// sharing a new space end to end: phone db + real server handler, in-process.
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
  late AppDb db;
  late Database serverDb;
  late http.Client client;

  setUp(() async {
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      final res = await handler(
          Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
    // log in as the app does
    final r = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
    await saveServerAccount(db,
        url: 'http://srv', accountId: r.accountId, displayName: 'Alice', token: r.token);
  });
  tearDown(() async {
    await db.close();
    serverDb.close();
  });

  Future<SpaceRow> shared() async =>
      (await watchSpaces(db).first).firstWhere((s) => !s.private);

  test('new shared space exists on phone and server, create op has a seq', () async {
    expect(await shareNewSpace(db, client, 'http://srv', 'Home'), true);

    final space = await shared();
    expect(space.name, 'Home');
    expect(space.serverUrl, 'http://srv');
    expect(await outbox(db, space.id), isEmpty); // all confirmed
    final row = await db.select(db.ops).get().then((r) => r.firstWhere((o) => o.spaceId == space.id));
    expect(row.serverSeq, 1);
    // server: alice owns it
    final owner = serverDb.select('select owner_id from spaces where id = ?', [space.id]);
    expect(owner.single['owner_id'], (await watchServerAccounts(db).first).single.accountId);
    final ops = serverDb.select('select seq from ops where space_id = ?', [space.id]);
    expect(ops.length, 1);
  });

  test('server down: nothing is created on the phone', () async {
    final down = MockClient((_) async => throw http.ClientException('down'));
    expect(await shareNewSpace(db, down, 'http://srv', 'Home'), false);
    expect((await watchSpaces(db).first).where((s) => !s.private), isEmpty);
  });

  test('push fails after create: space stays local, op waits in outbox', () async {
    // create works, ops post dies
    final flaky = MockClient((req) async {
      if (req.url.path.endsWith('/ops')) throw http.ClientException('down');
      return client.send(http.Request(req.method, req.url)
            ..body = req.body
            ..headers.addAll(req.headers))
          .then(http.Response.fromStream);
    });
    expect(await shareNewSpace(db, flaky, 'http://srv', 'Home'), true);
    expect(await outbox(db, (await shared()).id), hasLength(1));
  });

  test('dead token: share throws SessionExpired, nothing is created', () async {
    final token = (await watchServerAccounts(db).first).single.token;
    await logout(client, 'http://srv', token); // session revoked

    await expectLater(shareNewSpace(db, client, 'http://srv', 'Home'),
        throwsA(isA<SessionExpired>()));
    expect((await watchSpaces(db).first).where((s) => !s.private), isEmpty);
  });

  test('no account on that server fails', () async {
    expect(await shareNewSpace(db, client, 'http://other', 'Home'), false);
  });
}

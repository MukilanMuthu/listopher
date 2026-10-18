// login goes through the real server handler, in-process. no mock server.
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher_core/core.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database serverDb;
  late http.Client client;

  setUp(() {
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    final handler = buildHandler(serverDb);
    // http client that calls the shelf handler directly
    client = MockClient((req) async {
      final res = await handler(Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
  });
  tearDown(() => serverDb.close());

  test('right password returns the account', () async {
    final r = await login(client, 'http://srv', 'alice', 'pw');
    expect(r, isA<LoginOk>());
    r as LoginOk;
    expect(r.displayName, 'Alice');
    expect(r.token, isNotEmpty);
    expect(r.accountId, isNotEmpty);
  });

  test('wrong password is wrongCredentials', () async {
    final r = await login(client, 'http://srv', 'alice', 'nope');
    expect((r as LoginFailed).reason, LoginFailure.wrongCredentials);
  });

  test('too many bad passwords lock the account', () async {
    for (var i = 0; i < 20; i++) {
      await login(client, 'http://srv', 'alice', 'nope');
    }
    final r = await login(client, 'http://srv', 'alice', 'pw');
    expect((r as LoginFailed).reason, LoginFailure.locked);
  });

  test('no server is unreachable', () async {
    final down = MockClient((_) async => throw http.ClientException('down'));
    final r = await login(down, 'http://srv', 'alice', 'pw');
    expect((r as LoginFailed).reason, LoginFailure.unreachable);
  });

  group('sharing', () {
    late String token;
    setUp(() async {
      final r = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
      token = r.token;
    });

    Op op(String space, String user) => Op(
          id: newId(),
          spaceId: space,
          userId: user, itemId: null,
          clientTime: DateTime.utc(2026), serverSeq: null,
          body: const SpaceCreate(name: 'Home', private: false),
        );

    test('created space takes ops and returns their seqs', () async {
      final me = (await login(client, 'http://srv', 'alice', 'pw') as LoginOk).accountId;
      final space = newId();
      await createSpace(client, 'http://srv', token, space);
      final a = op(space, me);
      final seqs = await pushOps(client, 'http://srv', token, space, [a]);
      expect(seqs, {a.id: 1});
    });

    test('same space id twice fails', () async {
      final space = newId();
      await createSpace(client, 'http://srv', token, space);
      expect(createSpace(client, 'http://srv', token, space), throwsException);
    });

    test('push to a space I am not in fails', () async {
      expect(pushOps(client, 'http://srv', token, newId(), []), throwsException);
    });
  });
}

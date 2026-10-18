// login goes through the real server handler, in-process. no mock server.
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
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
      final res = await handler(Request(req.method, req.url, body: req.body));
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
}

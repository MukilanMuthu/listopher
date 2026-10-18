// background sync back-off: fake clock, server handler that fails on demand.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/bgsync/bgsync.dart';
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
  late AppDb db;
  var requests = 0; // all requests so far
  var failing = false; // true = server answers 500
  final t0 = DateTime(2026, 1, 1, 12); // fake clock start

  setUpAll(() {
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      requests++;
      if (failing) return http.Response('boom', 500);
      final res = await handler(
          Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
  });
  tearDownAll(() => serverDb.close());

  // fresh phone with one shared space
  setUp(() async {
    failing = false;
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
    final r = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
    await saveServerAccount(db,
        url: 'http://srv', accountId: r.accountId, displayName: 'Alice', token: r.token);
    await shareNewSpace(db, client, 'http://srv', 'Home');
    requests = 0;
    failing = true;
  });
  tearDown(() => db.close());

  // run the job [min] minutes after t0; returns how many requests it made
  Future<int> runAt(int min) async {
    final before = requests;
    await backgroundSync(db, client, t0.add(Duration(minutes: min)));
    return requests - before;
  }

  Future<int> failures() async => (await readBgSyncState(db)).failures;

  test('skip windows are 15 / 30 / 60 / 60 min, then a good sync resets', () async {
    expect(await runAt(0), greaterThan(0));
    expect(await failures(), 1);

    expect(await runAt(14), 0); // inside 15 min: no network
    expect(await runAt(15), greaterThan(0));
    expect(await failures(), 2);

    expect(await runAt(15 + 29), 0); // inside 30 min
    expect(await runAt(15 + 30), greaterThan(0));
    expect(await failures(), 3);

    expect(await runAt(45 + 59), 0); // inside 1 h
    expect(await runAt(45 + 60), greaterThan(0));
    expect(await failures(), 4);

    expect(await runAt(105 + 59), 0); // 4th fail: still 1 h
    expect(await runAt(105 + 60), greaterThan(0));
    expect(await failures(), 5);

    failing = false; // server back
    expect(await runAt(165 + 60), greaterThan(0));
    final s = await readBgSyncState(db);
    expect(s.failures, 0);
    expect(s.lastFailAt, isNull);
    expect(s.lastError, isNotNull); // kept for the user to see
  });

  test('good foreground sync resets failures', () async {
    await backgroundSync(db, client, t0);
    expect(await failures(), 1);
    failing = false;
    await sync(db, client);
    final s = await readBgSyncState(db);
    expect(s.failures, 0);
    expect(s.lastFailAt, isNull);
  });

  test('clock moved back: job still runs', () async {
    await backgroundSync(db, client, t0);
    final before = requests;
    await backgroundSync(db, client, t0.subtract(const Duration(days: 1)));
    expect(requests, greaterThan(before));
  });

  test('clearBgSyncError only clears the error the user saw', () async {
    await saveBgSyncFailure(db, t0, 'new');
    await clearBgSyncError(db, 'old');
    expect((await readBgSyncState(db)).lastError, 'new');
    await clearBgSyncError(db, 'new');
    expect((await readBgSyncState(db)).lastError, isNull);
  });

  test('never throws', () async {
    await backgroundSync(db, client, t0);
    await backgroundSync(db, client, t0.add(const Duration(hours: 5)));
  });
}

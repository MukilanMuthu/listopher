// auto sync: open, resume, poll, debounce, no overlap, error dedupe.
// two phones, same account, real server handler in-process, real (short) timers.
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/autosync/autosync.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';
import 'package:listopher_core/core.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late Database serverDb;
  late http.Client client; // wraps the handler: counts requests, can slow or fail them
  late String accountId;
  late String token;
  late AppDb a; // phone under auto sync
  late AppDb b; // other phone, synced by hand
  late String spaceId;
  var requests = 0; // all requests so far
  var pushes = 0; // POST .../ops requests: one per push
  var inFlight = 0; // requests running right now
  var maxInFlight = 0; // most at once
  var delay = Duration.zero; // added to every request
  var failing = false; // true = server "down"
  AutoSync? auto;

  // short timers keep the tests fast
  const poll = Duration(milliseconds: 300);
  const debounce = Duration(milliseconds: 100);

  setUpAll(() async {
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      requests++;
      if (req.method == 'POST' && req.url.path.endsWith('/ops')) pushes++;
      inFlight++;
      if (inFlight > maxInFlight) maxInFlight = inFlight;
      try {
        await Future<void>.delayed(delay);
        if (failing) throw http.ClientException('down');
        final res = await handler(
            Request(req.method, req.url, body: req.body, headers: req.headers));
        return http.Response(await res.readAsString(), res.statusCode);
      } finally {
        inFlight--;
      }
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

  Future<void> addItem(AppDb db, String name) => record(db,
      spaceId: spaceId,
      itemId: newId(),
      body: ItemAdd(
          name: name, quantity: null, unit: null, note: null, requestedBy: accountId));

  Future<List<String>> names(AppDb db) async =>
      [for (final i in await watchItems(db).first) i.name]..sort();

  // wait (real time) until [ok] is true; fail after 3 s
  Future<void> eventually(Future<bool> Function() ok) async {
    for (var i = 0; i < 60; i++) {
      if (await ok()) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    fail('condition not met in time');
  }

  // the engine walks these steps; the test binding does not, and the listener asserts on jumps
  void lifecycle(List<AppLifecycleState> steps) {
    for (final step in steps) {
      binding.handleAppLifecycleStateChanged(step);
    }
  }

  Future<void> wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

  AutoSync start(AppDb db, {void Function(Object)? onError}) => auto = startAutoSync(
      db, client,
      onError: onError ?? (_) {}, poll: poll, debounce: debounce);

  // a shared space "Home" known to both phones; b already holds its ops
  setUp(() async {
    a = await phone();
    b = await phone();
    await shareNewSpace(b, client, 'http://srv', 'Home');
    spaceId = (await watchSpaces(b).first).firstWhere((s) => !s.private).id;
    await addItem(b, 'milk');
    await sync(b, client);
    // a only knows the space id, like a fresh phone
    await a.into(a.spaces).insert(SpaceRow(
        id: spaceId,
        name: '?',
        private: false,
        serverUrl: 'http://srv',
        createdBy: accountId,
        createdAt: DateTime.now()));
    requests = 0;
    maxInFlight = 0;
    delay = Duration.zero;
    failing = false;
  });
  tearDown(() async {
    auto?.stop();
    auto = null;
    await wait(300); // let a running sync finish before the db closes
    await a.close();
    await b.close();
  });

  test('syncs on start', () async {
    start(a);
    await eventually(() async => (await names(a)).contains('milk'));
  });

  test('a local change is sent after the debounce, many changes in one burst', () async {
    start(a);
    await wait(200); // opening sync done
    pushes = 0;
    // three quick changes -> the timer restarts each time -> one push
    await addItem(a, 'eggs');
    await addItem(a, 'rice');
    await addItem(a, 'tea');
    await eventually(() async {
      await sync(b, client);
      return (await names(b)).length == 4;
    });
    expect(await names(b), ['eggs', 'milk', 'rice', 'tea']);
    expect(pushes, 1);
  });

  test('polls while in the foreground', () async {
    start(a);
    await wait(200);
    await addItem(b, 'bread');
    await sync(b, client);
    await eventually(() async => (await names(a)).contains('bread'));
  });

  test('stops polling in the background and syncs again on resume', () async {
    start(a);
    await wait(200);
    lifecycle([AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]);
    await addItem(b, 'bread');
    await sync(b, client);
    final quietRequests = requests; // b's own sync is counted too
    await wait(poll.inMilliseconds * 3);
    expect(requests, quietRequests, reason: 'no polling while paused');
    expect(await names(a), isNot(contains('bread')));

    lifecycle([AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]);
    await eventually(() async => (await names(a)).contains('bread'));
  });

  test('never two syncs at once; a change during a run is sent right after', () async {
    delay = const Duration(milliseconds: 40);
    final s = start(a);
    // manual taps and a local change while the opening sync runs
    final manual = [s.now(), s.now(), s.now()];
    await addItem(a, 'eggs');
    await Future.wait(manual);
    await wait(500); // debounce, then the rerun, all while b stays out of it
    expect(maxInFlight, 1);
    await sync(b, client);
    expect(await names(b), contains('eggs'));
  });

  test('the manual sync throws, the automatic one reports each new error once', () async {
    failing = true;
    final errors = <Object>[];
    final s = start(a, onError: errors.add);
    await wait(poll.inMilliseconds * 3 + 100); // opening + several polls, all failing
    expect(errors, hasLength(1));
    await expectLater(s.now(), throwsA(isA<SyncFailed>()));

    // server back, then down again: a repeated failure after success shows again
    failing = false;
    await s.now();
    failing = true;
    await wait(poll.inMilliseconds + 100);
    expect(errors, hasLength(2));
  });
}

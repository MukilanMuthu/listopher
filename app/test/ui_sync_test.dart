// sync trigger in the UI: on app open and the Sync button. real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';
import 'package:listopher/ui/ui.dart';
import 'package:listopher_core/core.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database serverDb;
  late http.Client client;
  late String accountId;
  late String token;
  late AppDb a; // other phone
  late AppDb b; // phone under test, same account

  // one login for the whole file: argon2 is slow
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

  // drift streams need real time: see ui_flow_test.dart.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  }

  // phone A has a shared space with milk; phone B knows the space id only
  setUp(() async {
    a = await phone();
    b = await phone();
    await shareNewSpace(a, client, 'http://srv', 'Home');
    final space = (await watchSpaces(a).first).firstWhere((s) => !s.private);
    await record(a,
        spaceId: space.id,
        itemId: newId(),
        body: ItemAdd(name: 'milk', quantity: null, unit: null, note: null, requestedBy: accountId));
    await sync(a, client);
    await b.into(b.spaces).insert(SpaceRow(
        id: space.id,
        name: '?',
        private: false,
        serverUrl: 'http://srv',
        createdBy: accountId,
        createdAt: DateTime.now()));
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  testWidgets('opening the app syncs', (tester) async {
    await tester.pumpWidget(ListopherApp(db: b, client: client));
    await settle(tester);
    expect(find.text('milk'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('failed sync shows a message, button syncs again', (tester) async {
    var down = true;
    final flaky = MockClient((req) async {
      if (down) throw http.ClientException('down');
      return client.send(http.Request(req.method, req.url)
            ..body = req.body
            ..headers.addAll(req.headers))
          .then(http.Response.fromStream);
    });
    await tester.pumpWidget(ListopherApp(db: b, client: flaky));
    await settle(tester);
    expect(find.text('Sync failed'), findsOneWidget);
    expect(find.text('milk'), findsNothing);

    down = false;
    await tester.tap(find.byTooltip('Sync'));
    await settle(tester);
    expect(find.text('milk'), findsOneWidget);
    await unmount(tester);
  });
}

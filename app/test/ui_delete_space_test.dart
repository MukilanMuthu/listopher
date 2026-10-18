// delete action on the Spaces tab, against the real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database serverDb;
  late http.Client client;
  late AppDb db;
  late String accountId;
  late String token;

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

  setUp(() async {
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
    await saveServerAccount(db,
        url: 'http://srv', accountId: accountId, displayName: 'Alice', token: token);
  });
  tearDown(() => db.close());

  // drift streams need real time: see ui_flow_test.dart.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> openSpacesTab(WidgetTester tester) async {
    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  }

  testWidgets('owner: delete asks first, cancel keeps, confirm deletes everywhere', (tester) async {
    await tester.runAsync(() => shareNewSpace(db, client, 'http://srv', 'Home'));
    await openSpacesTab(tester);

    await tester.tap(find.byTooltip('Delete space'));
    await settle(tester);
    expect(find.textContaining('Delete Home'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete space'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.text('Home'), findsNothing);
    expect(serverDb.select('select 1 from spaces'), isEmpty);
    await unmount(tester);
  });

  testWidgets('not owner or private: no delete action', (tester) async {
    // someone else's space that alice is a member of (else sync would forget it)
    addUser(serverDb, 'bob${DateTime.now().microsecondsSinceEpoch}', 'Bob', 'pw');
    final bob = serverDb.select('select id from accounts where display_name = ?', ['Bob']).first['id'];
    serverDb.execute("insert into spaces (id, owner_id, created_at) values ('theirs', '$bob', 0)");
    serverDb.execute("insert into members (space_id, account_id, role, joined_at) values ('theirs', '$accountId', 'member', 0)");
    await tester.runAsync(() => db.into(db.spaces).insert(SpaceRow(
        id: 'theirs',
        name: 'Theirs',
        private: false,
        serverUrl: 'http://srv',
        createdBy: 'someone-else',
        createdAt: DateTime.now())));
    await openSpacesTab(tester);

    expect(find.text('Theirs'), findsOneWidget);
    expect(find.byTooltip('Delete space'), findsNothing);
    await unmount(tester);
  });

  testWidgets('server refuses: message shown, space stays', (tester) async {
    await tester.runAsync(() => shareNewSpace(db, client, 'http://srv', 'Home'));
    await openSpacesTab(tester);
    // server turns us away: stale token
    await tester.runAsync(() => saveServerAccount(db,
        url: 'http://srv', accountId: accountId, displayName: 'Alice', token: 'stale'));
    await tester.tap(find.byTooltip('Delete space'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.text('Could not delete the space'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    await unmount(tester);
  });
}

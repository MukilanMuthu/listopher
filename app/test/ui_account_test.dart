// logout and delete account on the Spaces tab, against the real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';
import 'package:listopher_core/core.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Database serverDb;
  late http.Client client;
  late AppDb db;
  late String accountId;

  setUp(() async {
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
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
    await saveServerAccount(db,
        url: 'http://srv', accountId: accountId, displayName: 'Alice', token: r.token);
  });
  tearDown(() async {
    await db.close();
    serverDb.close();
  });

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

  testWidgets('log out: server tile and its spaces vanish', (tester) async {
    await tester.runAsync(() => shareNewSpace(db, client, 'http://srv', 'Home'));
    await openSpacesTab(tester);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byTooltip('Log out'));
    await settle(tester);

    expect(find.text('Home'), findsNothing);
    expect(find.text('Signed in to http://srv'), findsNothing);
    expect(serverDb.select('select 1 from sessions'), isEmpty);
    await unmount(tester);
  });

  testWidgets('delete account: warning lists transfer vs delete, cancel keeps, confirm deletes', (tester) async {
    await tester.runAsync(() => shareNewSpace(db, client, 'http://srv', 'Solo'));
    await tester.runAsync(() => shareNewSpace(db, client, 'http://srv', 'Team'));
    final team = (await tester.runAsync(() => watchSpaces(db).first))!.firstWhere((s) => s.name == 'Team').id;
    addUser(serverDb, 'bob', 'Bob', 'pw');
    final bob = serverDb.select("select id from accounts where display_name = 'Bob'").first['id'];
    serverDb.execute(
        "insert into members (space_id, account_id, role, joined_at) values ('$team', '$bob', 'member', 0)");
    await openSpacesTab(tester);

    await tester.tap(find.byTooltip('Delete account'));
    await settle(tester);
    expect(find.textContaining('Handed to another member: Team'), findsOneWidget);
    expect(find.textContaining('Deleted: Solo'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Solo'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete account'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);

    expect(find.text('Solo'), findsNothing);
    expect(find.text('Team'), findsNothing);
    expect(serverDb.select('select 1 from accounts where id = ?', [accountId]), isEmpty);
    await unmount(tester);
  });

  testWidgets('dead token on logout: counts as logged out, phone forgets the server', (tester) async {
    await openSpacesTab(tester);
    await tester.runAsync(() => saveServerAccount(db,
        url: 'http://srv', accountId: accountId, displayName: 'Alice', token: 'stale'));
    await settle(tester);

    await tester.tap(find.byTooltip('Log out'));
    await settle(tester);

    expect(find.text('Signed in to http://srv'), findsNothing);
    await unmount(tester);
  });

  testWidgets('unsent ops: log out asks first; cancel keeps, confirm forgets', (tester) async {
    await tester.runAsync(() => shareNewSpace(db, client, 'http://srv', 'Home'));
    final id = (await tester.runAsync(() => watchSpaces(db).first))!.firstWhere((s) => !s.private).id;
    await tester.runAsync(() => record(db,
        spaceId: id,
        itemId: 'i1',
        body: ItemAdd(name: 'milk', quantity: null, unit: null, note: null, requestedBy: accountId)));
    // ops cannot go up, logout itself works
    final offline = MockClient((req) async {
      if (req.url.path.endsWith('/ops')) throw http.ClientException('down');
      final r = await client.send(http.Request(req.method, req.url)
        ..body = req.body
        ..headers.addAll(req.headers));
      return http.Response.fromStream(r);
    });
    await tester.pumpWidget(ListopherApp(db: db, client: offline));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);

    await tester.tap(find.byTooltip('Log out'));
    await settle(tester);
    expect(find.text('1 unsent changes will be lost'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Signed in to http://srv'), findsOneWidget);

    await tester.tap(find.byTooltip('Log out'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await settle(tester);
    expect(find.text('Signed in to http://srv'), findsNothing);
    await unmount(tester);
  });

  testWidgets('server refuses logout: message shown, account stays', (tester) async {
    final broken = MockClient((req) async => http.Response('', 500));
    await tester.pumpWidget(ListopherApp(db: db, client: broken));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);

    await tester.tap(find.byTooltip('Log out'));
    await settle(tester);

    expect(find.text('Could not log out'), findsOneWidget);
    expect(find.text('Signed in to http://srv'), findsOneWidget);
    await unmount(tester);
  });
}

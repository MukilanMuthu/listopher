// + on the Spaces tab, against the real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';
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

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  }

  Future<void> openSpacesTab(WidgetTester tester, [http.Client? c]) async {
    await tester.pumpWidget(ListopherApp(db: db, client: c ?? client));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);
  }

  // type the space name into the dialog and press Create
  Future<void> nameSpace(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextField), name);
    await tester.pump();
    await tester.tap(find.text('Create'));
    await settle(tester);
  }

  testWidgets('not logged in: + asks login first, then name, then shares', (tester) async {
    await openSpacesTab(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    // login screen
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'http://srv');
    await tester.enterText(fields.at(1), 'alice');
    await tester.enterText(fields.at(2), 'pw');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await settle(tester);

    // name dialog
    expect(find.text('New space'), findsOneWidget);
    await nameSpace(tester, 'Home');

    expect(find.text('Home'), findsOneWidget);
    final space = (await db.select(db.spaces).get()).firstWhere((s) => !s.private);
    expect(space.serverUrl, 'http://srv');
    expect(serverDb.select('select 1 from ops where space_id = ?', [space.id]), hasLength(1));
    await unmount(tester);
  });

  testWidgets('already logged in: + goes straight to the name', (tester) async {
    // log in through the screen once, then use + again
    await openSpacesTab(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'http://srv');
    await tester.enterText(fields.at(1), 'alice');
    await tester.enterText(fields.at(2), 'pw');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await settle(tester);
    await nameSpace(tester, 'Home');

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(find.text('New space'), findsOneWidget); // no login screen
    await nameSpace(tester, 'Work');

    expect(find.text('Work'), findsOneWidget);
    expect(serverDb.select('select 1 from spaces'), hasLength(2));
    await unmount(tester);
  });

  testWidgets('server refuses: message shown, no space made', (tester) async {
    await openSpacesTab(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'http://srv');
    await tester.enterText(fields.at(1), 'alice');
    await tester.enterText(fields.at(2), 'pw');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await settle(tester);
    // server goes away before the space is made
    serverDb.execute('delete from sessions');
    await nameSpace(tester, 'Home');

    expect(find.text('Could not create the space on the server'), findsOneWidget);
    expect((await db.select(db.spaces).get()).where((s) => !s.private), isEmpty);
    await unmount(tester);
  });
}

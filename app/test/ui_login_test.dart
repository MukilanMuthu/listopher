// login screen against the real server handler, in-process.
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
      final res = await handler(Request(req.method, req.url, body: req.body, headers: req.headers));
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

  // unmount so drift stream-cancel timers fire before the test ends
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  }

  // open Spaces tab, open login screen, submit the three fields.
  Future<void> logIn(WidgetTester tester, String user, String pw) async {
    await tester.tap(find.text('Log in to server'));
    await settle(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'http://srv');
    await tester.enterText(fields.at(1), user);
    await tester.enterText(fields.at(2), pw);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await settle(tester);
  }

  testWidgets('good login lists the server on the Spaces tab', (tester) async {
    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);

    await logIn(tester, 'alice', 'pw');

    expect(find.text('Signed in to http://srv'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('bad password shows error and stays on the screen', (tester) async {
    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);

    await logIn(tester, 'alice', 'nope');

    expect(find.text('Wrong username or password'), findsOneWidget);
    expect(await db.select(db.serverAccounts).get(), isEmpty);
    await unmount(tester);
  });

  testWidgets('locked account shows locked message', (tester) async {
    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => client.post(Uri.parse('http://srv/auth/login'),
          body: '{"username":"alice","password":"nope"}'));
    }

    await logIn(tester, 'alice', 'pw');

    expect(find.text('Account locked, try again later'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('login ok but restore fails: snackbar says so, account is kept', (tester) async {
    final noRestore = MockClient((req) async {
      if (req.url.path == '/me/spaces') return http.Response('', 500);
      final res = await client.send(http.Request(req.method, req.url)
        ..body = req.body
        ..headers.addAll(req.headers));
      return http.Response.fromStream(res);
    });
    await tester.pumpWidget(ListopherApp(db: db, client: noRestore));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);

    await logIn(tester, 'alice', 'pw');

    expect(find.text('Could not restore your spaces'), findsOneWidget);
    expect(find.text('Signed in to http://srv'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('dead server shows network error', (tester) async {
    final down = MockClient((_) async => throw http.ClientException('down'));
    await tester.pumpWidget(ListopherApp(db: db, client: down));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);

    await logIn(tester, 'alice', 'pw');

    expect(find.text('Cannot reach the server'), findsOneWidget);
    await unmount(tester);
  });
}

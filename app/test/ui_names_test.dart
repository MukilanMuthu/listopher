// names on item rows. two phones, real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/join/join.dart';
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
  late LoginOk alice;
  late LoginOk bob;
  late AppDb a; // alice's phone
  late AppDb b; // bob's phone, under test

  setUpAll(() async {
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    addUser(serverDb, 'bob', 'Bob', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      final res = await handler(
          Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
    alice = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
    bob = await login(client, 'http://srv', 'bob', 'pw') as LoginOk;
  });
  tearDownAll(() => serverDb.close());

  Future<AppDb> phone(LoginOk who) async {
    final db = AppDb(NativeDatabase.memory());
    await createMe(db, who.displayName);
    await saveServerAccount(db,
        url: 'http://srv',
        accountId: who.accountId,
        displayName: who.displayName,
        token: who.token);
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

  // alice shares "Home" with milk, bob joins it
  setUp(() async {
    a = await phone(alice);
    b = await phone(bob);
    await shareNewSpace(a, client, 'http://srv', 'Home');
    final id = (await watchSpaces(a).first).firstWhere((s) => !s.private).id;
    await record(a,
        spaceId: id,
        itemId: newId(),
        body: ItemAdd(
            name: 'milk', quantity: null, unit: null, note: null, requestedBy: alice.accountId));
    await sync(a, client);
    await joinByLink(b, client, parseInviteLink(await makeInviteLink(a, client, id)));
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  testWidgets('shared row shows who asked; checking makes me the buyer at once',
      (tester) async {
    await tester.pumpWidget(ListopherApp(db: b, client: client));
    await settle(tester);
    expect(find.text('asked by Alice'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await settle(tester);
    expect(find.text('asked by Alice · bought by Bob'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('private row checks straight away with me as buyer', (tester) async {
    // db calls need real time inside testWidgets
    await tester.runAsync(() async {
      final priv = (await watchSpaces(b).first).firstWhere((s) => s.private);
      await record(b,
          spaceId: priv.id,
          itemId: newId(),
          body: ItemAdd(
              name: 'eggs', quantity: null, unit: null, note: null,
              requestedBy: (await watchMe(b).first)!.id));
    });
    await tester.pumpWidget(ListopherApp(db: b, client: client));
    await settle(tester);
    // eggs is the only private row; milk is the other checkbox
    await tester.tap(find.descendant(
        of: find.widgetWithText(ListTile, 'eggs'), matching: find.byType(Checkbox)));
    await settle(tester);
    expect(find.text('asked by Bob · bought by Bob'), findsOneWidget);
    await unmount(tester);
  });
}

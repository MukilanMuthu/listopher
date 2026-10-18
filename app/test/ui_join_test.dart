// invite and join through the Spaces tab, against the real server handler, in-process.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/join/join.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';
import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDb owner; // alice's phone, signed in, owns "Home"
  late AppDb joiner; // bob's phone, not signed in
  late Database serverDb;
  late http.Client client;
  late String spaceId;

  setUp(() async {
    serverDb = openServerDb(':memory:');
    addUser(serverDb, 'alice', 'Alice', 'pw');
    addUser(serverDb, 'bob', 'Bob', 'pw');
    final handler = buildHandler(serverDb);
    client = MockClient((req) async {
      final res = await handler(
          Request(req.method, req.url, body: req.body, headers: req.headers));
      return http.Response(await res.readAsString(), res.statusCode);
    });
    owner = AppDb(NativeDatabase.memory());
    await createMe(owner, 'Alice');
    final a = await login(client, 'http://srv', 'alice', 'pw') as LoginOk;
    await saveServerAccount(owner,
        url: 'http://srv', accountId: a.accountId, displayName: 'Alice', token: a.token);
    await shareNewSpace(owner, client, 'http://srv', 'Home');
    spaceId = (await watchSpaces(owner).first).firstWhere((s) => !s.private).id;
    joiner = AppDb(NativeDatabase.memory());
    await createMe(joiner, 'Bob');
  });
  tearDown(() async {
    await owner.close();
    await joiner.close();
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

  Future<void> openSpacesTab(WidgetTester tester, AppDb db) async {
    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    await tester.tap(find.text('Spaces'));
    await settle(tester);
  }

  // paste a link into the join dialog and press Join
  Future<void> pasteAndJoin(WidgetTester tester, String link) async {
    await tester.tap(find.text('Join with a link'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), link);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Join'));
    await settle(tester);
    await settle(tester); // login screen comes after a db read
  }

  Future<void> logInAsBob(WidgetTester tester) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), 'bob');
    await tester.enterText(fields.at(2), 'pw');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    // login (argon2), then join, then restore: slow in real time
    // (short pumps: a snackbar must not time out in fake time before we look)
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('owner taps Invite and sees a link that works', (tester) async {
    await openSpacesTab(tester, owner);
    await tester.tap(find.byTooltip('Invite'));
    await settle(tester);

    final shown = tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    final link = parseInviteLink(shown); // a real link, not just text
    expect(link.space, spaceId);
    expect(link.server, 'http://srv');
    await unmount(tester);
  });

  testWidgets('joiner not signed in: link asks login, then space and items appear', (tester) async {
    final link = (await tester.runAsync(() => makeInviteLink(owner, client, spaceId)))!;
    await openSpacesTab(tester, joiner);
    await pasteAndJoin(tester, link);

    // login screen, server already filled in from the link
    expect(find.text('http://srv'), findsOneWidget);
    await logInAsBob(tester);

    expect(find.text('Home'), findsOneWidget);
    final space = (await joiner.select(joiner.spaces).get()).firstWhere((s) => !s.private);
    expect(space.id, spaceId);
    await unmount(tester);
  });

  testWidgets('rotated invite: error shown, no space added', (tester) async {
    final old = (await tester.runAsync(() => makeInviteLink(owner, client, spaceId)))!;
    await tester.runAsync(() => makeInviteLink(owner, client, spaceId)); // owner rotates
    await openSpacesTab(tester, joiner);
    await pasteAndJoin(tester, old);
    await logInAsBob(tester);

    expect(find.text('This invite no longer works'), findsOneWidget);
    expect((await joiner.select(joiner.spaces).get()).where((s) => !s.private), isEmpty);
    await unmount(tester);
  });

  testWidgets('pasting junk: error shown', (tester) async {
    await openSpacesTab(tester, joiner);
    await pasteAndJoin(tester, 'hello');

    expect(find.text('Not a valid invite link'), findsOneWidget);
    await unmount(tester);
  });
}

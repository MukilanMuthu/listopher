import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';

void main() {
  late AppDb db;

  setUp(() => db = AppDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  // drift streams use real timers + real async, so pumpAndSettle can hang
  // and fake-async never sees db results. runAsync lets real time pass,
  // then pump draws the frame.
  // few rounds: load streams, then draw what they changed
  // (dialog close, tab switch).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  testWidgets('name -> add items -> check -> spaces -> picker', (tester) async {
    await tester.pumpWidget(ListopherApp(db: db, client: MockClient((_) async => http.Response('', 500))));
    await settle(tester);

    // name prompt: save is off while blank
    expect(find.text('Your name'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Mukil');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await settle(tester);

    // items tab, empty
    expect(find.text('No items yet'), findsOneWidget);

    // FAB: only private space, so no picker
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(find.text('Pick a space'), findsNothing);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'rice');
    await tester.enterText(fields.at(1), '1,5');
    await tester.enterText(fields.at(2), 'kg');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await settle(tester);

    // dialog reopened empty
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, '');
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('rice'), findsOneWidget);
    expect(find.text('1.5 kg · Private'), findsOneWidget);

    // tick it
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, false);
    await tester.tap(find.byType(Checkbox));
    await settle(tester);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);

    // spaces tab: private space shown, create Home
    await tester.tap(find.text('Spaces'));
    await settle(tester);
    expect(find.text('Private'), findsOneWidget);
    // shared Home made straight in the store (the + flow has its own test)
    await tester.runAsync(() async {
      await saveServerAccount(db, url: 'http://srv', accountId: 'a1', displayName: 'A', token: 't');
      await createSharedSpace(db, spaceId: 'home', serverUrl: 'http://srv', name: 'Home');
    });
    await settle(tester);
    expect(find.text('Home'), findsOneWidget);

    // items tab: two spaces, FAB shows picker
    await tester.tap(find.text('Items'));
    await settle(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(find.text('Pick a space'), findsOneWidget);
    expect(find.text('Private'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);

    // unmount so drift stream-cancel timers fire before the test ends
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });
}

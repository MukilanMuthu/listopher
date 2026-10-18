// background sync error: shown once on open, then cleared.
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';

void main() {
  late AppDb db;
  // local-only db: foreground sync has nothing to do, so no "Sync failed" noise
  final client = MockClient((req) async => http.Response('', 500));

  setUp(() async {
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'Mukil');
  });
  tearDown(() => db.close());

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

  testWidgets('saved error shows once, then is cleared', (tester) async {
    await tester.runAsync(() => saveBgSyncFailure(db, DateTime.now(), 'boom'));

    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    expect(find.text('Background sync failed'), findsOneWidget);
    expect((await tester.runAsync(() => readBgSyncState(db)))!.lastError, isNull);
    await unmount(tester);

    // fresh widget, same db: gone
    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    expect(find.text('Background sync failed'), findsNothing);
    await unmount(tester);
  });

  testWidgets('no saved error shows nothing', (tester) async {
    await tester.pumpWidget(ListopherApp(db: db, client: client));
    await settle(tester);
    expect(find.text('Background sync failed'), findsNothing);
    await unmount(tester);
  });
}

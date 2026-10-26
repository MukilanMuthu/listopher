import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/widget/widget.dart';
import 'package:listopher_core/core.dart';

void main() {
  late AppDb db;

  setUp(() async {
    db = AppDb(NativeDatabase.memory());
    await createMe(db, 'A');
  });
  tearDown(() => db.close());

  test(
    'snapshot groups ordered item data without notes or member names',
    () async {
      final space = (await watchSpaces(db).first).single;
      await record(
        db,
        spaceId: space.id,
        itemId: 'rice',
        body: const ItemAdd(
          name: 'rice',
          quantity: 2,
          unit: 'kg',
          note: 'private note',
          requestedBy: 'member',
        ),
      );
      final snapshot = widgetSnapshot(
        await watchSpaces(db).first,
        await watchItems(db).first,
      );
      final spaces = snapshot['spaces']! as List<Map<String, Object?>>;
      final item =
          (spaces.single['items']! as List<Map<String, Object?>>).single;
      expect(spaces.single['private'], isTrue);
      expect(item, containsPair('name', 'rice'));
      expect(item, containsPair('quantity', 2.0));
      expect(item, containsPair('unit', 'kg'));
      expect(item.keys, isNot(contains('note')));
      expect(item.keys, isNot(contains('requestedBy')));
    },
  );

  test(
    'widget checkbox records a local toggle and rejects stale list IDs',
    () async {
      final space = (await watchSpaces(db).first).single;
      await record(
        db,
        spaceId: space.id,
        itemId: 'milk',
        body: const ItemAdd(
          name: 'milk',
          quantity: null,
          unit: null,
          note: null,
          requestedBy: 'me',
        ),
      );
      final client = MockClient((_) async => http.Response('', 500));
      final action = Uri(
        scheme: 'listopher',
        host: 'check',
        queryParameters: {'space': space.id, 'item': 'milk'},
      );
      await performWidgetAction(db, client, action);
      expect((await watchItems(db).first).single.checked, isTrue);
      await performWidgetAction(db, client, action);
      expect((await watchItems(db).first).single.checked, isFalse);

      final stale = Uri(
        scheme: 'listopher',
        host: 'check',
        queryParameters: {'space': 'deleted', 'item': 'milk'},
      );
      await performWidgetAction(db, client, stale);
      expect((await watchItems(db).first).single.checked, isFalse);
      client.close();
    },
  );

  test('manual widget sync reports failure and keeps items', () async {
    await saveServerAccount(
      db,
      url: 'https://server',
      accountId: 'account',
      displayName: 'A',
      token: 'token',
    );
    await createSharedSpace(
      db,
      spaceId: 'shared',
      serverUrl: 'https://server',
      name: 'Shared',
    );
    await saveServerAccount(
      db,
      url: 'https://other',
      accountId: 'account-2',
      displayName: 'A',
      token: 'token-2',
    );
    await createSharedSpace(
      db,
      spaceId: 'other',
      serverUrl: 'https://other',
      name: 'Other',
    );
    final hosts = <String>{};
    final client = MockClient((request) async {
      hosts.add(request.url.host);
      return http.Response('', 500);
    });
    final failed = await performWidgetAction(
      db,
      client,
      Uri(scheme: 'listopher', host: 'sync'),
    );
    expect(failed, isTrue);
    expect(hosts, {'server', 'other'});
    expect(
      (await watchSpaces(db).first).any((space) => space.id == 'shared'),
      isTrue,
    );
    client.close();
  });

  test('widget list links identify the target list', () {
    expect(widgetSpaceFromUri(Uri.parse('listopher://space?id=home')), 'home');
    expect(widgetSpaceFromUri(Uri.parse('listopher://space')), isNull);
    expect(
      widgetSpaceFromUri(Uri.parse('https://example.com/?id=home')),
      isNull,
    );
  });
}

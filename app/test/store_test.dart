import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listopher/store/src/apply_item_op.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher_core/core.dart';

void main() {
  late AppDb db;

  setUp(() => db = AppDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  // helper: make list "shop" and add rice 1.5 kg. returns ids.
  Future<({String list, String item})> seed() async {
    final list = newId();
    final item = newId();
    await record(db,
        listId: list, body: const ListCreate(name: 'shop', date: null));
    await record(db,
        listId: list,
        itemId: item,
        body: const ItemAdd(
            name: 'rice',
            quantity: 1.5,
            unit: 'kg',
            note: null,
            requestedBy: 'mum'));
    return (list: list, item: item);
  }

  group('me', () {
    test('createMe then watchMe emits user', () async {
      await createMe(db, '  Asha ');
      final me = await watchMe(db).first;
      expect(me?.displayName, 'Asha');
      expect(me?.isMe, true);
    });

    test('createMe twice throws', () async {
      await createMe(db, 'Asha');
      expect(createMe(db, 'Ravi'), throwsStateError);
    });

    test('empty name throws', () {
      expect(createMe(db, '   '), throwsArgumentError);
    });
  });

  group('record', () {
    test('without me throws', () {
      expect(
          record(db,
              listId: newId(),
              body: const ListCreate(name: 'x', date: null)),
          throwsStateError);
    });

    test('check keeps checker and fulfiller apart', () async {
      await createMe(db, 'Asha');
      final me = (await watchMe(db).first)!;
      final s = await seed();
      await record(db,
          listId: s.list,
          itemId: s.item,
          body: const ItemCheck(fulfilledBy: 'ravi'));
      final item = (await watchItems(db, s.list).first).single;
      expect(item.name, 'rice');
      expect(item.checked, true);
      expect(item.checkedBy, me.id);
      expect(item.fulfilledBy, 'ravi');
    });

    test('uncheck clears check fields', () async {
      await createMe(db, 'Asha');
      final s = await seed();
      await record(db,
          listId: s.list,
          itemId: s.item,
          body: const ItemCheck(fulfilledBy: 'ravi'));
      await record(db,
          listId: s.list, itemId: s.item, body: const ItemUncheck());
      final item = (await watchItems(db, s.list).first).single;
      expect(item.checked, false);
      expect(item.checkedBy, isNull);
      expect(item.checkedAt, isNull);
      expect(item.fulfilledBy, isNull);
    });

    test('update with null unit clears unit', () async {
      await createMe(db, 'Asha');
      final s = await seed();
      await record(db,
          listId: s.list,
          itemId: s.item,
          body: const ItemUpdate(
              name: 'rice', quantity: 2, unit: null, note: null));
      final item = (await watchItems(db, s.list).first).single;
      expect(item.unit, isNull);
      expect(item.quantity, 2);
    });

    test('delete hides item', () async {
      await createMe(db, 'Asha');
      final s = await seed();
      await record(db,
          listId: s.list, itemId: s.item, body: const ItemDelete());
      expect(await watchItems(db, s.list).first, isEmpty);
    });

    test('every record adds one outbox op', () async {
      await createMe(db, 'Asha');
      await seed(); // 2 records
      final ops = await db.select(db.ops).get();
      expect(ops.length, 2);
      expect(ops.every((o) => o.serverSeq == null), true);
    });

    test('watchLists shows created list', () async {
      await createMe(db, 'Asha');
      await seed();
      expect((await watchLists(db).first).single.name, 'shop');
    });
  });

  group('applyItemOp', () {
    // op with given body on item "i"
    Op op(OpBody body) => Op(
        id: 'o',
        groupId: null,
        listId: 'l',
        itemId: 'i',
        userId: 'u',
        clientTime: DateTime.utc(2026),
        serverSeq: null,
        body: body);

    test('non-add ops on null are ignored', () {
      for (final b in <OpBody>[
        const ItemUpdate(name: 'a', quantity: null, unit: null, note: null),
        const ItemCheck(fulfilledBy: 'u'),
        const ItemUncheck(),
        const ItemDelete(),
      ]) {
        expect(applyItemOp(null, op(b)), isNull);
      }
    });
  });
}

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listopher/store/src/app_db.dart';
import 'package:listopher/store/src/apply_item_op.dart';
import 'package:listopher/store/src/apply_space_op.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher_core/core.dart';

void main() {
  late AppDb db;

  setUp(() => db = AppDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  // helper: add rice 1.5 kg to the private space (createMe made it). returns ids.
  Future<({String space, String item})> seed() async {
    final space = (await watchSpaces(db).first).single.id;
    final item = newId();
    await record(db,
        spaceId: space,
        itemId: item,
        body: const ItemAdd(
            name: 'rice',
            quantity: 1.5,
            unit: 'kg',
            note: null,
            requestedBy: 'mum'));
    return (space: space, item: item);
  }

  group('me', () {
    test('createMe then watchMe emits user', () async {
      await createMe(db, '  Asha ');
      final me = await watchMe(db).first;
      expect(me?.displayName, 'Asha');
      expect(me?.isMe, true);
    });

    test('createMe also makes exactly one private space', () async {
      await createMe(db, 'Asha');
      final spaces = await watchSpaces(db).first;
      expect(spaces.length, 1);
      expect(spaces.single.private, true);
      expect(spaces.single.serverUrl, isNull);
    });

    test('createMe twice throws', () async {
      await createMe(db, 'Asha');
      expect(createMe(db, 'Ravi'), throwsStateError);
    });

    test('empty name throws', () {
      expect(createMe(db, '   '), throwsArgumentError);
    });
  });

  group('server accounts', () {
    // helper: a shared space row on server url (UI to create one comes later)
    Future<void> shared(String id, String url) => db.into(db.spaces).insert(
        SpacesCompanion.insert(
            id: id,
            name: 'home',
            private: false,
            serverUrl: Value(url),
            createdBy: 'x',
            createdAt: DateTime.now()));

    Future<Op> lastOp() async =>
        opFromJson(jsonDecode((await db.select(db.ops).get()).last.json));

    test('one account per server url, save again replaces', () async {
      await saveServerAccount(db,
          url: 'http://a', accountId: 'a1', displayName: 'A', token: 't1');
      await saveServerAccount(db,
          url: 'http://b', accountId: 'b1', displayName: 'B', token: 't2');
      await saveServerAccount(db,
          url: 'http://a', accountId: 'a2', displayName: 'A', token: 't3');
      final all = await db.select(db.serverAccounts).get();
      expect(all.length, 2);
      expect(all.firstWhere((a) => a.url == 'http://a').accountId, 'a2');
    });

    test('op in shared space carries that server account id', () async {
      await createMe(db, 'Asha');
      await saveServerAccount(db,
          url: 'http://a', accountId: 'a1', displayName: 'A', token: 't');
      await shared('s1', 'http://a');
      await record(db, spaceId: 's1', body: const SpaceRename(name: 'x'));
      expect((await lastOp()).userId, 'a1');
    });

    test('op in private space carries local user id', () async {
      await createMe(db, 'Asha');
      final me = (await watchMe(db).first)!;
      await record(db,
          spaceId: (await watchSpaces(db).first).single.id,
          body: const SpaceRename(name: 'x'));
      expect((await lastOp()).userId, me.id);
    });

    test('shared space without account throws', () async {
      await createMe(db, 'Asha');
      await shared('s1', 'http://nope');
      expect(record(db, spaceId: 's1', body: const SpaceRename(name: 'x')),
          throwsStateError);
    });

    test('isMe true for local id and any account id, else false', () async {
      await createMe(db, 'Asha');
      final me = (await watchMe(db).first)!;
      await saveServerAccount(db,
          url: 'http://a', accountId: 'a1', displayName: 'A', token: 't');
      await saveServerAccount(db,
          url: 'http://b', accountId: 'b1', displayName: 'B', token: 't');
      expect(await isMe(db, me.id), true);
      expect(await isMe(db, 'a1'), true);
      expect(await isMe(db, 'b1'), true);
      expect(await isMe(db, 'other'), false);
    });
  });

  group('record', () {
    test('without me throws', () {
      expect(
          record(db,
              spaceId: newId(),
              body: const SpaceCreate(name: 'x', private: false)),
          throwsStateError);
    });

    test('check keeps checker and fulfiller apart', () async {
      await createMe(db, 'Asha');
      final me = (await watchMe(db).first)!;
      final s = await seed();
      await record(db,
          spaceId: s.space,
          itemId: s.item,
          body: const ItemCheck(fulfilledBy: 'ravi'));
      final item = (await watchItems(db).first).single;
      expect(item.name, 'rice');
      expect(item.checked, true);
      expect(item.checkedBy, me.id);
      expect(item.fulfilledBy, 'ravi');
    });

    test('uncheck clears check fields', () async {
      await createMe(db, 'Asha');
      final s = await seed();
      await record(db,
          spaceId: s.space,
          itemId: s.item,
          body: const ItemCheck(fulfilledBy: 'ravi'));
      await record(db,
          spaceId: s.space, itemId: s.item, body: const ItemUncheck());
      final item = (await watchItems(db).first).single;
      expect(item.checked, false);
      expect(item.checkedBy, isNull);
      expect(item.checkedAt, isNull);
      expect(item.fulfilledBy, isNull);
    });

    test('update with null unit clears unit', () async {
      await createMe(db, 'Asha');
      final s = await seed();
      await record(db,
          spaceId: s.space,
          itemId: s.item,
          body: const ItemUpdate(
              name: 'rice', quantity: 2, unit: null, note: null));
      final item = (await watchItems(db).first).single;
      expect(item.unit, isNull);
      expect(item.quantity, 2);
    });

    test('delete hides item', () async {
      await createMe(db, 'Asha');
      final s = await seed();
      await record(db,
          spaceId: s.space, itemId: s.item, body: const ItemDelete());
      expect(await watchItems(db).first, isEmpty);
    });

    test('every record adds one outbox op carrying spaceId', () async {
      await createMe(db, 'Asha');
      final s = await seed(); // space.create (createMe) + item.add = 2 records
      final ops = await db.select(db.ops).get();
      expect(ops.length, 2);
      expect(ops.every((o) => o.serverSeq == null && o.spaceId == s.space), true);
    });

    test('watchSpaces: private first, then name', () async {
      await createMe(db, 'Asha');
      await record(db,
          spaceId: newId(),
          body: const SpaceCreate(name: 'Zoo', private: false));
      await record(db,
          spaceId: newId(),
          body: const SpaceCreate(name: 'Apt', private: false));
      final spaces = await watchSpaces(db).first;
      expect(spaces.map((s) => s.private), [true, false, false]);
      expect(spaces.skip(1).map((s) => s.name), ['Apt', 'Zoo']);
    });

    test('rename changes name', () async {
      await createMe(db, 'Asha');
      final id = newId();
      await record(db,
          spaceId: id, body: const SpaceCreate(name: 'Home', private: false));
      await record(db, spaceId: id, body: const SpaceRename(name: 'Flat'));
      final spaces = await watchSpaces(db).first;
      expect(spaces.any((s) => s.name == 'Flat'), true);
      expect(spaces.any((s) => s.name == 'Home'), false);
    });

    test('watchItems spans spaces', () async {
      await createMe(db, 'Asha');
      await seed();
      final other = newId();
      await record(db,
          spaceId: other,
          body: const SpaceCreate(name: 'Home', private: false));
      await record(db,
          spaceId: other,
          itemId: newId(),
          body: const ItemAdd(
              name: 'soap',
              quantity: null,
              unit: null,
              note: null,
              requestedBy: 'x'));
      final items = await watchItems(db).first;
      expect(items.map((i) => i.name), ['rice', 'soap']);
      expect(items.map((i) => i.spaceId).toSet().length, 2);
    });
  });

  group('applySpaceOp', () {
    // space-level op (no item)
    Op op(OpBody body) => Op(
        id: 'o',
        spaceId: 's',
        itemId: null,
        userId: 'u',
        clientTime: DateTime.utc(2026),
        serverSeq: null,
        body: body);

    test('rename on null stays null', () {
      expect(applySpaceOp(null, op(const SpaceRename(name: 'x'))), isNull);
    });

    test('create then rename', () {
      final made =
          applySpaceOp(null, op(const SpaceCreate(name: 'a', private: false)));
      expect(made?.name, 'a');
      expect(applySpaceOp(made, op(const SpaceRename(name: 'b')))?.name, 'b');
    });
  });

  group('shared space', () {
    // me + an account on srv
    Future<void> signIn() async {
      await createMe(db, 'Asha');
      await saveServerAccount(db,
          url: 'http://srv', accountId: 'acc1', displayName: 'Asha S', token: 't');
    }

    test('createSharedSpace makes a shared space owned by my account id', () async {
      await signIn();
      final id = newId();
      await createSharedSpace(db, spaceId: id, serverUrl: 'http://srv', name: 'Home');
      final space = (await watchSpaces(db).first).firstWhere((s) => s.id == id);
      expect(space.serverUrl, 'http://srv');
      expect(space.private, false);
      expect(space.createdBy, 'acc1');
    });

    test('outbox holds the unsent ops, confirmOps empties it', () async {
      await signIn();
      final id = newId();
      await createSharedSpace(db, spaceId: id, serverUrl: 'http://srv', name: 'Home');
      final out = await outbox(db, id);
      expect(out.single.body, isA<SpaceCreate>());
      await confirmOps(db, {out.single.id: 7});
      expect(await outbox(db, id), isEmpty);
      final rows = await (db.select(db.ops)..where((o) => o.id.equals(out.single.id))).get();
      expect(rows.single.serverSeq, 7);
    });

    test('private space has no outbox: it can never be pushed', () async {
      await signIn();
      final priv = (await watchSpaces(db).first).single.id;
      expect(outbox(db, priv), throwsStateError);
    });

    test('createSharedSpace without an account fails', () async {
      await createMe(db, 'Asha');
      expect(createSharedSpace(db, spaceId: newId(), serverUrl: 'http://x', name: 'n'),
          throwsStateError);
    });
  });
  group('applyItemOp', () {
    // op with given body on item "i"
    Op op(OpBody body) => Op(
        id: 'o',
        spaceId: 's',
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


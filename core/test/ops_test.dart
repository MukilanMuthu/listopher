import 'dart:convert';

import 'package:listopher_core/core.dart';
import 'package:test/test.dart';

// make op with given body. other fields fixed: test only cares about body.
Op _op(OpBody body) => Op(
      id: 'op-1',
      spaceId: 's-1',
      itemId: 'i-1',
      userId: 'u-asha',
      clientTime: DateTime.utc(2026, 10, 10, 18, 2),
      serverSeq: 7,
      body: body,
    );

// op → json string → op → json map. same as first json map = nothing lost on wire.
void _roundTrip(OpBody body) {
  final first = opToJson(_op(body));
  final wire = jsonEncode(first);
  final back = opToJson(opFromJson(jsonDecode(wire) as Map<String, Object?>));
  expect(back, first);
}

void main() {
  // every op type survives the wire.
  test('space.create', () => _roundTrip(const SpaceCreate(name: 'Home', private: false)));
  test('space.create private', () => _roundTrip(const SpaceCreate(name: 'private', private: true)));
  test('space.rename', () => _roundTrip(const SpaceRename(name: 'Flat')));
  test('item.add rice 1.5 kg', () => _roundTrip(const ItemAdd(name: 'அரிசி', quantity: 1.5, unit: 'kg', note: null, requestedBy: 'u-mum')));
  test('item.add milk, no qty no unit', () => _roundTrip(const ItemAdd(name: 'milk', quantity: null, unit: null, note: null, requestedBy: 'u-asha')));
  test('item.update', () => _roundTrip(const ItemUpdate(name: 'soap', quantity: 1, unit: null, note: 'lavender')));
  test('item.check', () => _roundTrip(const ItemCheck(fulfilledBy: 'u-ravi')));
  test('item.uncheck', () => _roundTrip(const ItemUncheck()));
  test('item.delete', () => _roundTrip(const ItemDelete()));

  // json int quantity (1) must read as double, not crash.
  test('int quantity reads as double', () {
    final json = opToJson(_op(const ItemAdd(name: 'soap', quantity: 1, unit: null, note: null, requestedBy: 'u-asha')));
    (json['payload'] as Map)['quantity'] = 1; // int, like other json libs send
    final body = opFromJson(json).body as ItemAdd;
    expect(body.quantity, 1.0);
  });

  // unknown type must fail loud.
  test('unknown type throws', () {
    final json = opToJson(_op(const ItemDelete()))..['type'] = 'item.explode';
    expect(() => opFromJson(json), throwsFormatException);
  });
}

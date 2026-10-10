import 'op.dart';

/// OpBody → {type, payload}. type string = wire name from adr 5.
Map<String, Object?> bodyToJson(OpBody body) => switch (body) {
      // sealed switch: new op type added → compiler forces case here.
      SpaceCreate(:final name, :final private) => {
          'type': 'space.create',
          'payload': {'name': name, 'private': private},
        },
      SpaceRename(:final name) => {
          'type': 'space.rename',
          'payload': {'name': name},
        },
      ItemAdd(:final name, :final quantity, :final unit, :final note, :final requestedBy) => {
          'type': 'item.add',
          'payload': {
            'name': name,
            'quantity': quantity,
            'unit': unit,
            'note': note,
            'requested_by': requestedBy,
          },
        },
      ItemUpdate(:final name, :final quantity, :final unit, :final note) => {
          'type': 'item.update',
          'payload': {'name': name, 'quantity': quantity, 'unit': unit, 'note': note},
        },
      ItemCheck(:final fulfilledBy) => {
          'type': 'item.check',
          'payload': {'fulfilled_by': fulfilledBy},
        },
      ItemUncheck() => {'type': 'item.uncheck', 'payload': <String, Object?>{}},
      ItemDelete() => {'type': 'item.delete', 'payload': <String, Object?>{}},
    };

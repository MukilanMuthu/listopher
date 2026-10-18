import 'decimal_from_json.dart';
import 'op.dart';

/// (type, payload) → OpBody. reverse of bodyToJson.
/// unknown type → FormatException. old app talking to newer server fails loud, not silent.
OpBody bodyFromJson(String type, Map<String, Object?> p) => switch (type) {
      'space.create' => SpaceCreate(
          name: p['name'] as String,
          private: p['private'] as bool,
        ),
      'space.rename' => SpaceRename(name: p['name'] as String),
      'item.add' => ItemAdd(
          name: p['name'] as String,
          quantity: decimalFromJson(p['quantity']),
          unit: p['unit'] as String?,
          note: p['note'] as String?,
          requestedBy: p['requested_by'] as String,
        ),
      'item.update' => ItemUpdate(
          name: p['name'] as String,
          quantity: decimalFromJson(p['quantity']),
          unit: p['unit'] as String?,
          note: p['note'] as String?,
        ),
      'item.check' => const ItemCheck(),
      'item.uncheck' => const ItemUncheck(),
      'item.delete' => const ItemDelete(),
      _ => throw FormatException('unknown op type: $type'),
    };

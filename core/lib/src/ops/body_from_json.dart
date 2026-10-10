import 'day_from_json.dart';
import 'decimal_from_json.dart';
import 'op.dart';

/// (type, payload) → OpBody. reverse of bodyToJson.
/// unknown type → FormatException. old app talking to newer server fails loud, not silent.
OpBody bodyFromJson(String type, Map<String, Object?> p) => switch (type) {
      'list.create' => ListCreate(
          name: p['name'] as String,
          date: dayFromJson(p['date']),
        ),
      'list.update' => ListUpdate(
          name: p['name'] as String,
          date: dayFromJson(p['date']),
        ),
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
      'item.check' => ItemCheck(fulfilledBy: p['fulfilled_by'] as String),
      'item.uncheck' => const ItemUncheck(),
      'item.delete' => const ItemDelete(),
      _ => throw FormatException('unknown op type: $type'),
    };

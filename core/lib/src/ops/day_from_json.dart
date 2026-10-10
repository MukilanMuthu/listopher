/// "2026-10-10" → DateTime (local midnight). null stays null.
DateTime? dayFromJson(Object? value) => value == null ? null : DateTime.parse(value as String);

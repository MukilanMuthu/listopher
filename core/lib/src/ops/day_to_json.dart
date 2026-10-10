/// date → "2026-10-10". day only: no time, no timezone. null stays null.
String? dayToJson(DateTime? date) => date?.toIso8601String().substring(0, 10);

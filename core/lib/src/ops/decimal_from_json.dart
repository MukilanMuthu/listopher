/// json gives 1 (int) or 1.5 (double). both → double. null stays null.
double? decimalFromJson(Object? value) => (value as num?)?.toDouble();

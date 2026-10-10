/// text -> number. accepts "1,5" and "1.5". blank or junk = null.
/// ponytail: no thousands separators ("1,000" reads as 1.0).
double? parseQuantity(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  // tryParse accepts "NaN" and "Infinity": reject
  if (value == null || !value.isFinite) return null;
  return value;
}

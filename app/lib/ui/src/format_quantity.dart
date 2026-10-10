/// number -> text. 1.0 shows "1", 1.5 shows "1.5".
String formatQuantity(double quantity) {
  // whole number: drop the ".0"
  if (quantity == quantity.truncateToDouble()) return quantity.toInt().toString();
  return quantity.toString();
}

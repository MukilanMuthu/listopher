import 'package:flutter_test/flutter_test.dart';
import 'package:listopher/ui/src/format_quantity.dart';
import 'package:listopher/ui/src/parse_quantity.dart';

void main() {
  test('parseQuantity: comma, dot, whole, blank, junk', () {
    expect(parseQuantity('1,5'), 1.5);
    expect(parseQuantity('1.5'), 1.5);
    expect(parseQuantity('2'), 2.0);
    expect(parseQuantity(''), isNull);
    expect(parseQuantity('abc'), isNull);
    expect(parseQuantity('NaN'), isNull);
  });

  test('formatQuantity: drop trailing .0', () {
    expect(formatQuantity(1.0), '1');
    expect(formatQuantity(1.5), '1.5');
    expect(formatQuantity(0.25), '0.25');
  });
}

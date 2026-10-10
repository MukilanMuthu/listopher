import 'package:listopher_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('newId is uuid v4 and unique', () {
    final re = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
    final a = newId();
    expect(a, matches(re));
    expect(newId(), isNot(a)); // two calls differ
  });
}

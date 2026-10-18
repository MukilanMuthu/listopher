// server url normal form: the one spelling stored and compared everywhere.
import 'package:flutter_test/flutter_test.dart';
import 'package:listopher/net/net.dart';

void main() {
  test('trims, lowercases scheme and host, drops trailing slash', () {
    expect(normalizeServerUrl('  HTTP://Srv.Example.COM/ '), 'http://srv.example.com');
  });

  test('keeps port and path, drops only the trailing slash', () {
    expect(normalizeServerUrl('http://srv:8080/Api/'), 'http://srv:8080/Api');
  });

  test('already normal stays the same', () {
    expect(normalizeServerUrl('https://srv'), 'https://srv');
  });

  test('not a url: only trimmed', () {
    expect(normalizeServerUrl(' ht!tp:// '), 'ht!tp://');
  });
}

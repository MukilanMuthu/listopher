import 'dart:convert';
import 'dart:math';

// session token: 32 random bytes, base64url, no padding.
String newToken() {
  final r = Random.secure();
  final bytes = List<int>.generate(32, (_) => r.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

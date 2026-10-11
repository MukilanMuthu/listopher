import 'dart:convert';
import 'dart:math';

import 'package:hashlib/hashlib.dart' show argon2id;

// password → argon2id hash string (salt + params inside).
String hashPassword(String password) {
  final r = Random.secure();
  final salt = List<int>.generate(16, (_) => r.nextInt(256)); // fresh salt per hash
  return argon2id(utf8.encode(password), salt).encoded();
}

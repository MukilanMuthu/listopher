import 'dart:convert';

import 'package:hashlib/hashlib.dart' show argon2Verify;

// does password match stored hash?
bool verifyPassword(String password, String hash) =>
    argon2Verify(hash, utf8.encode(password));

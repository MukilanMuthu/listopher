import 'dart:convert';

import 'package:crypto/crypto.dart';

// sha256 hex of token. only this is stored, never the token.
String hashToken(String token) => sha256.convert(utf8.encode(token)).toString();

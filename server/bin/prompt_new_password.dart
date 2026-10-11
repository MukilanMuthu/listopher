import 'dart:io';

import 'prompt_password.dart';

// ask twice, must match and not be empty. else exit 1.
String promptNewPassword() {
  final first = promptPassword('Password');
  if (first.isEmpty) {
    stderr.writeln('password empty');
    exit(1);
  }
  if (first != promptPassword('Password again')) {
    stderr.writeln('passwords differ');
    exit(1);
  }
  return first;
}

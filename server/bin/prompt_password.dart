import 'dart:io';

// ask for a password, echo off. reads one line from stdin.
// ponytail: echo toggle needs a terminal, so skipped when stdin is piped.
String promptPassword(String label) {
  stdout.write('$label: ');
  final tty = stdin.hasTerminal;
  if (tty) stdin.echoMode = false; // hide typing
  final line = stdin.readLineSync() ?? '';
  if (tty) {
    stdin.echoMode = true;
    stdout.writeln(); // enter was not echoed
  }
  return line;
}

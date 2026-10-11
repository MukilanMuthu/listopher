import 'dart:io';

import 'package:listopher_server/server.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sqlite3/sqlite3.dart' show SqliteException;

import 'prompt_new_password.dart';

const _usage = 'usage: server [add-user <username> <display name> | '
    'set-password <username> | revoke-sessions <username>]';

// no args → serve. else run one admin command on the db and exit.
Future<void> main(List<String> args) async {
  final db = openServerDb(Platform.environment['DB_PATH'] ?? 'listopher.db');
  if (args.isEmpty) {
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    await io.serve(buildHandler(db), InternetAddress.anyIPv4, port);
    print('listening on :$port');
    return;
  }
  try {
    switch (args) {
      case ['add-user', final username, final displayName]:
        addUser(db, username, displayName, promptNewPassword());
        print('added $username');
      case ['set-password', final username]:
        setPassword(db, username, promptNewPassword());
        print('password set for $username');
      case ['revoke-sessions', final username]:
        revokeSessions(db, username);
        print('sessions revoked for $username');
      default:
        stderr.writeln(_usage);
        exit(64);
    }
  } on StateError catch (e) {
    stderr.writeln('error: ${e.message}'); // unknown user
    exit(1);
  } on SqliteException {
    stderr.writeln('error: username already exists'); // only unique clash can happen here
    exit(1);
  }
  db.close();
}

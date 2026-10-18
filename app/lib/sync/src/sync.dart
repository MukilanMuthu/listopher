import 'package:http/http.dart' as http;

import 'package:listopher/store/store.dart';

import 'sync_space.dart';

/// sync every shared space with its server.
/// throws on the first failure; later spaces wait for the next sync.
/// ponytail: one broken space blocks the ones after it.
Future<void> sync(AppDb db, http.Client client) async {
  for (final space in await watchSpaces(db).first) {
    if (space.serverUrl != null) await syncSpace(db, client, space);
  }
}

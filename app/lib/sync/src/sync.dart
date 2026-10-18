import 'package:http/http.dart' as http;

import 'package:listopher/store/store.dart';

import 'sync_failed.dart';
import 'sync_space.dart';

/// sync every shared space with its server.
/// a failing space does not stop the others; throws SyncFailed once at the end.
Future<void> sync(AppDb db, http.Client client) async {
  final errors = <Object>[];
  for (final space in await watchSpaces(db).first) {
    if (space.serverUrl == null) continue; // private: never leaves the phone
    try {
      await syncSpace(db, client, space);
    } catch (e) {
      errors.add(e); // keep going, report at the end
    }
  }
  if (errors.isNotEmpty) throw SyncFailed(errors);
}

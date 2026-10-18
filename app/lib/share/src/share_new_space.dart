import 'package:http/http.dart' as http;
import 'package:listopher_core/core.dart';

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

import 'push_space.dart';

/// make a shared space on [serverUrl]: server first, then the phone, then upload.
/// false = could not register it (no account there, or server said no / is down):
/// nothing is created. true = space exists, even if the upload failed (ops wait in outbox).
/// failed upload is retried by the next sync.
Future<bool> shareNewSpace(
  AppDb db,
  http.Client client,
  String serverUrl,
  String name,
) async {
  final accounts = await watchServerAccounts(db).first;
  final account = accounts.where((a) => a.url == serverUrl).firstOrNull;
  if (account == null) return false;
  final spaceId = newId();
  try {
    await createSpace(client, serverUrl, account.token, spaceId);
  } catch (_) {
    return false; // server down or refused: leave no half space on the phone
  }
  await createSharedSpace(db, spaceId: spaceId, serverUrl: serverUrl, name: name);
  try {
    await pushSpace(db, client, spaceId);
  } catch (_) {
    // space is real on both sides; the op will go up later
  }
  return true;
}

import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';

/// sync one shared space: send outbox, pull new ops (all pages), refresh member
/// names, rebuild state (only if something was sent or pulled).
/// server says the space is gone (deleted by the owner): forget it here, no throw.
/// throws if the server cannot be reached or says no.
Future<void> syncSpace(AppDb db, http.Client client, SpaceRow space) async {
  final url = space.serverUrl!; // caller passes shared spaces only
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == url);
  var changed = false; // op log moved: state must be replayed
  try {
    changed = await pushSpace(db, client, space.id) > 0;
    // page loop: empty page = caught up. start once, then follow each page's last seq
    var after = await lastSeq(db, space.id);
    while (true) {
      final page = await pullOps(client, url, account.token, space.id, after);
      if (page.isEmpty) break;
      await storeOps(db, page);
      after = page.last.serverSeq!;
      changed = true;
    }
    // names for blame; kept locally so they work offline
    await saveMembers(db, space.id, await listMembers(client, url, account.token, space.id));
  } on SpaceGone {
    await forgetSpace(db, space.id); // unsent ops die with the space
    return;
  }
  if (changed) await rebuildSpace(db, space.id);
}

import 'package:http/http.dart' as http;
import 'package:listopher_core/core.dart';

import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';

/// apply a check or manual sync action. true means sync failed; null means no sync ran.
Future<bool?> performWidgetAction(AppDb db, http.Client client, Uri uri) async {
  if (uri.scheme != 'listopher') {
    return null;
  }
  if (uri.host == 'check') {
    final spaceId = uri.queryParameters['space'];
    final itemId = uri.queryParameters['item'];
    if (spaceId == null || itemId == null) {
      return null;
    }
    if (!(await watchSpaces(db).first).any((space) => space.id == spaceId)) {
      return null;
    }
    ItemRow? item;
    for (final row in await watchItems(db).first) {
      if (row.id == itemId) item = row;
    }
    if (item == null || item.spaceId != spaceId) {
      return null;
    }
    await record(
      db,
      spaceId: spaceId,
      itemId: itemId,
      body: item.checked ? const ItemUncheck() : const ItemCheck(),
    );
    return null;
  }
  if (uri.host == 'sync') {
    try {
      await sync(db, client); // manual widget sync bypasses periodic back-off
      return false;
    } catch (_) {
      return true;
    }
  }
  return null;
}

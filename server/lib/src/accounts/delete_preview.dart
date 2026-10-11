import 'package:sqlite3/sqlite3.dart';

import '../spaces/spaces.dart';

// what delete-account would do to owned spaces: pass on or delete.
Map<String, List<String>> deletePreview(Database db, String accountId) {
  final transfer = <String>[];
  final delete = <String>[];
  for (final id in ownedSpaceIds(db, accountId)) {
    (pickNewOwner(db, id, accountId) == null ? delete : transfer).add(id);
  }
  return {'transfer': transfer, 'delete': delete};
}

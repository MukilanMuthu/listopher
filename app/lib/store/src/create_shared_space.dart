import 'package:listopher_core/core.dart';

import 'app_db.dart';
import 'record.dart';

/// make a shared space that lives on [serverUrl]. needs a saved account there.
/// the space.create op lands in the outbox. never private: private is never shared.
Future<void> createSharedSpace(
  AppDb db, {
  required String spaceId,
  required String serverUrl,
  required String name,
}) {
  return record(db,
      spaceId: spaceId,
      serverUrl: serverUrl,
      body: SpaceCreate(name: name, private: false));
}

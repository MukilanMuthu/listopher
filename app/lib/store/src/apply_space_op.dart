import 'package:listopher_core/core.dart';

import 'app_db.dart';

/// pure: space row after op. null current = space not there yet.
SpaceRow? applySpaceOp(SpaceRow? current, Op op) {
  final body = op.body;
  // create makes the row. not shared yet, so no server url
  if (body is SpaceCreate) {
    return SpaceRow(
      id: op.spaceId,
      name: body.name,
      private: body.private,
      serverUrl: null,
      createdBy: op.userId,
      createdAt: op.clientTime,
    );
  }
  // rename needs an existing space, else ignore
  if (body is SpaceRename && current != null) return current.copyWith(name: body.name);
  return current; // item ops and ignored ops leave space alone
}

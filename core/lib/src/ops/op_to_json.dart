import 'body_to_json.dart';
import 'op.dart';

/// Op → json map. wire format between app + server.
Map<String, Object?> opToJson(Op op) => {
      'id': op.id,
      'space_id': op.spaceId,
      'item_id': op.itemId,
      'user_id': op.userId,
      // always utc. phones in different timezones must agree.
      'client_time': op.clientTime.toUtc().toIso8601String(),
      'server_seq': op.serverSeq,
      // body split out: own file, own job.
      ...bodyToJson(op.body),
    };

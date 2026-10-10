import 'body_from_json.dart';
import 'op.dart';

/// json map → Op. reverse of opToJson.
/// bad input (missing field, wrong type) throws TypeError/FormatException.
/// server must catch → reply 400. never trust phone json.
Op opFromJson(Map<String, Object?> json) => Op(
      id: json['id'] as String,
      groupId: json['group_id'] as String?,
      listId: json['list_id'] as String,
      itemId: json['item_id'] as String?,
      userId: json['user_id'] as String,
      // utc in, utc kept.
      clientTime: DateTime.parse(json['client_time'] as String),
      serverSeq: json['server_seq'] as int?,
      body: bodyFromJson(json['type'] as String, json['payload'] as Map<String, Object?>),
    );

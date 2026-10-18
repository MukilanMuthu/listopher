import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:listopher_core/core.dart';

/// send ops to a space on the server. returns {op id: server seq}.
/// safe to resend: server answers known op ids with their old seq.
/// throws on any answer but 200 or no answer.
Future<Map<String, int>> pushOps(
  http.Client client,
  String serverUrl,
  String token,
  String spaceId,
  List<Op> ops,
) async {
  final res = await client.post(
    Uri.parse(serverUrl.trim()).resolve('/spaces/$spaceId/ops'),
    headers: {'Authorization': 'Bearer $token'},
    body: jsonEncode([for (final op in ops) opToJson(op)]),
  );
  if (res.statusCode != 200) throw http.ClientException('push ops: ${res.statusCode}');
  return (jsonDecode(res.body) as Map<String, dynamic>).cast<String, int>();
}

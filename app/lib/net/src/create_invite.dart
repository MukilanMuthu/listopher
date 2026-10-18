import 'dart:convert';

import 'package:http/http.dart' as http;

/// ask the server for a new invite token for a space (owner only).
/// the old token stops working. throws on any answer but 200 (403 = not owner) or no answer.
Future<String> createInvite(
  http.Client client,
  String serverUrl,
  String token,
  String spaceId,
) async {
  final res = await client.post(
    Uri.parse(serverUrl.trim()).resolve('/spaces/$spaceId/invite'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw http.ClientException('create invite: ${res.statusCode}');
  return (jsonDecode(res.body) as Map<String, dynamic>)['invite'] as String;
}

import 'dart:convert';

import 'package:http/http.dart' as http;

/// ids of the shared spaces this account is a member of.
/// throws on any answer but 200 or no answer.
Future<List<String>> listMySpaces(
  http.Client client,
  String serverUrl,
  String token,
) async {
  final res = await client.get(
    Uri.parse(serverUrl.trim()).resolve('/me/spaces'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw http.ClientException('list spaces: ${res.statusCode}');
  final ids = (jsonDecode(res.body) as Map<String, dynamic>)['space_ids'] as List;
  return [for (final id in ids) id as String];
}

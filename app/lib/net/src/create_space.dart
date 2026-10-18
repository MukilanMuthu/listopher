import 'dart:convert';

import 'package:http/http.dart' as http;

/// register a shared space on the server; caller becomes owner.
/// throws on any answer but 201 (409 = id taken) or no answer.
/// ponytail: server url path prefix is dropped, same as login.
Future<void> createSpace(
  http.Client client,
  String serverUrl,
  String token,
  String spaceId,
) async {
  final res = await client.post(
    Uri.parse(serverUrl.trim()).resolve('/spaces'),
    headers: {'Authorization': 'Bearer $token'},
    body: jsonEncode({'space_id': spaceId}),
  );
  if (res.statusCode != 201) throw http.ClientException('create space: ${res.statusCode}');
}

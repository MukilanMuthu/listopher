import 'dart:convert';

import 'package:http/http.dart' as http;

import 'bad_invite.dart';

/// become a member of a space on the server, using its invite.
/// throws BadInvite on 403, else on any answer but 200 (404 = no such space) or no answer.
Future<void> joinSpace(
  http.Client client,
  String serverUrl,
  String token,
  String spaceId,
  String invite,
) async {
  final res = await client.post(
    Uri.parse(serverUrl.trim()).resolve('/spaces/$spaceId/join'),
    headers: {'Authorization': 'Bearer $token'},
    body: jsonEncode({'invite': invite}),
  );
  if (res.statusCode == 403) throw BadInvite(spaceId);
  if (res.statusCode != 200) throw http.ClientException('join space: ${res.statusCode}');
}

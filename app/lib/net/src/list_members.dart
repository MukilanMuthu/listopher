import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_expired.dart';
import 'space_gone.dart';

/// members of a shared space: user id → (display name, role).
/// throws SessionExpired on 401, SpaceGone on 404, else on any answer but 200 or no answer.
Future<Map<String, ({String name, String role})>> listMembers(
  http.Client client,
  String serverUrl,
  String token,
  String spaceId,
) async {
  final res = await client.get(
    Uri.parse(serverUrl.trim()).resolve('/spaces/$spaceId/members'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode == 401) throw SessionExpired(); // token dead
  if (res.statusCode == 404) throw SpaceGone(spaceId);
  if (res.statusCode != 200) throw http.ClientException('list members: ${res.statusCode}');
  final rows = jsonDecode(res.body) as List; // bare list, see ADR 8
  return {
    for (final m in rows)
      (m as Map)['user_id'] as String: (
        name: m['display_name'] as String,
        role: m['role'] as String,
      ),
  };
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:listopher_core/core.dart';

import 'session_expired.dart';
import 'space_gone.dart';

/// one page (max 500) of a space's ops with server seq > [after], oldest first.
/// empty = caught up. throws SessionExpired on 401, SpaceGone on 404, else on any answer but 200 or no answer.
Future<List<Op>> pullOps(
  http.Client client,
  String serverUrl,
  String token,
  String spaceId,
  int after,
) async {
  final res = await client.get(
    Uri.parse(serverUrl.trim()).resolve('/spaces/$spaceId/ops?after=$after'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode == 401) throw SessionExpired(); // token dead
  if (res.statusCode == 404) throw SpaceGone(spaceId); // deleted on server
  if (res.statusCode != 200) throw http.ClientException('pull ops: ${res.statusCode}');
  final ops = (jsonDecode(res.body) as Map<String, dynamic>)['ops'] as List;
  return [for (final o in ops) opFromJson(o as Map<String, Object?>)];
}

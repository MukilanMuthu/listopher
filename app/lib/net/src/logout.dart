import 'package:http/http.dart' as http;

import 'session_expired.dart';

/// end my session on the server. throws SessionExpired on 401 (already ended),
/// else on any answer but 200 or no answer.
Future<void> logout(http.Client client, String serverUrl, String token) async {
  final res = await client.post(
    Uri.parse(serverUrl.trim()).resolve('/auth/logout'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode == 401) throw SessionExpired(); // token dead
  if (res.statusCode != 200) throw http.ClientException('logout: ${res.statusCode}');
}

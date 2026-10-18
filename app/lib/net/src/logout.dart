import 'package:http/http.dart' as http;

/// end my session on the server. throws on any answer but 200 or no answer.
Future<void> logout(http.Client client, String serverUrl, String token) async {
  final res = await client.post(
    Uri.parse(serverUrl.trim()).resolve('/auth/logout'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw http.ClientException('logout: ${res.statusCode}');
}

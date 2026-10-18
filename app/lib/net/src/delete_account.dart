import 'package:http/http.dart' as http;

/// delete my account on the server. throws on any answer but 200 or no answer.
Future<void> deleteAccount(http.Client client, String serverUrl, String token) async {
  final res = await client.delete(
    Uri.parse(serverUrl.trim()).resolve('/me'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw http.ClientException('delete account: ${res.statusCode}');
}

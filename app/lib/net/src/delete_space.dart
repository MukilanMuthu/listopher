import 'package:http/http.dart' as http;

/// delete a shared space on the server (owner only): ops, members, space.
/// throws on any answer but 200 (403 = not owner) or no answer.
Future<void> deleteSpace(
  http.Client client,
  String serverUrl,
  String token,
  String spaceId,
) async {
  final res = await client.delete(
    Uri.parse(serverUrl.trim()).resolve('/spaces/$spaceId'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw http.ClientException('delete space: ${res.statusCode}');
}

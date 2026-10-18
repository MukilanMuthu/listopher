import 'dart:convert';

import 'package:http/http.dart' as http;

/// what deleting my account would do to spaces I own (ADR 8):
/// `transfer` passes to another member, `delete` has no eligible member.
/// throws on any answer but 200 or no answer.
Future<({List<String> transfer, List<String> delete})> deletePreview(
  http.Client client,
  String serverUrl,
  String token,
) async {
  final res = await client.get(
    Uri.parse(serverUrl.trim()).resolve('/me/delete-preview'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode != 200) throw http.ClientException('delete preview: ${res.statusCode}');
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  return (
    transfer: [for (final id in json['transfer'] as List) id as String],
    delete: [for (final id in json['delete'] as List) id as String],
  );
}

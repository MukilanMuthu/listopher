import 'dart:convert';

import 'package:http/http.dart' as http;

import 'login_result.dart';

/// log in to a server. 200 = account, 401 = wrong credentials,
/// 429 = locked, no answer = unreachable.
/// ponytail: any other status counts as unreachable. server url path prefix is dropped.
Future<LoginResult> login(
  http.Client client,
  String serverUrl,
  String username,
  String password,
) async {
  try {
    final res = await client.post(
      Uri.parse(serverUrl.trim()).resolve('/auth/login'),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 401) return const LoginFailed(LoginFailure.wrongCredentials);
    if (res.statusCode == 429) return const LoginFailed(LoginFailure.locked);
    if (res.statusCode != 200) return const LoginFailed(LoginFailure.unreachable);
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return LoginOk(
      accountId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      token: json['token'] as String,
    );
  } catch (_) {
    // socket error, bad url, bad json: all "cannot talk to server"
    return const LoginFailed(LoginFailure.unreachable);
  }
}

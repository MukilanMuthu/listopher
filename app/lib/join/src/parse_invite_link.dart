import 'invite_link.dart';

/// read a pasted invite link. throws BadInviteLink if it is not one.
InviteLink parseInviteLink(String text) {
  final uri = Uri.tryParse(text.trim()); // null = not even a uri
  final q = uri?.queryParameters ?? const <String, String>{};
  final server = q['server'], space = q['space'], invite = q['invite'];
  if (uri == null ||
      uri.scheme != 'listopher' ||
      uri.host != 'join' ||
      (server ?? '').isEmpty ||
      (space ?? '').isEmpty ||
      (invite ?? '').isEmpty) {
    throw BadInviteLink(text);
  }
  return InviteLink(server!, space!, invite!);
}

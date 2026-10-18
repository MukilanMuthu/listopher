/// make the link the owner shares. Uri escapes the parts for us.
String buildInviteLink(String server, String space, String invite) => Uri(
      scheme: 'listopher',
      host: 'join',
      queryParameters: {'server': server, 'space': space, 'invite': invite},
    ).toString();

/// the three parts of listopher://join?server=…&space=…&invite=…
class InviteLink {
  final String server;
  final String space;
  final String invite;
  const InviteLink(this.server, this.space, this.invite);
}

/// pasted text is not a valid invite link.
class BadInviteLink implements Exception {
  final String text;
  const BadInviteLink(this.text);

  @override
  String toString() => 'bad invite link: $text';
}

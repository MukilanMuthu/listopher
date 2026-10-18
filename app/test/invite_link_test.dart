// invite link: build then parse, and bad links get a typed error.
import 'package:flutter_test/flutter_test.dart';
import 'package:listopher/join/join.dart';

void main() {
  test('built link parses back to the same parts', () {
    final link = buildInviteLink('http://srv:8080/x', 's1', 'tok&en');
    final p = parseInviteLink(link);
    expect(p.server, 'http://srv:8080/x');
    expect(p.space, 's1');
    expect(p.invite, 'tok&en');
  });

  test('parse trims spaces around a pasted link', () {
    final p = parseInviteLink('  ${buildInviteLink('http://srv', 's1', 't')}\n');
    expect(p.space, 's1');
  });

  test('parsed server is normalized so it matches the stored account url', () {
    final p = parseInviteLink(buildInviteLink('HTTP://Srv:8080/', 's1', 't'));
    expect(p.server, 'http://srv:8080');
  });

  test('bad links throw BadInviteLink', () {
    for (final bad in [
      '',
      'not a link',
      'https://join?server=a&space=b&invite=c', // wrong scheme
      'listopher://leave?server=a&space=b&invite=c', // wrong action
      'listopher://join?server=a&space=b', // no invite
      'listopher://join?server=&space=b&invite=c', // blank part
    ]) {
      expect(() => parseInviteLink(bad), throwsA(isA<BadInviteLink>()), reason: bad);
    }
  });
}

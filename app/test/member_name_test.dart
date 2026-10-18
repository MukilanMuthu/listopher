// who is this user id? private → local name, shared → cached member name, else "deleted user".
import 'package:flutter_test/flutter_test.dart';
import 'package:listopher/store/store.dart';

void main() {
  final me = UserRow(id: 'local', displayName: 'Mukil', isMe: true);
  SpaceRow space({required bool private}) => SpaceRow(
      id: 's', name: 'Home', private: private, createdBy: 'x', createdAt: DateTime(2026));
  const members = {'a1': 'Alice'};

  test('private space: my local id shows my local name', () {
    expect(memberName('local', space(private: true), me, members, 'gone'), 'Mukil');
  });
  test('shared space: id shows the cached member name', () {
    expect(memberName('a1', space(private: false), me, members, 'gone'), 'Alice');
  });
  test('unknown id shows the deleted-user label', () {
    expect(memberName('zz', space(private: false), me, members, 'gone'), 'gone');
    expect(memberName('zz', space(private: true), me, members, 'gone'), 'gone');
  });
}

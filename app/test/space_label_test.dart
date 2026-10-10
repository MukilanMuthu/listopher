import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/src/space_label.dart';

void main() {
  // space with given privacy + stored name
  SpaceRow space(String name, {required bool private}) => SpaceRow(
      id: 's',
      name: name,
      private: private,
      serverUrl: null,
      createdBy: 'u',
      createdAt: DateTime.utc(2026));

  test('private → localized label, stored name ignored', () async {
    final t = await AppLocalizations.delegate.load(const Locale('en'));
    expect(spaceLabel(space('private', private: true), t), 'Private');
  });

  test('shared → its name', () async {
    final t = await AppLocalizations.delegate.load(const Locale('en'));
    expect(spaceLabel(space('Home', private: false), t), 'Home');
  });
}

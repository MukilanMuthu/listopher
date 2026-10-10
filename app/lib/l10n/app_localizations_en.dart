// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Listopher';

  @override
  String get yourName => 'Your name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get add => 'Add';

  @override
  String get itemsTab => 'Items';

  @override
  String get spacesTab => 'Spaces';

  @override
  String get privateSpace => 'Private';

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get newSpace => 'New space';

  @override
  String get spaceName => 'Space name';

  @override
  String get pickSpace => 'Pick a space';

  @override
  String get editItem => 'Edit item';

  @override
  String get itemName => 'Item name';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get invalidQuantity => 'Not a number';
}

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

  @override
  String get logInToServer => 'Log in to server';

  @override
  String get serverUrl => 'Server address';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get logIn => 'Log in';

  @override
  String signedInTo(String server) {
    return 'Signed in to $server';
  }

  @override
  String get wrongCredentials => 'Wrong username or password';

  @override
  String get accountLocked => 'Account locked, try again later';

  @override
  String get serverUnreachable => 'Cannot reach the server';

  @override
  String get pickServer => 'Pick a server';

  @override
  String get couldNotShare => 'Could not create the space on the server';

  @override
  String get sync => 'Sync';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get backgroundSyncFailed => 'Background sync failed';

  @override
  String get deleteSpace => 'Delete space';

  @override
  String get delete => 'Delete';

  @override
  String deleteSpaceQuestion(String space) {
    return 'Delete $space for everyone?';
  }

  @override
  String get couldNotDeleteSpace => 'Could not delete the space';

  @override
  String get logOut => 'Log out';

  @override
  String get couldNotLogOut => 'Could not log out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String deleteAccountQuestion(String server) {
    return 'Delete your account on $server?';
  }

  @override
  String handedOver(String spaces) {
    return 'Handed to another member: $spaces';
  }

  @override
  String willBeDeleted(String spaces) {
    return 'Deleted: $spaces';
  }

  @override
  String get couldNotDeleteAccount => 'Could not delete the account';

  @override
  String get invite => 'Invite';

  @override
  String get inviteLink => 'Invite link';

  @override
  String get copy => 'Copy';

  @override
  String get couldNotInvite => 'Could not make an invite link';

  @override
  String get joinWithLink => 'Join with a link';

  @override
  String get join => 'Join';

  @override
  String get badLink => 'Not a valid invite link';

  @override
  String get badInvite => 'This invite no longer works';

  @override
  String get couldNotJoin => 'Could not join the space';

  @override
  String get deletedUser => 'deleted user';

  @override
  String askedBy(String name) {
    return 'asked by $name';
  }

  @override
  String boughtBy(String name) {
    return 'bought by $name';
  }

  @override
  String get scanQr => 'Scan QR';

  @override
  String get sessionExpired => 'Session expired, log in again';

  @override
  String unsentWillBeLost(int count) {
    return '$count unsent changes will be lost';
  }

  @override
  String get couldNotRestore => 'Could not restore your spaces';

  @override
  String get scannerUnavailable =>
      'Scanner unavailable — paste the link instead';

  @override
  String get somethingWentWrong => 'Something went wrong';
}

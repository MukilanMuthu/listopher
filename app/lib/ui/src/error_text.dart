import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/sync/sync.dart';

/// message for a failed server call: dead token says "log in again",
/// anything else gets [other] (the action's own message).
/// a combined sync error counts as dead token if any space hit one.
String errorText(AppLocalizations t, Object error, String other) {
  final dead = error is SessionExpired ||
      (error is SyncFailed && error.errors.any((e) => e is SessionExpired));
  return dead ? t.sessionExpired : other;
}

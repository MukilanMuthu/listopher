import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/net/net.dart';

/// message for a failed server call: dead token says "log in again",
/// anything else gets [other] (the action's own message).
String errorText(AppLocalizations t, Object error, String other) =>
    error is SessionExpired ? t.sessionExpired : other;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

/// name shown for a space. private → localized "Private" (stored name is a placeholder).
String spaceLabel(SpaceRow space, AppLocalizations t) =>
    space.private ? t.privateSpace : space.name;

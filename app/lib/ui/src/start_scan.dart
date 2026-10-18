import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/join/join.dart';
import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'join_from_text.dart';

/// the scan action: open the scanner, run the scanned text through the join flow.
/// cancel stops quietly. a broken scanner shows a message (paste the link instead).
Future<void> startScan(BuildContext context, AppDb db, http.Client client) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final String? text;
  try {
    text = await scanQr();
  } on ScannerUnavailable {
    messenger.showSnackBar(SnackBar(content: Text(t.scannerUnavailable)));
    return;
  }
  if (text == null) return;
  if (context.mounted) await joinFromText(context, db, client, text);
}

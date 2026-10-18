import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/join/join.dart';
import 'package:listopher/store/store.dart';

import 'join_from_text.dart';

/// the scan action: open the scanner, run the scanned text through the join flow.
/// cancel stops quietly.
Future<void> startScan(BuildContext context, AppDb db, http.Client client) async {
  final text = await scanQr();
  if (text == null) return;
  if (context.mounted) await joinFromText(context, db, client, text);
}

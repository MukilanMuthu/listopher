import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/store/store.dart';

import 'join_from_text.dart';
import 'show_join_dialog.dart';

/// the join action: ask for a pasted link, then run the join flow. cancel stops quietly.
Future<void> startJoin(BuildContext context, AppDb db, http.Client client) async {
  final text = await showJoinDialog(context);
  if (text == null) return;
  if (context.mounted) await joinFromText(context, db, client, text);
}

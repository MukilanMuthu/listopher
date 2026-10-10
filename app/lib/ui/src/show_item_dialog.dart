import 'package:flutter/material.dart';

import 'package:listopher/store/store.dart';

import 'item_dialog.dart';

/// ask for item fields. existing = prefill (edit); spaceName = title when adding. null result = cancelled.
/// ponytail: no note field, requester picker or buyer picker yet.
/// only one local user exists. they come with the join module.
Future<({String name, double? quantity, String? unit})?> showItemDialog(
  BuildContext context, {
  ItemRow? existing,
  String? spaceName,
}) {
  return showDialog<({String name, double? quantity, String? unit})>(
    context: context,
    builder: (_) => ItemDialog(existing: existing, spaceName: spaceName),
  );
}

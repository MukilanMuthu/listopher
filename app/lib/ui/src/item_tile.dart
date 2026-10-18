import 'package:flutter/material.dart';
import 'package:listopher_core/core.dart';

import 'package:listopher/store/store.dart';

import 'package:listopher/l10n/app_localizations.dart';

import 'format_quantity.dart';
import 'show_item_dialog.dart';

/// one item row: checkbox, name, "qty unit · space", "asked by X · bought by Y".
/// tap = edit, swipe = delete.
class ItemTile extends StatelessWidget {
  final AppDb db;
  final UserRow me;
  final ItemRow item;
  final SpaceRow space; // where the item lives
  final Map<String, String> members; // cached names of that space
  final String spaceLabel; // shown after qty/unit
  const ItemTile({
    super.key,
    required this.db,
    required this.me,
    required this.item,
    required this.space,
    required this.members,
    required this.spaceLabel,
  });

  // tick = check (checker is the buyer), untick = uncheck. no questions asked.
  Future<void> _toggle() => record(db,
      spaceId: item.spaceId,
      itemId: item.id,
      body: item.checked ? const ItemUncheck() : const ItemCheck());

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // "asked by X", plus "bought by Y" once checked. unknown id = deleted user
    String name(String id) => memberName(id, space, me, members, t.deletedUser);
    final blame = [
      t.askedBy(name(item.requestedBy)),
      if (item.checkedBy != null) t.boughtBy(name(item.checkedBy!)),
    ].join(' · ');
    // "1.5 kg", "1", "kg" or nothing
    final amount = [
      if (item.quantity != null) formatQuantity(item.quantity!),
      if (item.unit != null) item.unit!,
    ].join(' ');
    // "1.5 kg · Home", or just the space when no qty/unit
    final detail = [amount, spaceLabel].where((p) => p.isNotEmpty).join(' · ');

    return Dismissible(
      key: ValueKey(item.id),
      onDismissed: (_) => record(
        db,
        spaceId: item.spaceId,
        itemId: item.id,
        body: const ItemDelete(),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.checked,
          onChanged: (_) => _toggle(),
        ),
        title: Text(
          item.name,
          style: item.checked ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
        ),
        // two lines: where, then who
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(detail), Text(blame)],
        ),
        isThreeLine: true,
        onTap: () async {
          final result = await showItemDialog(context, existing: item);
          if (result == null) return;
          // full state, keep the old note
          await record(
            db,
            spaceId: item.spaceId,
            itemId: item.id,
            body: ItemUpdate(
              name: result.name,
              quantity: result.quantity,
              unit: result.unit,
              note: item.note,
            ),
          );
        },
      ),
    );
  }
}

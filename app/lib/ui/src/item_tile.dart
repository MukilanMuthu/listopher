import 'package:flutter/material.dart';
import 'package:listopher_core/core.dart';

import 'package:listopher/store/store.dart';

import 'package:listopher/l10n/app_localizations.dart';

import 'format_quantity.dart';
import 'show_buyer_picker.dart';
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

  // tick = check, untick = uncheck. shared space asks who bought it (me first).
  Future<void> _toggle(BuildContext context) async {
    final body = item.checked ? const ItemUncheck() : await _check(context);
    if (body == null) return; // picker cancelled
    await record(db, spaceId: item.spaceId, itemId: item.id, body: body);
  }

  // the check op: private = me bought it, shared = pick the buyer. null = cancelled
  Future<ItemCheck?> _check(BuildContext context) async {
    final myId = await userIdIn(db, space, me);
    if (space.private) return ItemCheck(fulfilledBy: myId);
    if (!context.mounted) return null;
    // me first (default), then the other members
    final buyer = await showBuyerPicker(
        context, {myId: members[myId] ?? me.displayName, ...members});
    return buyer == null ? null : ItemCheck(fulfilledBy: buyer);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // "asked by X", plus "bought by Y" once checked. unknown id = deleted user
    String name(String id) => memberName(id, space, me, members, t.deletedUser);
    final blame = [
      t.askedBy(name(item.requestedBy)),
      if (item.fulfilledBy != null) t.boughtBy(name(item.fulfilledBy!)),
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
          onChanged: (_) => _toggle(context),
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

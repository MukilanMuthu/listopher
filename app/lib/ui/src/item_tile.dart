import 'package:flutter/material.dart';
import 'package:listopher_core/core.dart';

import 'package:listopher/store/store.dart';

import 'format_quantity.dart';
import 'show_item_dialog.dart';

/// one item row: checkbox, name, "qty unit · space". tap = edit, swipe = delete.
class ItemTile extends StatelessWidget {
  final AppDb db;
  final UserRow me;
  final ItemRow item;
  final String spaceLabel; // shown after qty/unit
  const ItemTile({
    super.key,
    required this.db,
    required this.me,
    required this.item,
    required this.spaceLabel,
  });

  @override
  Widget build(BuildContext context) {
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
          // tick = check (me bought it), untick = uncheck
          onChanged: (_) => record(
            db,
            spaceId: item.spaceId,
            itemId: item.id,
            body: item.checked ? const ItemUncheck() : ItemCheck(fulfilledBy: me.id),
          ),
        ),
        title: Text(
          item.name,
          style: item.checked ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
        ),
        subtitle: Text(detail),
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

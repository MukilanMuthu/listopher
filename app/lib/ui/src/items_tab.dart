import 'package:flutter/material.dart';
import 'package:listopher_core/core.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'item_tile.dart';
import 'show_item_dialog.dart';
import 'show_space_picker.dart';
import 'space_label.dart';

/// items of all spaces. FAB = adding mode: dialog reopens after each Add.
class ItemsTab extends StatefulWidget {
  final AppDb db;
  final UserRow me;
  final String? selectedSpaceId;
  const ItemsTab({
    super.key,
    required this.db,
    required this.me,
    this.selectedSpaceId,
  });

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  // pick space (skip when only one), then loop: dialog → save → dialog, until Cancel
  Future<void> _add() async {
    final t = AppLocalizations.of(context);
    final spaces = await watchSpaces(widget.db).first;
    if (!mounted) return;
    final space = spaces.length == 1
        ? spaces.single
        : await showSpacePicker(context, spaces);
    if (space == null || !mounted) return;
    while (true) {
      // screen gone mid-loop: stop
      if (!mounted) return;
      final result = await showItemDialog(
        context,
        spaceName: spaceLabel(space, t),
      );
      // cancel ends the loop
      if (result == null) break;
      await record(
        widget.db,
        spaceId: space.id,
        itemId: newId(),
        body: ItemAdd(
          name: result.name,
          quantity: result.quantity,
          unit: result.unit,
          note: null,
          requestedBy: await userIdIn(widget.db, space, widget.me),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      // spaces stream gives names, items stream gives rows
      body: StreamBuilder<List<SpaceRow>>(
        stream: watchSpaces(widget.db),
        builder: (context, spaceSnap) =>
            StreamBuilder<Map<String, Map<String, String>>>(
              stream: watchMembers(widget.db),
              builder: (context, memberSnap) => StreamBuilder<List<ItemRow>>(
                stream: watchItems(widget.db),
                builder: (context, itemSnap) {
                  final items = (itemSnap.data ?? [])
                      .where(
                        (item) =>
                            widget.selectedSpaceId == null ||
                            item.spaceId == widget.selectedSpaceId,
                      )
                      .toList();
                  final spaces = {
                    for (final s in spaceSnap.data ?? <SpaceRow>[]) s.id: s,
                  };
                  if (items.isEmpty) return Center(child: Text(t.noItemsYet));
                  // space id → label
                  final labels = {
                    for (final s in spaceSnap.data ?? <SpaceRow>[])
                      s.id: spaceLabel(s, t),
                  };
                  return ListView(
                    children: [
                      // item of a space not loaded yet: skip it for now
                      for (final item in items.where(
                        (i) => spaces.containsKey(i.spaceId),
                      ))
                        ItemTile(
                          db: widget.db,
                          me: widget.me,
                          item: item,
                          space: spaces[item.spaceId]!,
                          members: memberSnap.data?[item.spaceId] ?? const {},
                          spaceLabel: labels[item.spaceId] ?? '',
                        ),
                    ],
                  );
                },
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}

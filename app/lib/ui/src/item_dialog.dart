import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'format_quantity.dart';
import 'parse_quantity.dart';

/// dialog body for add/edit item. stateful: keeps fields + quantity error.
class ItemDialog extends StatefulWidget {
  final ItemRow? existing;

  /// title when adding (null when editing).
  final String? spaceName;
  const ItemDialog({super.key, this.existing, this.spaceName});

  @override
  State<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _quantity = TextEditingController(
    text: widget.existing?.quantity == null ? '' : formatQuantity(widget.existing!.quantity!),
  );
  late final _unit = TextEditingController(text: widget.existing?.unit);
  bool _quantityBad = false;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unit.dispose();
    super.dispose();
  }

  // check quantity; bad = show error and stay open, good = close with result
  void _submit() {
    final quantityText = _quantity.text.trim();
    final quantity = parseQuantity(quantityText);
    // text typed but not a number
    if (quantityText.isNotEmpty && quantity == null) {
      setState(() => _quantityBad = true);
      return;
    }
    final unit = _unit.text.trim();
    Navigator.pop(context, (
      name: _name.text.trim(),
      quantity: quantity,
      unit: unit.isEmpty ? null : unit,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? widget.spaceName ?? '' : t.editItem),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: t.itemName),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.quantity,
              errorText: _quantityBad ? t.invalidQuantity : null,
            ),
          ),
          TextField(
            controller: _unit,
            decoration: InputDecoration(labelText: t.unit),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          // name required
          onPressed: _name.text.trim().isEmpty ? null : _submit,
          // add mode says Add, edit mode says Save
          child: Text(widget.existing == null ? t.add : t.save),
        ),
      ],
    );
  }
}

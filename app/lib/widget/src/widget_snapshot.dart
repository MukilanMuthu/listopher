import 'package:listopher/store/store.dart';

/// build the minimal, ordered data Glance needs to draw the widget.
Map<String, Object?> widgetSnapshot(
  List<SpaceRow> spaces,
  List<ItemRow> items,
) => {
  'spaces': [
    for (final space in spaces)
      {
        'id': space.id,
        'name': space.name,
        'private': space.private,
        'items': [
          for (final item in items.where((i) => i.spaceId == space.id))
            {
              'id': item.id,
              'name': item.name,
              'quantity': item.quantity,
              'unit': item.unit,
              'checked': item.checked,
            },
        ],
      },
  ],
};

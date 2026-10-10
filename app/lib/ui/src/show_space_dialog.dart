import 'package:flutter/material.dart';

import 'space_dialog.dart';

/// ask for new space name. null = cancelled.
Future<String?> showSpaceDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const SpaceDialog(),
  );
}

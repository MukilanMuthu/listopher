import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:listopher/l10n/app_localizations.dart';

/// show an invite link: selectable text, Copy puts it on the clipboard and closes.
Future<void> showInviteDialog(BuildContext context, String link) {
  final t = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.inviteLink),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // white background so phone scanners can read it in dark mode
          SizedBox(
            width: 200,
            height: 200,
            child: QrImageView(data: link, backgroundColor: Colors.white),
          ),
          SelectableText(link),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: link));
            Navigator.pop(context);
          },
          child: Text(t.copy),
        ),
      ],
    ),
  );
}

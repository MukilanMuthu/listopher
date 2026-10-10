import 'package:flutter/material.dart';
import 'package:listopher_core/core.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'show_space_dialog.dart';
import 'space_label.dart';

/// all spaces: lock = private, group = shared. FAB makes a shared space.
class SpacesTab extends StatelessWidget {
  final AppDb db;
  const SpacesTab({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: StreamBuilder<List<SpaceRow>>(
        stream: watchSpaces(db),
        builder: (context, snap) => ListView(
          children: [
            for (final space in snap.data ?? <SpaceRow>[])
              // ponytail: tap does nothing yet. space details / members / QR invite come with the join module.
              ListTile(
                leading: Icon(space.private ? Icons.lock : Icons.group),
                title: Text(spaceLabel(space, t)),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final name = await showSpaceDialog(context);
          // cancelled = nothing to do
          if (name == null) return;
          await record(db, spaceId: newId(), body: SpaceCreate(name: name, private: false));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

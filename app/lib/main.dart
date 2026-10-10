import 'package:flutter/material.dart';

import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';

// app entry: open db, show app.
void main() {
  final db = openAppDb();
  runApp(ListopherApp(db: db));
}

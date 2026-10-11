import 'package:sqlite3/sqlite3.dart';

// does this space id exist?
bool spaceExists(Database db, String spaceId) =>
    db.select('SELECT 1 FROM spaces WHERE id = ?', [spaceId]).isNotEmpty;

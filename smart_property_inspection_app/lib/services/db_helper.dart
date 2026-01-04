import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'inspection.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE tbl_inspections(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            property_name TEXT,
            description TEXT,
            rating TEXT,
            latitude REAL,
            longitude REAL,
            date_created TEXT,
            photos TEXT
          )
        ''');
      },
    );
  }
}



import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static late Database database;
  static late String path;
  static late bool exist;
  Future init() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, "medicine.db");
    database = await openDatabase(path);

    List<Map<String, Object?>> table = await database.query('sqlite_master', where: 'name = ?', whereArgs: ['brand']);
    exist = table.isNotEmpty;
  }
}



import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static late Database database;
  static late String path;
  Future init() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, "medicine.db");
    database = await openDatabase(path);
  }
}

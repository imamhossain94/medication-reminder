import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/medicine.dart';
import '../models/medicine_details.dart';
import '../utils/constants.dart';

/// Owns the local copy of the open medicine database.
///
/// The database is **not** part of this app – it is downloaded from
/// [medicineDbRepoUrl]. See `lib/services/database_downloader.dart`.
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const String fileName = medicineDbFileName;
  static const int schemaVersion = 1;

  Database? _db;
  String _path = '';
  int _brandCount = 0;

  Database get database {
    final Database? db = _db;
    if (db == null || !db.isOpen) {
      throw StateError(
        'Medicine database is not open. Call DatabaseService.instance.open() first.',
      );
    }
    return db;
  }

  bool get isOpen => _db != null && _db!.isOpen;

  /// Absolute path of the database file inside the app sandbox.
  String get path => _path;

  /// Number of brand rows — used to sanity check a freshly installed file.
  int get brandCount => _brandCount;

  /// Where the database lives on this device.
  static Future<String> resolvePath() async {
    if (instance._path.isNotEmpty) return instance._path;
    final String databasesPath = await getDatabasesPath();
    instance._path = p.join(databasesPath, fileName);
    return instance._path;
  }

  /// True when a usable database file is already present.
  static Future<bool> isInstalled() async {
    final String filePath = await resolvePath();
    final File file = File(filePath);
    if (!file.existsSync()) return false;
    // A truncated/partial download must never be treated as a valid database.
    if (file.lengthSync() < 100000) return false;
    return _hasSqliteHeader(filePath);
  }

  static bool _hasSqliteHeader(String filePath) {
    try {
      final RandomAccessFile raf = File(filePath).openSync();
      try {
        final List<int> header = raf.readSync(16);
        const String magic = 'SQLite format 3';
        if (header.length < magic.length) return false;
        for (int i = 0; i < magic.length; i++) {
          if (header[i] != magic.codeUnitAt(i)) return false;
        }
        return true;
      } finally {
        raf.closeSync();
      }
    } catch (_) {
      return false;
    }
  }

  /// Opens the database read-only and caches a few stats.
  Future<void> open() async {
    if (isOpen) return;
    final String filePath = await resolvePath();
    if (!await isInstalled()) {
      throw StateError('Medicine database has not been downloaded yet.');
    }

    _db = await openDatabase(
      filePath,
      version: schemaVersion,
      readOnly: true,
      singleInstance: true,
    );

    // Fail fast when the file is valid sqlite but not the expected schema.
    await _assertSchema();
    _brandCount = await _countRows('brand');
  }

  Future<void> _assertSchema() async {
    final List<Map<String, Object?>> tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('brand','generic','company_name')",
    );
    if (tables.length < 3) {
      await close();
      throw StateError('Downloaded file is not a valid medicine database.');
    }
  }

  Future<int> _countRows(String table) async {
    final List<Map<String, Object?>> rows =
        await database.rawQuery('SELECT COUNT(*) AS c FROM $table');
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  DateTime? _fileTimestamp(String filePath) {
    try {
      return File(filePath).lastModifiedSync();
    } catch (_) {
      return null;
    }
  }

  /// When the installed database file was last written.
  DateTime? get installedAt => _fileTimestamp(_path);

  Future<void> close() async {
    final Database? db = _db;
    _db = null;
    if (db != null && db.isOpen) await db.close();
  }

  /// Deletes the local copy so the app can ask for a fresh download.
  Future<void> delete() async {
    await close();
    final File file = File(await resolvePath());
    if (file.existsSync()) {
      try {
        await file.delete();
      } catch (_) {/* ignore */}
    }
    _brandCount = 0;
  }

  // -------------------------------------------------------------------------
  // Queries
  // -------------------------------------------------------------------------

  static const String _selectBrand =
      "SELECT b.brand_id, b.generic_id, b.company_id, b.brand_name, b.form,"
      "       b.strength, b.price, b.packsize, c.company_name AS company_name"
      "  FROM brand b"
      "  LEFT JOIN company_name c ON c.company_id = b.company_id";

  /// Paginated brand search.
  ///
  /// [query] is always bound as a parameter – it is never interpolated into
  /// SQL, so quotes in the search box can no longer break the statement.
  Future<List<Medicine>> searchBrands({
    String query = '',
    int limit = 30,
    int offset = 0,
  }) async {
    final String trimmed = query.trim();
    final List<Object?>? args;
    final String where;

    if (trimmed.isEmpty) {
      where = '';
      args = null;
    } else {
      where =
          " WHERE b.brand_name LIKE ? ESCAPE '\\' COLLATE NOCASE"
          "    OR g.generic_name LIKE ? ESCAPE '\\' COLLATE NOCASE";
      args = <Object?>[
        '%${_escapeLike(trimmed)}%',
        '%${_escapeLike(trimmed)}%',
      ];
    }

    final List<Map<String, Object?>> rows = await database.rawQuery(
      '$_selectBrand'
      '${where.isEmpty ? '' : '  LEFT JOIN generic g ON g.generic_id = b.generic_id$where'}'
      ' ORDER BY b.brand_name COLLATE NOCASE'
      ' LIMIT ? OFFSET ?',
      <Object?>[...?args, limit, offset],
    );

    return rows.map(Medicine.fromRow).toList(growable: false);
  }

  /// Full detail (generic info included) for one brand row.
  Future<MedicineDetails?> detailsForBrand(String brandId) async {
    final List<Map<String, Object?>> rows = await database.rawQuery(
      'SELECT b.brand_id, b.generic_id, b.company_id, b.brand_name, b.form,'
      '       b.strength, b.price, b.packsize, c.company_name AS company_name,'
      '       g.generic_name AS generic_name, g.indication AS g_indication,'
      '       g.dose AS g_dose, g.contra_indication AS g_contra,'
      '       g.side_effect AS g_side_effect, g.precaution AS g_precaution,'
      '       g.interaction AS g_interaction, g."mode_of_action" AS g_moa,'
      '       p.pregnancy_name AS pregnancy_name'
      '  FROM brand b'
      '  LEFT JOIN company_name c ON c.company_id = b.company_id'
      '  LEFT JOIN generic g ON g.generic_id = b.generic_id'
      '  LEFT JOIN pregnancy_category p ON p.pregnancy_id = g.pregnancy_category_id'
      ' WHERE b.brand_id = ?'
      ' LIMIT 1',
      <Object?>[brandId],
    );

    if (rows.isEmpty) return null;
    final Map<String, Object?> row = rows.first;

    return MedicineDetails(
      medicine: Medicine.fromRow(row),
      genericName: (row['generic_name'] ?? '').toString(),
      indication: (row['g_indication'] ?? '').toString(),
      dose: (row['g_dose'] ?? '').toString(),
      contraIndication: (row['g_contra'] ?? '').toString(),
      sideEffect: (row['g_side_effect'] ?? '').toString(),
      precaution: (row['g_precaution'] ?? '').toString(),
      interaction: (row['g_interaction'] ?? '').toString(),
      modeOfAction: (row['g_moa'] ?? '').toString(),
      pregnancyCategory: (row['pregnancy_name'] ?? '').toString(),
    );
  }

  /// Other brands that share the same generic.
  Future<List<Medicine>> alternativesFor(String genericId,
      {String excludeBrandId = '', int limit = 12}) async {
    if (genericId.isEmpty) return <Medicine>[];
    final List<Map<String, Object?>> rows = await database.rawQuery(
      '$_selectBrand WHERE b.generic_id = ? AND b.brand_id != ?'
      ' ORDER BY b.brand_name COLLATE NOCASE LIMIT ?',
      <Object?>[genericId, excludeBrandId, limit],
    );
    return rows.map(Medicine.fromRow).toList(growable: false);
  }

  /// Number of medicines matching a search term (used for "N results").
  Future<int> countBrands({String query = ''}) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return _brandCount;
    final List<Map<String, Object?>> rows = await database.rawQuery(
      "SELECT COUNT(*) AS c FROM brand WHERE brand_name LIKE ? ESCAPE '\\' COLLATE NOCASE",
      <Object?>['%${_escapeLike(trimmed)}%'],
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  static String _escapeLike(String value) =>
      value.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
}

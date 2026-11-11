import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/farm_field.dart';
import '../models/pest_disease_record.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  static const String _databaseName = 'majova_agriworks.db';

  // Version 1 = Farm Location
  // Version 2 = Farm Fields
  // Version 3 = Pest & Disease Records
  static const int _databaseVersion = 3;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      _databaseName,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(
      Database db,
      int version,
      ) async {
    await _createFarmLocationTable(db);
    await _createFarmFieldsTable(db);
    await _createPestDiseaseRecordsTable(db);
  }

  Future<void> _upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await _createFarmFieldsTable(db);
    }

    if (oldVersion < 3) {
      await _createPestDiseaseRecordsTable(db);
    }
  }

  // =========================================================
  // TABLE CREATION
  // =========================================================

  Future<void> _createFarmLocationTable(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farm_location (
        id INTEGER PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        saved_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createFarmFieldsTable(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farm_fields (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        crop TEXT NOT NULL,
        size_hectares REAL NOT NULL,
        planting_date TEXT NOT NULL,
        expected_harvest_date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPestDiseaseRecordsTable(
      Database db,
      ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pest_disease_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        record_type TEXT NOT NULL,
        problem_name TEXT NOT NULL,
        crop TEXT NOT NULL,
        field_name TEXT NOT NULL,
        symptoms TEXT NOT NULL DEFAULT '',
        severity TEXT NOT NULL,
        status TEXT NOT NULL,
        detection_date TEXT NOT NULL,
        treatment TEXT NOT NULL DEFAULT '',
        treatment_date TEXT,
        notes TEXT NOT NULL DEFAULT '',
        photo_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // =========================================================
  // FARM LOCATION
  // =========================================================

  Future<void> saveFarmLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    final db = await database;

    await db.insert(
      'farm_location',
      {
        'id': 1,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'saved_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Object?>?> getFarmLocation() async {
    final db = await database;

    final results = await db.query(
      'farm_location',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  Future<bool> hasFarmLocation() async {
    final location = await getFarmLocation();
    return location != null;
  }

  Future<void> deleteFarmLocation() async {
    final db = await database;

    await db.delete(
      'farm_location',
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // =========================================================
  // FARM FIELDS
  // =========================================================

  Future<int> addFarmField(
      FarmField field,
      ) async {
    final db = await database;

    return db.insert(
      'farm_fields',
      field.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<FarmField>> getFarmFields() async {
    final db = await database;

    final results = await db.query(
      'farm_fields',
      orderBy: 'created_at DESC',
    );

    return results
        .map(
          (map) => FarmField.fromMap(map),
    )
        .toList();
  }

  Future<FarmField?> getFarmFieldById(
      int id,
      ) async {
    final db = await database;

    final results = await db.query(
      'farm_fields',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return FarmField.fromMap(results.first);
  }

  Future<int> updateFarmField(
      FarmField field,
      ) async {
    if (field.id == null) {
      throw ArgumentError(
        'Farm field ID is required for an update.',
      );
    }

    final db = await database;

    final values = field.toMap();
    values.remove('id');

    return db.update(
      'farm_fields',
      values,
      where: 'id = ?',
      whereArgs: [field.id],
    );
  }

  Future<int> deleteFarmField(
      int id,
      ) async {
    final db = await database;

    return db.delete(
      'farm_fields',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllFarmFields() async {
    final db = await database;

    return db.delete(
      'farm_fields',
    );
  }

  Future<int> getFarmFieldCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM farm_fields',
    );

    final value = result.first['count'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  Future<double> getTotalFieldHectares() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT SUM(size_hectares) AS total
      FROM farm_fields
      ''',
    );

    final value = result.first['total'];

    if (value == null) {
      return 0;
    }

    return (value as num).toDouble();
  }

  Future<List<FarmField>> getFarmFieldsByCrop(
      String crop,
      ) async {
    final db = await database;

    final results = await db.query(
      'farm_fields',
      where: 'crop = ?',
      whereArgs: [crop],
      orderBy: 'planting_date DESC',
    );

    return results
        .map(
          (map) => FarmField.fromMap(map),
    )
        .toList();
  }

  Future<List<FarmField>> getFarmFieldsByStatus(
      String status,
      ) async {
    final db = await database;

    final results = await db.query(
      'farm_fields',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'planting_date DESC',
    );

    return results
        .map(
          (map) => FarmField.fromMap(map),
    )
        .toList();
  }

  // =========================================================
  // PEST & DISEASE RECORDS
  // =========================================================

  Future<int> addPestDiseaseRecord(
      PestDiseaseRecord record,
      ) async {
    final db = await database;

    return db.insert(
      'pest_disease_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<PestDiseaseRecord>>
  getPestDiseaseRecords() async {
    final db = await database;

    final results = await db.query(
      'pest_disease_records',
      orderBy: 'detection_date DESC, created_at DESC',
    );

    return results
        .map(
          (map) => PestDiseaseRecord.fromMap(map),
    )
        .toList();
  }

  Future<PestDiseaseRecord?> getPestDiseaseRecordById(
      int id,
      ) async {
    final db = await database;

    final results = await db.query(
      'pest_disease_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return PestDiseaseRecord.fromMap(
      results.first,
    );
  }

  Future<int> updatePestDiseaseRecord(
      PestDiseaseRecord record,
      ) async {
    if (record.id == null) {
      throw ArgumentError(
        'Pest or disease record ID is required for an update.',
      );
    }

    final db = await database;

    final values = record.toMap();
    values.remove('id');

    values['updated_at'] =
        DateTime.now().toIso8601String();

    return db.update(
      'pest_disease_records',
      values,
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deletePestDiseaseRecord(
      int id,
      ) async {
    final db = await database;

    return db.delete(
      'pest_disease_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllPestDiseaseRecords() async {
    final db = await database;

    return db.delete(
      'pest_disease_records',
    );
  }

  Future<List<PestDiseaseRecord>>
  getPestDiseaseRecordsByType(
      String recordType,
      ) async {
    final db = await database;

    final results = await db.query(
      'pest_disease_records',
      where: 'record_type = ?',
      whereArgs: [recordType],
      orderBy: 'detection_date DESC',
    );

    return results
        .map(
          (map) => PestDiseaseRecord.fromMap(map),
    )
        .toList();
  }

  Future<List<PestDiseaseRecord>>
  getPestDiseaseRecordsByStatus(
      String status,
      ) async {
    final db = await database;

    final results = await db.query(
      'pest_disease_records',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'detection_date DESC',
    );

    return results
        .map(
          (map) => PestDiseaseRecord.fromMap(map),
    )
        .toList();
  }

  Future<List<PestDiseaseRecord>>
  getPestDiseaseRecordsByCrop(
      String crop,
      ) async {
    final db = await database;

    final results = await db.query(
      'pest_disease_records',
      where: 'crop = ?',
      whereArgs: [crop],
      orderBy: 'detection_date DESC',
    );

    return results
        .map(
          (map) => PestDiseaseRecord.fromMap(map),
    )
        .toList();
  }

  Future<List<PestDiseaseRecord>>
  getPestDiseaseRecordsByField(
      String fieldName,
      ) async {
    final db = await database;

    final results = await db.query(
      'pest_disease_records',
      where: 'field_name = ?',
      whereArgs: [fieldName],
      orderBy: 'detection_date DESC',
    );

    return results
        .map(
          (map) => PestDiseaseRecord.fromMap(map),
    )
        .toList();
  }

  Future<int> getPestDiseaseRecordCount() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM pest_disease_records
      ''',
    );

    final value = result.first['count'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  Future<int> getActivePestDiseaseRecordCount() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM pest_disease_records
      WHERE status != ?
      ''',
      ['Resolved'],
    );

    final value = result.first['count'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  Future<int> getCriticalPestDiseaseRecordCount() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM pest_disease_records
      WHERE severity = ?
      AND status != ?
      ''',
      [
        'Critical',
        'Resolved',
      ],
    );

    final value = result.first['count'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  // =========================================================
  // DATABASE MANAGEMENT
  // =========================================================

  Future<void> closeDatabase() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
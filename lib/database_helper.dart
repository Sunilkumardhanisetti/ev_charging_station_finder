import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = "ev_stations.db";
  static const int _databaseVersion = 1;

  static const String tableStations = "stations";
  static const String columnId = "id";
  static const String columnName = "name";
  static const String columnLocation = "location";
  static const String columnStatus = "status";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStations (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnLocation TEXT NOT NULL,
        $columnStatus TEXT NOT NULL
      )
    ''');
  }

  // Insert station data with conflict resolution to prevent duplicates
  Future<int> insertStation(Map<String, dynamic> station) async {
    Database db = await database;
    return await db.insert(
      tableStations,
      station,
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Prevents duplicate entries
    );
  }

  // Get all charging stations from database
  Future<List<Map<String, dynamic>>> getStations() async {
    Database db = await database;
    return await db.query(tableStations);
  }

  // Clear all stored stations (used before inserting fresh data)
  Future<void> clearStations() async {
    Database db = await database;
    await db.delete(tableStations);
  }
}

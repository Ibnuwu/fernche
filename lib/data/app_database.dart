import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants.dart';

class AppDatabase {
  static Database? _database;
  static final AppDatabase instance = AppDatabase._();

  AppDatabase._();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTransactions} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        source TEXT DEFAULT 'manual',
        source_id INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableNotes} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        tag TEXT NOT NULL,
        expected_payout INTEGER DEFAULT 0,
        status TEXT DEFAULT 'OPEN',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableAppMeta} (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableBudgets} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL UNIQUE,
        limit_amount INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Indexes for performance
    await db.execute('''
      CREATE INDEX idx_transactions_type ON ${AppConstants.tableTransactions}(type)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_created ON ${AppConstants.tableTransactions}(created_at)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_created_category ON ${AppConstants.tableTransactions}(created_at, category)
    ''');
    await db.execute('''
      CREATE INDEX idx_notes_tag ON ${AppConstants.tableNotes}(tag)
    ''');
    await db.execute('''
      CREATE INDEX idx_notes_status ON ${AppConstants.tableNotes}(status)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_source ON ${AppConstants.tableTransactions}(source, source_id)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add composite index for monthly report queries
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_transactions_created_category 
        ON ${AppConstants.tableTransactions}(created_at, category)
      ''');

      // Create budgets table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.tableBudgets} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL UNIQUE,
          limit_amount INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }
  }

  /// Get the database file path for backup operations
  Future<String> get databasePath async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, AppConstants.dbName);
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // ----- App Meta helpers -----

  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert(
      AppConstants.tableAppMeta,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMeta(String key) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableAppMeta,
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }
}

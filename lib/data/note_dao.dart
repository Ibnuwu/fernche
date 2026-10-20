import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';
import '../models/note_model.dart';
import 'app_database.dart';

class NoteDao {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  /// Insert a new note
  Future<int> insert(NoteModel note) async {
    final db = await _db;
    return db.insert(AppConstants.tableNotes, note.toMap());
  }

  /// Update an existing note
  Future<int> update(NoteModel note) async {
    final db = await _db;
    return db.update(
      AppConstants.tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete a note by ID
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      AppConstants.tableNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all notes, newest first
  Future<List<NoteModel>> getAll() async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableNotes,
      orderBy: 'updated_at DESC',
    );
    return result.map((m) => NoteModel.fromMap(m)).toList();
  }

  /// Get notes filtered by tag
  Future<List<NoteModel>> getByTag(String tag) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableNotes,
      where: 'tag = ?',
      whereArgs: [tag],
      orderBy: 'updated_at DESC',
    );
    return result.map((m) => NoteModel.fromMap(m)).toList();
  }

  /// Search notes by title, content, or tag
  Future<List<NoteModel>> search(String query) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableNotes,
      where: 'title LIKE ? OR content LIKE ? OR tag LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return result.map((m) => NoteModel.fromMap(m)).toList();
  }

  /// Get a single note by ID
  Future<NoteModel?> getById(int id) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return NoteModel.fromMap(result.first);
  }

  /// Count projects by status
  Future<Map<String, int>> projectCountByStatus() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT status, COUNT(*) as count FROM ${AppConstants.tableNotes} WHERE tag = ? GROUP BY status',
      ['Project'],
    );

    final map = <String, int>{};
    for (final row in result) {
      map[row['status'] as String] = (row['count'] as int?) ?? 0;
    }
    return map;
  }

  /// Count done projects
  Future<int> doneProjectCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableNotes} WHERE tag = ? AND status = ?',
      ['Project', 'DONE'],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}

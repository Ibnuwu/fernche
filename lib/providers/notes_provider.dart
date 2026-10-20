import 'package:flutter/foundation.dart';
import '../core/date_utils.dart';
import '../data/note_dao.dart';
import '../data/transaction_dao.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  final NoteDao _noteDao = NoteDao();
  final TransactionDao _txnDao = TransactionDao();

  List<NoteModel> _notes = [];
  String? _selectedTag;
  String _searchQuery = '';
  bool _isLoading = false;

  List<NoteModel> get notes => _notes;
  String? get selectedTag => _selectedTag;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  NotesProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    if (_searchQuery.isNotEmpty) {
      _notes = await _noteDao.search(_searchQuery);
    } else if (_selectedTag != null) {
      _notes = await _noteDao.getByTag(_selectedTag!);
    } else {
      _notes = await _noteDao.getAll();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setTagFilter(String? tag) {
    _selectedTag = tag;
    _searchQuery = '';
    loadNotes();
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadNotes();
  }

  Future<void> addNote({
    required String title,
    String? content,
    required String tag,
    int expectedPayout = 0,
    String status = 'OPEN',
  }) async {
    final now = FerncheDateUtils.nowIso();
    final note = NoteModel(
      title: title,
      content: content,
      tag: tag,
      expectedPayout: expectedPayout,
      status: status,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _noteDao.insert(note);

    // Handle project payout automation
    if (tag == 'Project' && status == 'DONE' && expectedPayout > 0) {
      await _txnDao.createProjectPayout(
        noteId: id,
        amount: expectedPayout,
        projectTitle: title,
      );
    }

    await loadNotes();
  }

  Future<void> updateNote(NoteModel note) async {
    final updated = note.copyWith(updatedAt: FerncheDateUtils.nowIso());
    await _noteDao.update(updated);

    // Handle project payout automation when status changes to DONE
    if (updated.isProject && updated.isDone && updated.hasPayout) {
      await _txnDao.createProjectPayout(
        noteId: updated.id!,
        amount: updated.expectedPayout,
        projectTitle: updated.title,
      );
    }

    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _noteDao.delete(id);
    await loadNotes();
  }

  /// Check if a project note already has a payout transaction
  Future<bool> hasProjectPayout(int noteId) async {
    return _txnDao.hasProjectPayout(noteId);
  }
}

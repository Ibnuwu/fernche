import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/tag_chip.dart';

class RepositoryScreen extends StatefulWidget {
  const RepositoryScreen({super.key});

  @override
  State<RepositoryScreen> createState() => _RepositoryScreenState();
}

class _RepositoryScreenState extends State<RepositoryScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notes, _) {
        return Scaffold(
          backgroundColor: FerncheColors.matteBlack,
          appBar: AppBar(
            backgroundColor: FerncheColors.matteBlack,
            title: _showSearch
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: FerncheColors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari catatan...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: GoogleFonts.inter(
                        color: FerncheColors.textSecondary,
                      ),
                    ),
                    onChanged: notes.setSearch,
                  )
                : Text(
                    'Repository',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.close_rounded : Icons.search_rounded,
                ),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      notes.setSearch('');
                    }
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildTagFilter(notes),
              Expanded(
                child: notes.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: FerncheColors.terminalGreen,
                        ),
                      )
                    : notes.notes.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            color: FerncheColors.terminalGreen,
                            onRefresh: notes.loadNotes,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: notes.notes.length,
                              itemBuilder: (context, index) {
                                final note = notes.notes[index];
                                return FutureBuilder<bool>(
                                  future: note.isProject
                                      ? notes.hasProjectPayout(note.id!)
                                      : Future.value(false),
                                  builder: (context, snap) {
                                    return NoteCard(
                                      note: note,
                                      isPaid: snap.data ?? false,
                                      onTap: () => _showNoteForm(
                                        context,
                                        note: note,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showNoteForm(context),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildTagFilter(NotesProvider notes) {
    final tags = ['All', ...AppConstants.noteTags];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isAll = tag == 'All';
          return TagChip(
            label: tag,
            isSelected: isAll
                ? notes.selectedTag == null
                : notes.selectedTag == tag,
            onTap: () => notes.setTagFilter(isAll ? null : tag),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_add_rounded,
            size: 48,
            color: FerncheColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada catatan',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: FerncheColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteForm(BuildContext context, {NoteModel? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FerncheColors.softGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NoteFormSheet(note: note),
    );
  }
}

class _NoteFormSheet extends StatefulWidget {
  final NoteModel? note;

  const _NoteFormSheet({this.note});

  @override
  State<_NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends State<_NoteFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _payoutController;
  late String _tag;
  late String _status;
  bool get _isEditing => widget.note != null;
  bool get _isProject => _tag == 'Project';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _payoutController = TextEditingController(
      text: widget.note?.expectedPayout != null &&
              widget.note!.expectedPayout > 0
          ? FerncheFormatters.formatAmount(widget.note!.expectedPayout)
          : '',
    );
    _tag = widget.note?.tag ?? 'General';
    _status = widget.note?.status ?? 'OPEN';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _payoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FerncheColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Note' : 'Tambah Note',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: FerncheColors.white,
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: FerncheColors.dangerRed,
                    ),
                    onPressed: _delete,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FerncheColors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Content
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Konten'),
              maxLines: 4,
              style: _tag == 'Code Snippet'
                  ? GoogleFonts.firaCode(
                      fontSize: 13,
                      color: FerncheColors.white,
                    )
                  : GoogleFonts.inter(
                      fontSize: 14,
                      color: FerncheColors.white,
                    ),
            ),
            const SizedBox(height: 12),

            // Tag
            DropdownButtonFormField<String>(
              initialValue: _tag,
              dropdownColor: FerncheColors.surfaceLight,
              decoration: const InputDecoration(labelText: 'Tag'),
              items: AppConstants.noteTags
                  .map(
                    (t) => DropdownMenuItem(value: t, child: Text(t)),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _tag = val);
              },
            ),
            const SizedBox(height: 12),

            // Project fields
            if (_isProject) ...[
              TextField(
                controller: _payoutController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsFormatter(),
                ],
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: FerncheColors.terminalGreen,
                ),
                decoration: InputDecoration(
                  labelText: 'Expected Payout',
                  prefixText: 'Rp  ',
                  prefixStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: FerncheColors.terminalGreen.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _status,
                dropdownColor: FerncheColors.surfaceLight,
                decoration: const InputDecoration(labelText: 'Status'),
                items: AppConstants.noteStatuses
                    .map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),

            // Save button
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(_isEditing ? 'Update' : 'Simpan'),
              style: FilledButton.styleFrom(
                backgroundColor: FerncheColors.terminalGreen,
                foregroundColor: FerncheColors.matteBlack,
                minimumSize: const Size.fromHeight(50),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    final notes = context.read<NotesProvider>();
    final dashboard = context.read<DashboardProvider>();
    final payout = FerncheFormatters.parseAmount(_payoutController.text);

    if (_isEditing) {
      final updated = widget.note!.copyWith(
        title: title,
        content: _contentController.text.isEmpty
            ? null
            : _contentController.text,
        tag: _tag,
        expectedPayout: _isProject ? payout : 0,
        status: _isProject ? _status : 'OPEN',
      );
      await notes.updateNote(updated);
    } else {
      await notes.addNote(
        title: title,
        content: _contentController.text.isEmpty
            ? null
            : _contentController.text,
        tag: _tag,
        expectedPayout: _isProject ? payout : 0,
        status: _isProject ? _status : 'OPEN',
      );
    }

    await dashboard.refresh();
    if (!context.mounted) return;
    if (mounted) Navigator.pop(context);
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: FerncheColors.dangerRed,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (confirm == true) {
      final notes = context.read<NotesProvider>();
      await notes.deleteNote(widget.note!.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}

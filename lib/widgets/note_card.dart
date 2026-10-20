import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/formatters.dart';
import '../core/date_utils.dart';
import '../core/theme.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isPaid;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.note,
    this.isPaid = false,
    this.onTap,
  });

  Color get _tagColor {
    switch (note.tag) {
      case 'Project':
        return FerncheColors.terminalGreen;
      case 'Idea':
        return Colors.amberAccent;
      case 'Code Snippet':
        return Colors.cyanAccent;
      case 'Organization':
        return Colors.purpleAccent;
      default:
        return FerncheColors.textSecondary;
    }
  }

  IconData get _tagIcon {
    switch (note.tag) {
      case 'Project':
        return Icons.rocket_launch_rounded;
      case 'Idea':
        return Icons.lightbulb_rounded;
      case 'Code Snippet':
        return Icons.code_rounded;
      case 'Organization':
        return Icons.folder_rounded;
      default:
        return Icons.notes_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_tagIcon, size: 16, color: _tagColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: FerncheColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isProject) _buildStatusChip(),
                ],
              ),
              if (note.content != null && note.content!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.content!,
                  style: note.isCodeSnippet
                      ? GoogleFonts.firaCode(
                          fontSize: 12,
                          color: FerncheColors.textSecondary,
                          height: 1.4,
                        )
                      : GoogleFonts.inter(
                          fontSize: 13,
                          color: FerncheColors.textSecondary,
                          height: 1.3,
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _tagColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      note.tag,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _tagColor,
                      ),
                    ),
                  ),
                  if (note.isProject && note.hasPayout) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${FerncheFormatters.formatAmount(note.expectedPayout)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: FerncheColors.terminalGreen.withValues(alpha: 0.7),
                      ),
                    ),
                    if (isPaid) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: FerncheColors.terminalGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Paid',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: FerncheColors.terminalGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                  const Spacer(),
                  Text(
                    FerncheDateUtils.formatShort(note.updatedAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: FerncheColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    switch (note.status) {
      case 'DONE':
        statusColor = FerncheColors.terminalGreen;
        break;
      case 'PROGRESS':
        statusColor = Colors.amberAccent;
        break;
      case 'ARCHIVED':
        statusColor = FerncheColors.textSecondary;
        break;
      default:
        statusColor = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        note.status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: statusColor,
        ),
      ),
    );
  }
}

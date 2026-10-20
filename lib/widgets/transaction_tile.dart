import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/formatters.dart';
import '../core/date_utils.dart';
import '../core/theme.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;
  final bool budgetWarning;
  final bool budgetOver;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDismissed,
    this.onTap,
    this.budgetWarning = false,
    this.budgetOver = false,
  });

  IconData get _categoryIcon {
    switch (transaction.category) {
      case 'Transportasi':
        return Icons.directions_car_rounded;
      case 'Makan':
        return Icons.restaurant_rounded;
      case 'Main':
        return Icons.sports_esports_rounded;
      case 'Beli Barang':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Project':
        return Icons.code_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color =
        isIncome ? FerncheColors.terminalGreen : FerncheColors.dangerRed;

    final tile = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_categoryIcon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FerncheColors.white,
                        ),
                      ),
                      if (budgetWarning || budgetOver) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: budgetOver
                              ? FerncheColors.dangerRed
                              : const Color(0xFFFFA726),
                        ),
                      ],
                    ],
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Text(
                      transaction.note!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: FerncheColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: isIncome ? '+ ' : '- ',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      TextSpan(
                        text: 'Rp ',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: color.withValues(alpha: 0.7),
                        ),
                      ),
                      TextSpan(
                        text: FerncheFormatters.formatAmount(transaction.amount),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  FerncheDateUtils.formatShort(transaction.createdAt),
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
    );

    if (onDismissed == null) return tile;

    return Dismissible(
      key: Key('txn_${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: FerncheColors.dangerRed.withValues(alpha: 0.2),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: FerncheColors.dangerRed,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: tile,
    );
  }
}


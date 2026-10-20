import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import '../core/theme.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;

  const AmountInput({
    super.key,
    required this.controller,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsFormatter(),
      ],
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: FerncheColors.white,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        labelText: label ?? 'Nominal',
        prefixText: 'Rp  ',
        prefixStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: FerncheColors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

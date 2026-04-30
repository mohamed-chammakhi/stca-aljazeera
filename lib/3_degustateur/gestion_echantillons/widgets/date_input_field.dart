// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/date_input_field.dart
// PURPOSE : reusable date input — auto-format, clamping, calendar picker,
//           real-time preview
// USAGE   : DateInputField(controller: dateCtrl)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

class DateInputField extends StatefulWidget {
  final TextEditingController controller;

  const DateInputField({super.key, required this.controller});

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  // ── formats raw digits into DD/MM/YYYY with clamping ─────────────────────
  // called by BOTH onChanged (typing) and _pickDate (calendar)
  // so both paths go through the same validation ✅
  String _formatDate(String digits) {
    if (digits.length > 8) digits = digits.substring(0, 8);

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digits[i];
    }

    // clamp day 01–31
    if (digits.length >= 2) {
      final day = int.tryParse(digits.substring(0, 2)) ?? 1;
      final clampedDay = day.clamp(1, 31).toString().padLeft(2, '0');
      formatted = clampedDay + formatted.substring(2);
    }

    // clamp month 01–12
    if (digits.length >= 4) {
      final month = int.tryParse(digits.substring(2, 4)) ?? 1;
      final clampedMonth = month.clamp(1, 12).toString().padLeft(2, '0');
      formatted =
          formatted.substring(0, 3) + clampedMonth + formatted.substring(5);
    }

    // clamp year 2000–2126
    if (digits.length == 8) {
      final year = int.tryParse(digits.substring(4, 8)) ?? 2026;
      final clampedYear = year.clamp(2000, 2126).toString();
      formatted = formatted.substring(0, 6) + clampedYear;
    }

    return formatted;
  }

  // ── opens calendar in grid-only mode (no text input allowed) ─────────────
  // fills field through _formatDate so same clamping applies ✅
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2126),
      initialEntryMode: DatePickerEntryMode.calendarOnly, // ← no text input
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green,
            onPrimary: Colors.white,
            onSurface: _darkText,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      // build digit string → run through _formatDate → same clamping as typing
      final digits =
          picked.day.toString().padLeft(2, '0') +
          picked.month.toString().padLeft(2, '0') +
          picked.year.toString();
      final formatted = _formatDate(digits);
      setState(() {
        widget.controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.controller.text.length == 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── label ──────────────────────────────────────────────────────────
        const Text(
          "Date d'arrivée",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _oliveGreen,
          ),
        ),
        const SizedBox(height: 6),

        // ── input row : text field + calendar button ───────────────────────
        Row(
          children: [
            // ── text field ─────────────────────────────────────────────────
            Expanded(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.number,
                maxLength: 10, // DD/MM/YYYY = 10 chars
                style: const TextStyle(fontSize: 14, color: _darkText),
                decoration: InputDecoration(
                  counterText: '', // hides "0/10" counter
                  hintText: 'JJ/MM/AAAA',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7FAF8),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _green, width: 1.8),
                  ),
                ),
                onChanged: (value) {
                  final digits = value.replaceAll('/', '');
                  final formatted = _formatDate(digits);
                  if (formatted != value) {
                    widget.controller.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                  setState(() {}); // rebuilds preview in real time
                },
              ),
            ),

            // ── calendar button ────────────────────────────────────────────
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green.withValues(alpha:0.3)),
                ),
                child: const Icon(
                  Icons.edit_calendar_outlined,
                  color: _green,
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        // ── real-time preview — appears once date is complete (10 chars) ───
        if (isComplete)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: _green, size: 15),
                const SizedBox(width: 6),
                Text(
                  widget.controller.text,
                  style: const TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

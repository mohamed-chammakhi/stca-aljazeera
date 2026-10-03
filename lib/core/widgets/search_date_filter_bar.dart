import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _dark = Color(0xFF1A2E1F);

enum DateFilterType {
  enregistrement,
  livraisonEchantillon,
  receptionPhysique,
  arriveeStock,
}

extension DateFilterTypeX on DateFilterType {
  String get label {
    switch (this) {
      case DateFilterType.enregistrement:
        return 'Date d\'enregistrement';
      case DateFilterType.livraisonEchantillon:
        return 'Livraison échantillon';
      case DateFilterType.receptionPhysique:
        return 'Réception physique';
      case DateFilterType.arriveeStock:
        return 'Livraison du stock';
    }
  }

  String get shortLabel {
    switch (this) {
      case DateFilterType.enregistrement:
        return 'Enregistrement';
      case DateFilterType.livraisonEchantillon:
        return 'Livraison éch.';
      case DateFilterType.receptionPhysique:
        return 'Réception';
      case DateFilterType.arriveeStock:
        return 'Livraison stock';
    }
  }

  String get helpText {
    switch (this) {
      case DateFilterType.enregistrement:
        return 'Cherche les échantillons enregistrés à une date précise.';
      case DateFilterType.livraisonEchantillon:
        return 'Cherche les échantillons que vous prévoyez de livrer à une date précise.';
      case DateFilterType.receptionPhysique:
        return 'Cherche les échantillons réellement arrivés à l\'entreprise.';
      case DateFilterType.arriveeStock:
        return 'Cherche les dates auxquelles vous prévoyez de livrer le stock acheté.';
    }
  }
}

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _green,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _dark.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: (v) => onChanged(v.trim()),
          style: const TextStyle(fontSize: 13, color: _dark),
          decoration: InputDecoration(
            hintText: 'Rechercher réf, fournisseur, gouvernorat...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color.fromARGB(255, 150, 149, 149),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 17,
              color: Colors.grey.shade400,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close,
                      size: 17,
                      color: Colors.grey.shade400,
                    ),
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
          ),
        ),
      ),
    );
  }
}

class DateFilterButton extends StatelessWidget {
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final VoidCallback onTap;

  const DateFilterButton({
    super.key,
    required this.dateDebut,
    required this.dateFin,
    required this.onTap,
  });

  bool get _active => dateDebut != null;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: _active ? Colors.white : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _active ? Colors.white : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: _active ? _green : Colors.white,
            ),
            if (_active) ...[
              const SizedBox(width: 5),
              Text(
                dateFin != null
                    ? '${_fmt(dateDebut!)} → ${_fmt(dateFin!)}'
                    : _fmt(dateDebut!),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DateFilterSheet extends StatefulWidget {
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final void Function(DateTime debut, DateTime? fin) onApply;
  final VoidCallback onClear;
  final String titre;
  final List<DateFilterType> availableTypes;
  final DateFilterType? initialType;
  final void Function(DateTime debut, DateTime? fin, DateFilterType type)?
  onApplyTyped;

  const DateFilterSheet({
    super.key,
    required this.dateDebut,
    required this.dateFin,
    required this.onApply,
    required this.onClear,
    this.titre = 'Filtrer par date',
    this.availableTypes = const [],
    this.initialType,
    this.onApplyTyped,
  });

  @override
  State<DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<DateFilterSheet> {
  late DateTime? _debut;
  late DateTime? _fin;
  bool _isRange = false;
  late DateFilterType _selectedType;

  @override
  void initState() {
    super.initState();
    _debut = widget.dateDebut;
    _fin = widget.dateFin;
    _isRange = widget.dateFin != null;
    _selectedType =
        widget.initialType ??
        (widget.availableTypes.isNotEmpty
            ? widget.availableTypes.first
            : DateFilterType.enregistrement);
  }

  bool get _hasTypeSelector => widget.availableTypes.length > 1;

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  Future<void> _pickDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDebut ? _debut : _fin) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isDebut ? _debut = picked : _fin = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: _green,
              ),
              const SizedBox(width: 8),
              Text(
                widget.titre,
                style: GoogleFonts.domine(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_hasTypeSelector) ...[
            Text(
              'Filtrer sur quelle date :',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.availableTypes.map((type) {
                  final selected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? _green : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? _green : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        type.shortLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedType.helpText,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _ModeSegment(
                  label: 'Jour exact',
                  selected: !_isRange,
                  onTap: () => setState(() {
                    _isRange = false;
                    _fin = null;
                  }),
                ),
                _ModeSegment(
                  label: 'Période',
                  selected: _isRange,
                  onTap: () => setState(() => _isRange = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _pickDate(true),
            child: _DatePickerField(
              label: _isRange ? 'Du' : 'Date',
              value: _debut != null ? _fmtDate(_debut!) : null,
            ),
          ),
          if (_isRange) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickDate(false),
              child: _DatePickerField(
                label: 'Au',
                value: _fin != null ? _fmtDate(_fin!) : null,
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Only way to drop an active date filter: shown only when one is set.
          if (widget.dateDebut != null) ...
            [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: const Text('Toutes les dates'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _debut == null
                  ? null
                  : () {
                      if (widget.onApplyTyped != null) {
                        widget.onApplyTyped!(
                          _debut!,
                          _isRange ? _fin : null,
                          _selectedType,
                        );
                      } else {
                        widget.onApply(_debut!, _isRange ? _fin : null);
                      }
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Appliquer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _dark.withValues(alpha: 0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? _dark : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    ),
  );
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;

  const _DatePickerField({required this.label, this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: value != null ? _green : Colors.grey.shade200,
        width: value != null ? 1.5 : 1,
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: value != null ? _green : Colors.grey.shade400,
        ),
        const SizedBox(width: 10),
        Text(
          '$label : ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        Text(
          value ?? 'Choisir une date',
          style: TextStyle(
            fontSize: 13,
            fontWeight: value != null ? FontWeight.w700 : FontWeight.w400,
            color: value != null ? _dark : Colors.grey.shade400,
          ),
        ),
      ],
    ),
  );
}

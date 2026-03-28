import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/campaign_calendar.dart';
import 'package:spacegom_companion/widgets/month_grid.dart';

class CalendarScreen extends StatefulWidget {
  final CampaignCalendar calendar;
  final ValueChanged<CampaignCalendar> onChanged;

  const CalendarScreen({
    super.key,
    required this.calendar,
    required this.onChanged,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _currentYear;
  late Map<int, Set<(int, int)>> _markedDays;
  late Map<int, List<SpecialDate>> _specialDates;

  @override
  void initState() {
    super.initState();

    _currentYear = widget.calendar.currentYear;
    _markedDays = widget.calendar.markedDays.map(
      (k, v) => MapEntry(k, Set.from(v)),
    );
    _specialDates = widget.calendar.specialDates.map(
      (k, v) => MapEntry(k, List.from(v)),
    );
  }

  CampaignCalendar _buildCalendar() {
    return CampaignCalendar(
      currentYear: _currentYear,
      markedDays: _markedDays.map((k, v) => MapEntry(k, Set.from(v))),
      specialDates: _specialDates.map((k, v) => MapEntry(k, List.from(v))),
    );
  }

  void _notifyChanged() => widget.onChanged(_buildCalendar());

  (int, int) get _currentDate => _buildCalendar().currentDate;

  List<SpecialDate> get _yearEvents => _specialDates[_currentYear] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Campaña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearSelector(),

            const SizedBox(height: 8),

            _buildLegend(),

            const SizedBox(height: 12),

            for (var month = 1; month <= 12; month++) ...[
              MonthGrid(
                month: month,
                markedDays: _markedDaysForMonth(month),
                eventLetters: _eventLettersForMonth(month),
                currentDate: _currentDate,
                onDayTap: _onDayTap,
              ),

              const SizedBox(height: 16),
            ],

            _buildSpecialDatesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentYear > 1
              ? () => setState(() { _currentYear--; _notifyChanged(); })
              : null,
          icon: const Icon(Icons.chevron_left),
        ),

        Text(
          'Año $_currentYear',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        IconButton(
          onPressed: () => setState(() { _currentYear++; _notifyChanged(); }),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final date = _currentDate;

    return Text(
      'Día actual: ${date.$2}/${date.$1}',
      style: const TextStyle(fontSize: 12, color: Color(0xFF58A6FF), fontWeight: FontWeight.bold),
    );
  }

  Set<int> _markedDaysForMonth(int month) {
    final yearMarks = _markedDays[_currentYear] ?? {};

    return yearMarks
        .where((d) => d.$1 == month)
        .map((d) => d.$2)
        .toSet();
  }

  Map<int, List<String>> _eventLettersForMonth(int month) {
    final result = <int, List<String>>{};

    for (final event in _yearEvents) {
      if (event.month == month) {
        result.putIfAbsent(event.day, () => []).add(event.letter);
      }
    }

    return result;
  }


  Set<(int, int)> _allDaysOfYear() {
    final all = <(int, int)>{};

    for (var m = 1; m <= 12; m++) {
      for (var d = 1; d <= 35; d++) {
        all.add((m, d));
      }
    }

    return all;
  }

  void _onDayTap(int month, int day) {
    setState(() {
      _markedDays.putIfAbsent(_currentYear, () => {});
      final marks = _markedDays[_currentYear]!;
      final tapped = (month, day);

      if (marks.contains(tapped)) {
        marks.removeWhere((d) =>
            d.$1 > month || (d.$1 == month && d.$2 >= day));

        _markedDays.keys
            .where((y) => y > _currentYear)
            .toList()
            .forEach((y) => _markedDays.remove(y));
      } else {
        for (var y = 1; y < _currentYear; y++) {
          _markedDays[y] = _allDaysOfYear();
        }

        for (var m = 1; m <= month; m++) {
          final maxDay = m < month ? 35 : day;
          for (var d = 1; d <= maxDay; d++) {
            marks.add((m, d));
          }
        }
      }

      _notifyChanged();
    });
  }

  Widget _buildSpecialDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FECHAS SEÑALADAS (Año $_currentYear)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            IconButton(
              onPressed: _addSpecialDate,
              icon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ],
        ),

        if (_yearEvents.isEmpty)
          const Text(
            'Sin fechas señaladas',
            style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
          ),

        for (var i = 0; i < _yearEvents.length; i++)
          _buildSpecialDateRow(i, _yearEvents[i]),
      ],
    );
  }

  Widget _buildSpecialDateRow(int index, SpecialDate date) {
    return GestureDetector(
      onLongPress: () => _deleteSpecialDate(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFE8B830).withValues(alpha: 0.2),
                border: Border.all(color: const Color(0xFFE8B830)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  date.letter,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE8B830)),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '${date.day}/${date.month}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                date.description,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSpecialDate() {
    final letterController = TextEditingController();
    final monthController = TextEditingController();
    final dayController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva fecha señalada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: letterController,
              decoration: const InputDecoration(labelText: 'Letra'),
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: monthController,
                    decoration: const InputDecoration(labelText: 'Mes'),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: dayController,
                    decoration: const InputDecoration(labelText: 'Día'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Qué sucede'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final letter = letterController.text.trim();
              final month = int.tryParse(monthController.text);
              final day = int.tryParse(dayController.text);

              if (letter.isNotEmpty && month != null && day != null) {
                setState(() {
                  _specialDates.putIfAbsent(_currentYear, () => []);
                  _specialDates[_currentYear]!.add(SpecialDate(
                    letter: letter,
                    month: month,
                    day: day,
                    description: descriptionController.text.trim(),
                  ));
                  _notifyChanged();
                });
              }

              Navigator.pop(ctx);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _deleteSpecialDate(int index) {
    final date = _yearEvents[index];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar fecha señalada'),
        content: Text('¿Eliminar "${date.letter}" (${date.day}/${date.month})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _specialDates[_currentYear]?.removeAt(index);
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }
}

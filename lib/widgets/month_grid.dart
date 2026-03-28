import 'package:flutter/material.dart';

class MonthGrid extends StatelessWidget {
  final int month;
  final Set<int> markedDays;
  final Map<int, List<String>> eventLetters;
  final (int, int)? currentDate;
  final void Function(int month, int day) onDayTap;

  static const _currentDayColor = Color(0xFF58A6FF);
  static const _markedColor = Color(0xFF0D2818);

  const MonthGrid({
    super.key,
    required this.month,
    required this.markedDays,
    required this.eventLetters,
    required this.currentDate,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes $month',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: 35,
          itemBuilder: (_, i) => _buildDayCell(i + 1),
        ),
      ],
    );
  }

  Widget _buildDayCell(int day) {
    final isCurrent = currentDate != null && currentDate!.$1 == month && currentDate!.$2 == day;
    final isMarked = markedDays.contains(day);
    final letters = eventLetters[day];

    Color bgColor;
    if (isCurrent) {
      bgColor = _currentDayColor;
    } else if (isMarked) {
      bgColor = _markedColor;
    } else {
      bgColor = const Color(0xFF161B22);
    }

    return GestureDetector(
      onTap: () => onDayTap(month, day),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: isCurrent
              ? Border.all(color: _currentDayColor, width: 2)
              : isMarked
                  ? Border.all(color: const Color(0xFF2EA043).withValues(alpha: 0.4))
                  : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent
                    ? Colors.white
                    : isMarked
                        ? const Color(0xFF2EA043).withValues(alpha: 0.6)
                        : const Color(0xFF8B949E),
                decoration: isMarked && !isCurrent ? TextDecoration.lineThrough : null,
              ),
            ),

            if (letters != null && letters.isNotEmpty)
              Positioned(
                top: 1,
                right: 2,
                child: Text(
                  letters.join(''),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8B830),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

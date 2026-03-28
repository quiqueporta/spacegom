import 'package:flutter/material.dart';

class LevelSelector extends StatelessWidget {
  final String label;
  final List<int> values;
  final int selectedValue;
  final ValueChanged<int> onChanged;
  final Color Function(int value)? colorResolver;

  const LevelSelector({
    super.key,
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onChanged,
    this.colorResolver,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),

        Row(
          children: values.map((v) => Expanded(child: _buildCell(v))).toList(),
        ),
      ],
    );
  }

  Widget _buildCell(int value) {
    final isSelected = value == selectedValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor(value) : Colors.transparent,
          border: Border.all(
            color: isSelected ? _selectedColor(value) : const Color(0xFF30363D),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF8B949E),
          ),
        ),
      ),
    );
  }

  Color _selectedColor(int value) {
    if (colorResolver != null) return colorResolver!(value);

    if (value < 0) return const Color(0xFFDA3633);
    if (value == 0) return const Color(0xFF484F58);

    return const Color(0xFF2EA043);
  }

  static Color damageColor(int value) {
    if (value == 0) return const Color(0xFF484F58);

    return Color.lerp(
      const Color(0xFFE8B830),
      const Color(0xFFDA3633),
      (value - 1) / 4,
    )!;
  }
}

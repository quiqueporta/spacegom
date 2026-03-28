import 'dart:math' as math;

import 'package:flutter/material.dart';

class DigitCounter extends StatelessWidget {
  final String label;
  final int value;
  final int digitCount;
  final ValueChanged<int> onChanged;

  const DigitCounter({
    super.key,
    required this.label,
    required this.value,
    required this.digitCount,
    required this.onChanged,
  });

  int get _maxValue => math.pow(10, digitCount).toInt() - 1;

  List<int> get _digits {
    final digits = <int>[];
    var remaining = value;

    for (var i = digitCount - 1; i >= 0; i--) {
      final divisor = math.pow(10, i).toInt();
      digits.add(remaining ~/ divisor);
      remaining = remaining % divisor;
    }

    return digits;
  }

  void _incrementDigit(int position) {
    final multiplier = math.pow(10, digitCount - 1 - position).toInt();
    final newValue = value + multiplier;

    if (newValue <= _maxValue) {
      onChanged(newValue);
    }
  }

  void _decrementDigit(int position) {
    final multiplier = math.pow(10, digitCount - 1 - position).toInt();
    final newValue = value - multiplier;

    if (newValue >= 0) {
      onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = _digits;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(digitCount, (i) => Flexible(child: _buildDigitColumn(digits[i], i))),
        ),
      ],
    );
  }

  Widget _buildDigitColumn(int digit, int position) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(Icons.add, () => _incrementDigit(position), Colors.teal),

          const SizedBox(height: 2),

          Text(
            '$digit',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 2),

          _buildButton(Icons.remove, () => _decrementDigit(position), Colors.red),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.3),
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

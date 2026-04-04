import 'dart:math';

import 'package:flutter/material.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> with AutomaticKeepAliveClientMixin {
  final _random = Random();
  int _diceCount = 2;
  List<int> _results = [];

  int get _total => _results.fold(0, (a, b) => a + b);

  void _roll() {
    setState(() {
      _results = List.generate(_diceCount, (_) => _random.nextInt(6) + 1);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDiceCountSelector(),

            const SizedBox(height: 32),

            _buildRollButton(),

            const SizedBox(height: 32),

            if (_results.isNotEmpty) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceCountSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 3; i++) ...[
          if (i > 1) const SizedBox(width: 12),
          _buildDiceOption(i),
        ],
      ],
    );
  }

  Widget _buildDiceOption(int count) {
    final isSelected = _diceCount == count;

    return GestureDetector(
      onTap: () => setState(() {
        _diceCount = count;
        _results = [];
      }),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF58A6FF).withValues(alpha: 0.25) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino,
              color: isSelected ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
              size: 20,
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRollButton() {
    return SizedBox(
      width: 160,
      height: 48,
      child: ElevatedButton(
        onPressed: _roll,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF58A6FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('TIRAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _results.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              _buildDieResult(_results[i]),
            ],
          ],
        ),

        if (_results.length > 1) ...[
          const SizedBox(height: 16),

          Text(
            'Total: $_total',
            style: const TextStyle(fontSize: 20, color: Color(0xFF8B949E)),
          ),
        ],
      ],
    );
  }

  Widget _buildDieResult(int value) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF58A6FF), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

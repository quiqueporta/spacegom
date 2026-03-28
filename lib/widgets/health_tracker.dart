import 'package:flutter/material.dart';

class HealthTracker extends StatelessWidget {
  static const maxMarks = 140;
  static const rowsPerLevel = 20;

  static const _levels = [
    'EXCELENTE',
    'BUENA',
    'ACEPTABLE',
    'DEFICIENTE',
    'PRECARIA',
    'SERIO RIESGO',
    'CRÍTICA',
  ];

  static const _levelColors = [
    Color(0xFF2EA043),
    Color(0xFF3FB950),
    Color(0xFFE8B830),
    Color(0xFFD29922),
    Color(0xFFDB6D28),
    Color(0xFFDA3633),
    Color(0xFF8B1A1A),
  ];

  static const Map<int, String> _effects = {
    // BUENA (20-39): filas 5, 15
    24: '↓ Moral todos',
    34: '↓ Moral todos',
    // ACEPTABLE (40-59): filas 7, 13, 19
    46: '↓ Moral todos',
    52: '↓ Moral todos',
    58: '↓ Moral todos',
    // DEFICIENTE (60-79): filas 3, 7, 13, 19
    62: '☠ 1 fallece',
    66: '↓ Moral todos',
    72: '↓ Moral todos',
    78: '↓ Moral todos',
    // PRECARIA (80-99): filas 3, 7, 13, 19
    82: '☠ 1 fallece',
    86: '↓ Moral todos',
    92: '☠ 1 fallece',
    98: '↓ Moral todos',
    // SERIO RIESGO (100-119): filas 3, 7, 13, 19
    102: '☠ 1 fallece',
    106: '↓ Moral todos',
    112: '☠ 2 fallecen',
    118: '↓ Moral todos',
    // CRÍTICA (120-139): filas 3, 7, 13, 19, 20
    122: '☠ 2 fallecen',
    126: '↓ Moral todos',
    132: '☠ 2 fallecen',
    138: '↓ Moral todos',
    139: 'FIN PARTIDA',
  };

  final int marks;
  final ValueChanged<int> onChanged;

  const HealthTracker({
    super.key,
    required this.marks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = (marks / rowsPerLevel).floor().clamp(0, 6);
    final levelColor = _levelColors[currentLevel];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'NIVEL DE SALUBRIDAD',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: levelColor),
              ),
              child: Text(
                _levels[currentLevel],
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: levelColor),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                onPressed: marks > 0 ? () {
                  showDialog(
                    context: ctx,
                    builder: (dlg) => AlertDialog(
                      title: const Text('Sanar por completo'),
                      content: const Text('¿Restablecer la salubridad a EXCELENTE?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dlg),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            onChanged(0);
                            Navigator.pop(dlg);
                          },
                          child: const Text('Sanar'),
                        ),
                      ],
                    ),
                  );
                } : null,
                icon: const Icon(Icons.favorite, size: 20, color: Color(0xFF2EA043)),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                padding: EdgeInsets.zero,
                tooltip: 'Sanar',
              ),
            ),

            IconButton(
              onPressed: marks > 0 ? () => onChanged(marks - 1) : null,
              icon: const Icon(Icons.remove_circle_outline, size: 24),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),

            Expanded(child: _buildGrid()),

            IconButton(
              onPressed: marks < maxMarks ? () => onChanged(marks + 1) : null,
              icon: const Icon(Icons.add_circle_outline, size: 24),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ],
        ),

        const SizedBox(height: 4),

        _buildTriggeredEffects(),
      ],
    );
  }

  Widget _buildGrid() {
    return Row(
      children: [
        for (var level = 0; level < 7; level++)
          Expanded(child: _buildLevelColumn(level)),
      ],
    );
  }

  Widget _buildLevelColumn(int level) {
    final startMark = level * rowsPerLevel;

    return Column(
      children: [
        Text(
          '${level + 1}',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: _levelColors[level],
          ),
        ),

        for (var row = 0; row < rowsPerLevel; row++)
          _buildCell(startMark + row, level),
      ],
    );
  }

  Widget _buildCell(int index, int level) {
    final isMarked = index < marks;
    final hasEffect = _effects.containsKey(index);
    final color = _levelColors[level];

    return Container(
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 0.25),
      decoration: BoxDecoration(
        color: isMarked ? color : hasEffect ? const Color(0xFF21262D) : const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(
          color: isMarked ? color : hasEffect ? const Color(0xFF484F58) : const Color(0xFF30363D),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildTriggeredEffects() {
    final triggered = _effects.entries
        .where((e) => e.key < marks)
        .toList();

    if (triggered.isEmpty) return const SizedBox.shrink();

    final moralCount = triggered.where((e) => e.value.contains('Moral')).length;
    final deaths1 = triggered.where((e) => e.value == '☠ 1 fallece').length;
    final deaths2 = triggered.where((e) => e.value == '☠ 2 fallecen').length;
    final totalDeaths = deaths1 + (deaths2 * 2);
    final gameOver = triggered.any((e) => e.value == 'FIN PARTIDA');

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (moralCount > 0)
          _effectChip('↓ Moral ×$moralCount', const Color(0xFFE8B830)),

        if (totalDeaths > 0)
          _effectChip('☠ $totalDeaths fallecidos', const Color(0xFFDA3633)),

        if (gameOver)
          _effectChip('FIN DE LA PARTIDA', const Color(0xFF8B1A1A)),
      ],
    );
  }

  Widget _effectChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

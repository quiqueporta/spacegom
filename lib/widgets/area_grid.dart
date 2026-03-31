import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/cell_data.dart';

class AreaGrid extends StatelessWidget {
  final Map<(int, int), CellData> cells;
  final void Function(int row, int col) onCellTap;
  final void Function(int row, int col)? onCellLongPress;
  final (int, int)? shipPosition;

  static const _columns = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const _borderColor = Color(0xFF30363D);
  static const _cellColor = Color(0xFF0D1B2A);

  static const _starColor = Color(0xFF8B949E);

  const AreaGrid({
    super.key,
    required this.cells,
    required this.onCellTap,
    this.onCellLongPress,
    this.shipPosition,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headerSize = 24.0;
        final available = constraints.maxWidth - headerSize;
        final cellSize = available > 0 ? available / 6 : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColumnHeaders(cellSize, headerSize),

            for (var row = 1; row <= 6; row++)
              _buildRow(row, cellSize, headerSize),
          ],
        );
      },
    );
  }

  Widget _buildColumnHeaders(double cellSize, double headerSize) {
    return Row(
      children: [
        SizedBox(width: headerSize),

        for (final col in _columns)
          SizedBox(
            width: cellSize,
            height: headerSize,
            child: Center(
              child: Text(
                col,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B949E),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(int row, double cellSize, double headerSize) {
    return Row(
      children: [
        SizedBox(
          width: headerSize,
          height: cellSize,
          child: Center(
            child: Text(
              '$row',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B949E),
              ),
            ),
          ),
        ),

        for (var col = 1; col <= 6; col++)
          _buildCell(row, col, cellSize),
      ],
    );
  }

  Widget _buildCell(int row, int col, double size) {
    final cellData = cells[(row, col)];
    final isShipHere = shipPosition == (row, col);

    return GestureDetector(
      onTap: () => onCellTap(row, col),
      onLongPress: onCellLongPress != null ? () => onCellLongPress!(row, col) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _cellColor,
          border: Border.all(color: _borderColor, width: 0.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isShipHere)
              Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDA3633), width: 2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

            if (cellData != null && cellData.isDeepSpace)
              ..._buildStarField(row, col, size),

            if (cellData != null && !cellData.isDeepSpace) ...[
              Container(
                width: size * 0.65,
                height: size * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isShipHere
                        ? const Color(0xFFE6EDF3).withValues(alpha: 0.4)
                        : const Color(0xFF58A6FF).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
              ),

              Text(
                '${cellData.sectionNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isShipHere
                      ? const Color(0xFFE6EDF3)
                      : const Color(0xFF58A6FF),
                ),
              ),
            ],

            if (cellData != null && cellData.pirates)
              Positioned(
                top: 1,
                right: 1,
                child: Text('☠', style: TextStyle(fontSize: 8)),
              ),

            if (cellData != null && cellData.megacorporation.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 1,
                child: Text(
                  cellData.megacorporation.length > 3
                      ? cellData.megacorporation.substring(0, 3)
                      : cellData.megacorporation,
                  style: const TextStyle(fontSize: 6, color: Color(0xFFBC8CFF)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStarField(int row, int col, double size) {
    final seed = row * 7 + col * 13;
    const stars = ['✦', '·', '∗', '·', '✦'];
    const positions = [
      (0.2, 0.3),
      (0.7, 0.15),
      (0.45, 0.55),
      (0.15, 0.75),
      (0.75, 0.7),
    ];
    final count = 3 + (seed % 3);

    return [
      for (var i = 0; i < count; i++)
        Positioned(
          left: positions[(i + seed) % positions.length].$1 * size,
          top: positions[(i + seed) % positions.length].$2 * size,
          child: Text(
            stars[(i + seed) % stars.length],
            style: TextStyle(
              fontSize: 6.0 + (((i + seed) * 3) % 5),
              color: _starColor,
            ),
          ),
        ),
    ];
  }
}

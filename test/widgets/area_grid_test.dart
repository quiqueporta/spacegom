import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/cell_data.dart';
import 'package:spacegom_companion/widgets/area_grid.dart';

Widget buildTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('AreaGrid', () {
    testWidgets('muestra las cabeceras de columna A-F', (tester) async {
      await tester.pumpWidget(buildTestable(
        AreaGrid(cells: {}, onCellTap: (_, __) {}),
      ));

      for (final col in ['A', 'B', 'C', 'D', 'E', 'F']) {
        expect(find.text(col), findsOneWidget);
      }
    });

    testWidgets('muestra las cabeceras de fila 1-6', (tester) async {
      await tester.pumpWidget(buildTestable(
        AreaGrid(cells: {}, onCellTap: (_, __) {}),
      ));

      for (var row = 1; row <= 6; row++) {
        expect(find.text('$row'), findsOneWidget);
      }
    });

    testWidgets('muestra el número de sección en una celda ocupada', (tester) async {
      await tester.pumpWidget(buildTestable(
        AreaGrid(
          cells: {(2, 3): CellData(sectionNumber: 256)},
          onCellTap: (_, __) {},
        ),
      ));

      expect(find.text('256'), findsOneWidget);
    });

    testWidgets('llama onCellTap al pulsar una celda', (tester) async {
      int? tappedRow;
      int? tappedCol;

      await tester.pumpWidget(buildTestable(
        AreaGrid(
          cells: {},
          onCellTap: (row, col) {
            tappedRow = row;
            tappedCol = col;
          },
        ),
      ));

      final gridCells = find.byType(GestureDetector);
      await tester.tap(gridCells.first);

      expect(tappedRow, isNotNull);
      expect(tappedCol, isNotNull);
    });

    testWidgets('llama onCellLongPress al mantener pulsada una celda', (tester) async {
      int? longPressedRow;
      int? longPressedCol;

      await tester.pumpWidget(buildTestable(
        AreaGrid(
          cells: {(1, 1): CellData(sectionNumber: 111)},
          onCellTap: (_, __) {},
          onCellLongPress: (row, col) {
            longPressedRow = row;
            longPressedCol = col;
          },
        ),
      ));

      final gridCells = find.descendant(
        of: find.byType(AreaGrid),
        matching: find.byType(GestureDetector),
      );
      await tester.longPress(gridCells.first);

      expect(longPressedRow, 1);
      expect(longPressedCol, 1);
    });
  });
}

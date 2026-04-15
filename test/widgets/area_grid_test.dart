import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/cell_data.dart';
import 'package:spacegom_companion/widgets/area_grid.dart';

Widget buildTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

Border? _findCellBorder(WidgetTester tester, String sectionNumber) {
  final textFinder = find.text(sectionNumber);
  final containerAncestor = find.ancestor(
    of: textFinder,
    matching: find.byType(Container),
  );

  for (final element in containerAncestor.evaluate()) {
    final widget = element.widget as Container;
    final decoration = widget.decoration;

    if (decoration is BoxDecoration && decoration.border is Border) {
      return decoration.border as Border;
    }
  }

  return null;
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

    testWidgets('todas las celdas tienen el mismo borde', (tester) async {
      await tester.pumpWidget(buildTestable(
        AreaGrid(
          cells: {
            (1, 1): CellData(sectionNumber: 111),
            (1, 2): CellData(sectionNumber: 222),
          },
          onCellTap: (_, __) {},
        ),
      ));

      final border111 = _findCellBorder(tester, '111');
      final border222 = _findCellBorder(tester, '222');

      expect(border111!.top.width, 0.5);
      expect(border222!.top.width, 0.5);
      expect(border111.top.color, border222.top.color);
    });

    testWidgets('muestra número de megacorporación en la celda', (tester) async {
      await tester.pumpWidget(buildTestable(
        AreaGrid(
          cells: {(1, 1): CellData(sectionNumber: 111, megacorporation: 'Orion Holdings')},
          onCellTap: (_, __) {},
          megacorpNumbers: {'Orion Holdings': 1},
        ),
      ));

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('dos celdas con misma megacorporación muestran el mismo número', (tester) async {
      await tester.pumpWidget(buildTestable(
        AreaGrid(
          cells: {
            (1, 1): CellData(sectionNumber: 111, megacorporation: 'Orion Holdings'),
            (2, 2): CellData(sectionNumber: 256, megacorporation: 'Orion Holdings'),
          },
          onCellTap: (_, __) {},
          megacorpNumbers: {'Orion Holdings': 1},
        ),
      ));

      final megacorpLabels = find.text('1');
      expect(megacorpLabels, findsAtLeast(2));
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

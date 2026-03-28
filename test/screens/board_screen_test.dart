import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/board_state.dart';
import 'package:spacegom_companion/models/cell_data.dart';
import 'package:spacegom_companion/screens/board_screen.dart';
import 'package:spacegom_companion/widgets/area_grid.dart';

Widget buildTestable({BoardState? initialState}) {
  return MaterialApp(
    home: Scaffold(
      body: BoardScreen(
        initialState: initialState ?? const BoardState(),
        onChanged: (_) {},
      ),
    ),
  );
}

void main() {
  group('BoardScreen', () {
    testWidgets('muestra el selector de área', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('ÁREA'), findsOneWidget);
    });

    testWidgets('muestra el campo de fecha', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('FECHA'), findsOneWidget);
      expect(find.text('01/01/01'), findsOneWidget);
    });

    testWidgets('muestra las 4 flechas de navegación', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.byIcon(Icons.arrow_left), findsOneWidget);
      expect(find.byIcon(Icons.arrow_right), findsOneWidget);
    });

    testWidgets('muestra los indicadores de tipo seleccionables', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('MUNDO'), findsOneWidget);
      expect(find.text('ESPACIO.'), findsOneWidget);
      expect(find.text('ORBITAL'), findsOneWidget);
      expect(find.text('HIPERDISP.'), findsOneWidget);
    });

    testWidgets('cambiar área con botón > incrementa el número', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.widgetWithText(IconButton, '>'));
      await tester.pump();

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('al pulsar celda vacía aparece diálogo de tipo de cuadrante', (tester) async {
      await tester.pumpWidget(buildTestable());

      final gridCells = find.descendant(
        of: find.byType(AreaGrid),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gridCells.first);
      await tester.pumpAndSettle();

      expect(find.text('Planeta (sección)'), findsOneWidget);
      expect(find.text('Espacio profundo'), findsOneWidget);
    });

    testWidgets('tap en fecha llama a onOpenCalendar', (tester) async {
      var calendarOpened = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BoardScreen(
            initialState: const BoardState(),
            onChanged: (_) {},
            currentMonth: 3,
            currentDay: 15,
            onOpenCalendar: () => calendarOpened = true,
          ),
        ),
      ));

      await tester.tap(find.text('15/03/01'));
      await tester.pump();

      expect(calendarOpened, true);
    });

    testWidgets('muestra los días hasta hiperdisparo', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.textContaining('↔'), findsOneWidget);
    });

    testWidgets('muestra fecha del calendario', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BoardScreen(
            initialState: const BoardState(),
            onChanged: (_) {},
            currentDay: 15,
            currentMonth: 6,
            currentYear: 3,
          ),
        ),
      ));

      expect(find.text('15/06/03'), findsOneWidget);
    });

    testWidgets('notifica cambios al callback', (tester) async {
      BoardState? lastState;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BoardScreen(
            initialState: const BoardState(),
            onChanged: (state) => lastState = state,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pump();

      expect(lastState, isNotNull);
      expect(lastState!.shipCol, 2);
    });

    testWidgets('long-press en celda con sección muestra opciones editar/borrar', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaCells: {1: {(1, 1): CellData(sectionNumber: 256)}},
        ),
      ));

      final gridCells = find.descendant(
        of: find.byType(AreaGrid),
        matching: find.byType(GestureDetector),
      );
      await tester.longPress(gridCells.first);
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Borrar'), findsOneWidget);
    });

    testWidgets('borrar celda elimina la sección', (tester) async {
      BoardState? lastState;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BoardScreen(
            initialState: BoardState(
              areaCells: {1: {(1, 1): CellData(sectionNumber: 256)}},
            ),
            onChanged: (state) => lastState = state,
          ),
        ),
      ));

      final gridCells = find.descendant(
        of: find.byType(AreaGrid),
        matching: find.byType(GestureDetector),
      );
      await tester.longPress(gridCells.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();

      expect(lastState, isNotNull);
      expect(lastState!.areaCells[1]?[(1, 1)], isNull);
    });

    testWidgets('muestra la densidad del área en la cabecera', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaDensity: {1: AreaDensity.high},
        ),
      ));

      expect(find.text('Alta'), findsOneWidget);
    });
  });
}

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

      expect(find.text('Mundo'), findsOneWidget);
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

    testWidgets('diálogo de sección muestra botón de dado aleatorio', (tester) async {
      await tester.pumpWidget(buildTestable());

      final gridCells = find.descendant(
        of: find.byType(AreaGrid),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gridCells.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mundo'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.casino), findsOneWidget);
    });

    testWidgets('botón de dado rellena el campo con un código válido', (tester) async {
      await tester.pumpWidget(buildTestable());

      final gridCells = find.descendant(
        of: find.byType(AreaGrid),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gridCells.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mundo'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.casino));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final text = textField.controller!.text;
      final code = int.parse(text);
      final digits = text.split('').map(int.parse).toList();

      expect(digits.length, 3);
      for (final digit in digits) {
        expect(digit, greaterThanOrEqualTo(1));
        expect(digit, lessThanOrEqualTo(6));
      }
      expect(code, greaterThanOrEqualTo(111));
      expect(code, lessThanOrEqualTo(666));
    });

    testWidgets('muestra la densidad del área en la cabecera', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaDensity: {1: AreaDensity.high},
        ),
      ));

      expect(find.text('Alta'), findsOneWidget);
    });

    testWidgets('muestra sección UBICACIÓN DE LA NAVE', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('UBICACIÓN DE LA NAVE'), findsOneWidget);
    });

    testWidgets('muestra info del planeta donde está la nave', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          shipRow: 1,
          shipCol: 1,
          areaCells: {
            1: {(1, 1): CellData(sectionNumber: 111)},
          },
        ),
      ));

      expect(find.text('Chipethea (111)'), findsWidgets);
    });

    testWidgets('muestra megacorporación del planeta donde está la nave', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          shipRow: 1,
          shipCol: 1,
          areaCells: {
            1: {(1, 1): CellData(sectionNumber: 111, megacorporation: 'Orion Holdings')},
          },
        ),
      ));

      expect(find.textContaining('Orion Holdings'), findsWidgets);
    });

    testWidgets('muestra indicador de piratas del planeta donde está la nave', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          shipRow: 1,
          shipCol: 1,
          areaCells: {
            1: {(1, 1): CellData(sectionNumber: 111, pirates: true)},
          },
        ),
      ));

      expect(find.textContaining('Piratas'), findsOneWidget);
    });

    testWidgets('no muestra info si la nave está en celda vacía', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.textContaining('(111)'), findsNothing);
    });

    testWidgets('muestra Espacio profundo si la nave está en espacio profundo', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          shipRow: 1,
          shipCol: 1,
          areaCells: {
            1: {(1, 1): CellData.deepSpace()},
          },
        ),
      ));

      expect(find.text('Espacio profundo'), findsOneWidget);
    });

    testWidgets('muestra megacorporación y piratas en espacio profundo', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          shipRow: 1,
          shipCol: 1,
          areaCells: {
            1: {(1, 1): CellData.deepSpace(megacorporation: 'Orion Holdings', pirates: true)},
          },
        ),
      ));

      expect(find.text('Espacio profundo'), findsOneWidget);
      expect(find.textContaining('Orion Holdings'), findsWidgets);
      expect(find.textContaining('Piratas'), findsOneWidget);
    });

    testWidgets('muestra productos con rentabilidad del planeta actual', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          shipRow: 1,
          shipCol: 1,
          areaCells: {
            1: {(1, 1): CellData(sectionNumber: 111)},
          },
        ),
      ));

      expect(find.text('Producto'), findsWidgets);
      expect(find.text('Rent.%'), findsWidgets);
      expect(find.text('INDU'), findsWidgets);
    });

    testWidgets('muestra listado de planetas del área con productos', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          shipRow: 1,
          shipCol: 1,
          areaCells: {
            1: {
              (1, 1): CellData(sectionNumber: 111),
              (2, 2): CellData(sectionNumber: 256),
              (3, 3): CellData.deepSpace(),
            },
          },
        ),
      ));

      await tester.ensureVisible(find.text('PLANETAS DEL ÁREA'));

      expect(find.text('PLANETAS DEL ÁREA'), findsOneWidget);
      expect(find.textContaining('Chipethea'), findsWidgets);
      expect(find.textContaining('Pucolla'), findsWidgets);
    });

    testWidgets('no muestra listado de planetas si el área está vacía', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('PLANETAS DEL ÁREA'), findsNothing);
    });

    testWidgets('planetas del área muestra los del área visualizada, no la de la nave', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaCells: {
            1: {
              (2, 2): CellData(sectionNumber: 111),
            },
            2: {
              (1, 1): CellData(sectionNumber: 256),
            },
          },
        ),
      ));

      await tester.tap(find.widgetWithText(IconButton, '>'));
      await tester.pump();

      expect(find.textContaining('Pucolla'), findsWidgets);
      expect(find.textContaining('Chipethea'), findsNothing);
    });

    testWidgets('muestra listado de megacorporaciones del área visualizada', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaCells: {
            1: {
              (1, 1): CellData(sectionNumber: 111, megacorporation: 'Orion Holdings'),
              (2, 2): CellData(sectionNumber: 256, megacorporation: 'Stellar Systems'),
            },
          },
        ),
      ));

      await tester.ensureVisible(find.text('MEGACORPORACIONES'));

      expect(find.text('MEGACORPORACIONES'), findsOneWidget);
      expect(find.textContaining('Orion Holdings'), findsWidgets);
      expect(find.textContaining('Stellar Systems'), findsWidgets);
    });

    testWidgets('listado de megacorporaciones usa el área visualizada, no la de la nave', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaCells: {
            1: {
              (2, 2): CellData(sectionNumber: 111, megacorporation: 'Orion Holdings'),
            },
            2: {
              (1, 1): CellData(sectionNumber: 256, megacorporation: 'Stellar Systems'),
            },
          },
        ),
      ));

      await tester.tap(find.widgetWithText(IconButton, '>'));
      await tester.pump();

      expect(find.textContaining('Stellar Systems'), findsOneWidget);
      expect(find.textContaining('Orion Holdings'), findsNothing);
    });

    testWidgets('numeración de megacorporaciones es global entre áreas', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaCells: {
            1: {
              (1, 1): CellData(sectionNumber: 111, megacorporation: 'Orion Holdings'),
            },
            2: {
              (1, 1): CellData(sectionNumber: 256, megacorporation: 'Stellar Systems'),
            },
          },
        ),
      ));

      await tester.tap(find.widgetWithText(IconButton, '>'));
      await tester.pump();

      expect(find.textContaining('2. Stellar Systems'), findsOneWidget);
    });

    testWidgets('megacorporaciones se numeran por orden de aparición', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialState: BoardState(
          areaCells: {
            1: {
              (1, 1): CellData(sectionNumber: 111, megacorporation: 'Orion Holdings'),
              (2, 2): CellData(sectionNumber: 256, megacorporation: 'Stellar Systems'),
              (3, 3): CellData(sectionNumber: 333, megacorporation: 'Orion Holdings'),
            },
          },
        ),
      ));

      expect(find.textContaining('1. Orion Holdings'), findsOneWidget);
      expect(find.textContaining('2. Stellar Systems'), findsOneWidget);
    });

    testWidgets('diálogo de edición muestra dado de megacorporación', (tester) async {
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

      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('Megacorporación'), findsOneWidget);
      expect(find.byIcon(Icons.casino_outlined), findsOneWidget);
    });

    testWidgets('dado de megacorporación rellena el campo con un nombre', (tester) async {
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

      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.casino_outlined));
      await tester.pump();

      final megacorpField = find.widgetWithText(TextField, 'Megacorporación');
      final textField = tester.widget<TextField>(megacorpField);
      expect(textField.controller!.text, isNotEmpty);
    });
  });
}

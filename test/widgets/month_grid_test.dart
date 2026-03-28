import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/widgets/month_grid.dart';

Widget buildTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('MonthGrid', () {
    testWidgets('muestra el título del mes', (tester) async {
      await tester.pumpWidget(buildTestable(
        MonthGrid(
          month: 3,
          markedDays: {},
          eventLetters: {},
          currentDate: null,
          onDayTap: (_, __) {},
        ),
      ));

      expect(find.text('Mes 3'), findsOneWidget);
    });

    testWidgets('muestra 35 días', (tester) async {
      await tester.pumpWidget(buildTestable(
        MonthGrid(
          month: 1,
          markedDays: {},
          eventLetters: {},
          currentDate: null,
          onDayTap: (_, __) {},
        ),
      ));

      expect(find.text('35'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('muestra letras de eventos en un día', (tester) async {
      await tester.pumpWidget(buildTestable(
        MonthGrid(
          month: 1,
          markedDays: {},
          eventLetters: {5: ['A']},
          currentDate: null,
          onDayTap: (_, __) {},
        ),
      ));

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('resalta el día actual', (tester) async {
      await tester.pumpWidget(buildTestable(
        MonthGrid(
          month: 1,
          markedDays: {},
          eventLetters: {},
          currentDate: (1, 10),
          onDayTap: (_, __) {},
        ),
      ));

      expect(find.text('10'), findsOneWidget);
    });
  });
}

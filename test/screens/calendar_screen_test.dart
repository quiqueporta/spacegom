import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/campaign_calendar.dart';
import 'package:spacegom_companion/screens/calendar_screen.dart';

void main() {
  group('CalendarScreen', () {
    testWidgets('muestra los 12 meses', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CalendarScreen(
          calendar: const CampaignCalendar(),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Mes 1'), findsOneWidget);
      expect(find.text('Mes 2'), findsOneWidget);
    });

    testWidgets('muestra la sección de fechas señaladas', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CalendarScreen(
          calendar: const CampaignCalendar(),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('FECHAS SEÑALADAS'), findsOneWidget);
    });

    testWidgets('muestra fechas señaladas existentes', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CalendarScreen(
          calendar: CampaignCalendar(
            specialDates: {
              1: [SpecialDate(letter: 'A', month: 1, day: 5, description: 'Misión')],
            },
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Misión'), findsOneWidget);
    });

    testWidgets('muestra selector de año', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CalendarScreen(
          calendar: const CampaignCalendar(currentYear: 3),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Año 3'), findsOneWidget);
    });

    testWidgets('hace scroll automático al mes del día actual', (tester) async {
      final marks = <(int, int)>{};
      for (var m = 1; m < 8; m++) {
        for (var d = 1; d <= 35; d++) {
          marks.add((m, d));
        }
      }

      await tester.pumpWidget(MaterialApp(
        home: CalendarScreen(
          calendar: CampaignCalendar(markedDays: {1: marks}),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();

      final viewportHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final monthTop = tester.getTopLeft(find.text('Mes 8')).dy;

      expect(monthTop, lessThan(viewportHeight));
      expect(monthTop, greaterThanOrEqualTo(0));
    });

    testWidgets('no hace scroll si el día actual está en el mes 1', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CalendarScreen(
          calendar: const CampaignCalendar(),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Mes 1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Mes 1')).dy, greaterThanOrEqualTo(0));
    });
  });
}

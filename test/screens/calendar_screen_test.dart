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
  });
}

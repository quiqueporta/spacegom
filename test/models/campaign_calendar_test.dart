import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/campaign_calendar.dart';

void main() {
  group('SpecialDate', () {
    test('toJson y fromJson round-trip', () {
      final date = SpecialDate(
        letter: 'A',
        month: 3,
        day: 15,
        description: 'Llega cargamento',
      );

      final json = date.toJson();
      final restored = SpecialDate.fromJson(json);

      expect(restored.letter, 'A');
      expect(restored.month, 3);
      expect(restored.day, 15);
      expect(restored.description, 'Llega cargamento');
    });
  });

  group('CampaignCalendar', () {
    test('toJson y fromJson producen el mismo calendario', () {
      final calendar = CampaignCalendar(
        currentYear: 2,
        markedDays: {1: {(1, 1), (1, 2), (1, 3)}},
        specialDates: {
          1: [
            SpecialDate(letter: 'A', month: 2, day: 10, description: 'Evento A'),
          ],
          2: [
            SpecialDate(letter: 'B', month: 5, day: 35, description: 'Evento B'),
          ],
        },
        adminDone: {1: {(1, 7), (1, 14)}, 2: {(3, 35)}},
      );

      final json = calendar.toJson();
      final restored = CampaignCalendar.fromJson(json);

      expect(restored.currentYear, 2);
      expect(restored.markedDays[1]?.contains((1, 1)), true);
      expect(restored.markedDays[1]?.contains((1, 3)), true);
      expect(restored.specialDates[1]?.length, 1);
      expect(restored.specialDates[1]?[0].letter, 'A');
      expect(restored.specialDates[2]?[0].letter, 'B');
      expect(restored.adminDone[1]?.contains((1, 7)), true);
      expect(restored.adminDone[2]?.contains((3, 35)), true);
    });

    test('valores por defecto', () {
      final calendar = CampaignCalendar();

      expect(calendar.currentYear, 1);
      expect(calendar.markedDays, isEmpty);
      expect(calendar.specialDates, isEmpty);
      expect(calendar.adminDone, isEmpty);
    });

    test('currentDate devuelve el primer día no marcado del año', () {
      final calendar = CampaignCalendar(
        currentYear: 1,
        markedDays: {1: {(1, 1), (1, 2), (1, 3)}},
      );

      expect(calendar.currentDate, (1, 4));
    });

    test('currentDate avanza al siguiente mes', () {
      final marks = <(int, int)>{};
      for (var d = 1; d <= 35; d++) {
        marks.add((1, d));
      }

      final calendar = CampaignCalendar(
        currentYear: 1,
        markedDays: {1: marks},
      );

      expect(calendar.currentDate, (2, 1));
    });

    test('currentDate devuelve (1, 1) sin marcas', () {
      final calendar = CampaignCalendar(currentYear: 1);

      expect(calendar.currentDate, (1, 1));
    });

    test('eventsForDay devuelve eventos del día en el año actual', () {
      final calendar = CampaignCalendar(
        currentYear: 1,
        specialDates: {
          1: [
            SpecialDate(letter: 'A', month: 3, day: 15, description: 'Evento A'),
            SpecialDate(letter: 'B', month: 3, day: 15, description: 'Evento B'),
            SpecialDate(letter: 'C', month: 4, day: 1, description: 'Evento C'),
          ],
        },
      );

      final events = calendar.eventsForDay(3, 15);

      expect(events.length, 2);
      expect(events[0].letter, 'A');
      expect(events[1].letter, 'B');
    });

    test('eventsForDay devuelve vacío si no hay eventos', () {
      final calendar = CampaignCalendar(currentYear: 1);

      expect(calendar.eventsForDay(1, 1), isEmpty);
    });

    test('isWeeklyAdmin identifica días 7 14 21 28', () {
      expect(CampaignCalendar.isWeeklyAdmin(7), true);
      expect(CampaignCalendar.isWeeklyAdmin(14), true);
      expect(CampaignCalendar.isWeeklyAdmin(21), true);
      expect(CampaignCalendar.isWeeklyAdmin(28), true);
      expect(CampaignCalendar.isWeeklyAdmin(35), false);
      expect(CampaignCalendar.isWeeklyAdmin(10), false);
    });

    test('isMonthlyAdmin identifica día 35', () {
      expect(CampaignCalendar.isMonthlyAdmin(35), true);
      expect(CampaignCalendar.isMonthlyAdmin(28), false);
    });

    test('copyWith cambia solo los campos indicados', () {
      final original = CampaignCalendar(currentYear: 1);

      final modified = original.copyWith(currentYear: 3);

      expect(modified.currentYear, 3);
    });
  });
}

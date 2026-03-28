import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/widgets/health_tracker.dart';

void main() {
  group('HealthTracker', () {
    testWidgets('muestra el título y nivel actual', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HealthTracker(marks: 0, onChanged: (_) {}),
        ),
      ));

      expect(find.text('NIVEL DE SALUBRIDAD'), findsOneWidget);
      expect(find.text('EXCELENTE'), findsOneWidget);
    });

    testWidgets('muestra nivel correcto según marcas', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HealthTracker(marks: 40, onChanged: (_) {}),
        ),
      ));

      expect(find.text('ACEPTABLE'), findsOneWidget);
    });

    testWidgets('muestra botones +/-', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HealthTracker(marks: 5, onChanged: (_) {}),
        ),
      ));

      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('notifica cambio al pulsar +', (tester) async {
      int? newMarks;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HealthTracker(marks: 5, onChanged: (v) => newMarks = v),
        ),
      ));

      await tester.tap(find.byIcon(Icons.add_circle_outline));

      expect(newMarks, 6);
    });
  });
}

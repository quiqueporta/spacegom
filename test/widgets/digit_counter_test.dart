import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/widgets/digit_counter.dart';

Widget buildTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('DigitCounter', () {
    testWidgets('muestra el valor inicial con los dígitos separados', (tester) async {
      await tester.pumpWidget(buildTestable(
        DigitCounter(label: 'COMBUSTIBLE', value: 20, digitCount: 2, onChanged: (_) {}),
      ));

      expect(find.text('COMBUSTIBLE'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('incrementa el dígito correcto al pulsar +', (tester) async {
      int result = 0;
      await tester.pumpWidget(buildTestable(
        DigitCounter(label: 'TEST', value: 15, digitCount: 2, onChanged: (v) => result = v),
      ));

      final plusButtons = find.byIcon(Icons.add);
      await tester.tap(plusButtons.first);

      expect(result, 25);
    });

    testWidgets('decrementa el dígito correcto al pulsar -', (tester) async {
      int result = 0;
      await tester.pumpWidget(buildTestable(
        DigitCounter(label: 'TEST', value: 25, digitCount: 2, onChanged: (v) => result = v),
      ));

      final minusButtons = find.byIcon(Icons.remove);
      await tester.tap(minusButtons.first);

      expect(result, 15);
    });

    testWidgets('no baja de 0', (tester) async {
      int result = -1;
      await tester.pumpWidget(buildTestable(
        DigitCounter(label: 'TEST', value: 0, digitCount: 2, onChanged: (v) => result = v),
      ));

      final minusButtons = find.byIcon(Icons.remove);
      await tester.tap(minusButtons.first);

      expect(result, -1);
    });

    testWidgets('no supera el máximo según dígitos (99 para 2 dígitos)', (tester) async {
      int result = -1;
      await tester.pumpWidget(buildTestable(
        DigitCounter(label: 'TEST', value: 99, digitCount: 2, onChanged: (v) => result = v),
      ));

      final plusButtons = find.byIcon(Icons.add);
      await tester.tap(plusButtons.last);

      expect(result, -1);
    });

    testWidgets('funciona con 3 dígitos', (tester) async {
      await tester.pumpWidget(buildTestable(
        DigitCounter(label: 'ALMACÉN', value: 42, digitCount: 3, onChanged: (_) {}),
      ));

      expect(find.text('ALMACÉN'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('funciona con 4 dígitos', (tester) async {
      await tester.pumpWidget(buildTestable(
        DigitCounter(label: 'TESORERÍA', value: 500, digitCount: 4, onChanged: (_) {}),
      ));

      expect(find.text('TESORERÍA'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.text('5'), findsOneWidget);
    });
  });
}

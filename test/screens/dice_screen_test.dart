import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/screens/dice_screen.dart';

Widget buildTestable() {
  return const MaterialApp(
    home: Scaffold(body: DiceScreen()),
  );
}

void main() {
  group('DiceScreen', () {
    testWidgets('muestra selector de cantidad de dados', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('muestra botón de tirar', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('TIRAR'), findsOneWidget);
    });

    testWidgets('al tirar muestra resultados individuales', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.text('TIRAR'));
      await tester.pump();

      expect(find.byIcon(Icons.casino), findsWidgets);
    });
  });
}

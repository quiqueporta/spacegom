import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/widgets/level_selector.dart';

Widget buildTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('LevelSelector', () {
    testWidgets('muestra el label y todos los niveles', (tester) async {
      await tester.pumpWidget(buildTestable(
        LevelSelector(
          label: 'REPUTACIÓN',
          values: List.generate(11, (i) => i - 5),
          selectedValue: 0,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('REPUTACIÓN'), findsOneWidget);
      expect(find.text('-5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('resalta el valor seleccionado', (tester) async {
      await tester.pumpWidget(buildTestable(
        LevelSelector(
          label: 'DAÑOS LEVES',
          values: List.generate(6, (i) => i),
          selectedValue: 3,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('DAÑOS LEVES'), findsOneWidget);

      final selectedContainer = find.ancestor(
        of: find.text('3'),
        matching: find.byType(Container),
      );
      expect(selectedContainer, findsWidgets);
    });

    testWidgets('llama onChanged al pulsar un valor', (tester) async {
      int result = -1;
      await tester.pumpWidget(buildTestable(
        LevelSelector(
          label: 'TEST',
          values: List.generate(6, (i) => i),
          selectedValue: 0,
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.text('4'));

      expect(result, 4);
    });
  });
}

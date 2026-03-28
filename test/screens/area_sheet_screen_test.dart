import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/area_sheet.dart';
import 'package:spacegom_companion/screens/area_sheet_screen.dart';

void main() {
  group('AreaSheetScreen', () {
    testWidgets('muestra el título con el número de área', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 3,
          sheet: const AreaSheet(),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Área 3'), findsOneWidget);
    });

    testWidgets('muestra secciones de misiones y comercio', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: const AreaSheet(),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('MISIONES'), findsOneWidget);
      expect(find.textContaining('COMERCIO'), findsOneWidget);
    });

    testWidgets('muestra misiones existentes', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            missions: [
              SpecialMission(code: 'M-23', acceptanceWorld: '256'),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('M-23'), findsOneWidget);
    });

    testWidgets('muestra operaciones comerciales existentes', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            trades: [
              TradeRecord(purchaseWorld: '333', productCode: 'MIRA', purchaseAmount: 130),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('MIRA'), findsWidgets);
    });

    testWidgets('muestra tabla de productos de referencia', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: const AreaSheet(),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('PRODUCTOS'), findsOneWidget);
      expect(find.text('INDU'), findsOneWidget);
      expect(find.text('COM'), findsOneWidget);
    });
  });
}

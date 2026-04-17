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

    testWidgets('muestra contador de misiones con límite 6', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            missions: [
              SpecialMission(code: 'M-01'),
              SpecialMission(code: 'M-02'),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('MISIONES ESPECIALES (2/6)'), findsOneWidget);
    });

    testWidgets('deshabilita botón de añadir misión al llegar al límite', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            missions: List.generate(6, (i) => SpecialMission(code: 'M-0$i')),
          ),
          onChanged: (_) {},
        ),
      ));

      final addButton = tester.widget<IconButton>(find.byIcon(Icons.add).first.evaluate().first.widget is IconButton
          ? find.byIcon(Icons.add).first
          : find.ancestor(of: find.byIcon(Icons.add).first, matching: find.byType(IconButton)).first);

      expect(addButton.onPressed, isNull);
    });

    testWidgets('botón de añadir misión habilitado por debajo del límite', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            missions: List.generate(5, (i) => SpecialMission(code: 'M-0$i')),
          ),
          onChanged: (_) {},
        ),
      ));

      final addButton = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.add).first, matching: find.byType(IconButton)).first,
      );

      expect(addButton.onPressed, isNotNull);
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

    testWidgets('muestra nombre del producto en la tarjeta de operación', (tester) async {
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

      expect(find.text('MIRA — Minerales raros'), findsOneWidget);
    });

    testWidgets('muestra unidades compradas en la tarjeta de operación', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            trades: [
              TradeRecord(purchaseWorld: '333', productCode: 'MIRA', purchaseUnits: 10, purchaseAmount: 130),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('10 uds'), findsOneWidget);
    });

    testWidgets('muestra icono verificado cuando tiene trazabilidad', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            trades: [
              TradeRecord(productCode: 'MIRA', traceability: true),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('muestra icono X cuando no tiene trazabilidad', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            trades: [
              TradeRecord(productCode: 'MIRA', traceability: false),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('muestra operación inutilizada con texto tachado', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            trades: [
              TradeRecord(productCode: 'MIRA', purchaseAmount: 130, voided: true),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('INUTILIZADA'), findsOneWidget);

      final productText = tester.widget<Text>(find.text('MIRA — Minerales raros').first);
      expect(productText.style!.decoration, TextDecoration.lineThrough);
    });

    testWidgets('formulario de edición muestra toggle de inutilizada', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: AreaSheet(
            trades: [
              TradeRecord(productCode: 'MIRA', purchaseAmount: 130),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      await tester.tap(find.text('MIRA — Minerales raros').first);
      await tester.pumpAndSettle();

      expect(find.text('Inutilizada'), findsOneWidget);
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

    testWidgets('nueva operación muestra iconos de relleno rápido', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: const AreaSheet(),
          onChanged: (_) {},
          currentWorld: '256',
          currentDate: '15/03/01',
        ),
      ));

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.my_location), findsWidgets);
      expect(find.byIcon(Icons.today), findsWidgets);
    });

    testWidgets('icono de mundo rellena el campo con el mundo actual', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: const AreaSheet(),
          onChanged: (_) {},
          currentWorld: '256',
          currentDate: '15/03/01',
        ),
      ));

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.my_location).first);
      await tester.pump();

      expect(find.text('256'), findsOneWidget);
    });

    testWidgets('icono de fecha rellena el campo con la fecha actual', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AreaSheetScreen(
          area: 1,
          sheet: const AreaSheet(),
          onChanged: (_) {},
          currentWorld: '256',
          currentDate: '15/03/01',
        ),
      ));

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.today).first);
      await tester.pump();

      expect(find.text('15/03/01'), findsOneWidget);
    });
  });
}

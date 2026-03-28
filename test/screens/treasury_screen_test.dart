import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/treasury.dart';
import 'package:spacegom_companion/screens/treasury_screen.dart';

void main() {
  group('TreasuryScreen', () {
    testWidgets('muestra el saldo', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TreasuryScreen(
          treasury: Treasury(
            transactions: [Transaction(concept: 'Ingreso', amount: 100)],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('muestra las transacciones', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TreasuryScreen(
          treasury: Treasury(
            transactions: [
              Transaction(concept: 'Venta minerales', amount: 50),
            ],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Venta minerales'), findsOneWidget);
    });

    testWidgets('muestra sección de préstamos', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TreasuryScreen(
          treasury: const Treasury(),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('PRÉSTAMOS'), findsOneWidget);
    });

    testWidgets('muestra préstamos existentes', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TreasuryScreen(
          treasury: Treasury(
            loans: [Loan(id: 1, amount: 200)],
          ),
          onChanged: (_) {},
        ),
      ));

      expect(find.textContaining('200'), findsWidgets);
    });

    testWidgets('muestra botón añadir transacción', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TreasuryScreen(
          treasury: const Treasury(),
          onChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });
}

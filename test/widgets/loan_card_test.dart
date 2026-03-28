import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/treasury.dart';
import 'package:spacegom_companion/widgets/loan_card.dart';

void main() {
  group('LoanCard', () {
    testWidgets('muestra los datos del préstamo', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoanCard(
              loan: Loan(
                id: 1,
                amount: 100,
                totalRepayment: 120,
                grantDate: '01/03',
                monthlyPayment: 6,
                paidInstallments: 5,
              ),
              onChanged: (_) {},
            ),
          ),
        ),
      ));

      expect(find.textContaining('100'), findsWidgets);
      expect(find.textContaining('120'), findsWidgets);
    });

    testWidgets('muestra 20 casillas de cuotas', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoanCard(
              loan: Loan(id: 1, paidInstallments: 3),
              onChanged: (_) {},
            ),
          ),
        ),
      ));

      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}

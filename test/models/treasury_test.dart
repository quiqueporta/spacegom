import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/treasury.dart';

void main() {
  group('Transaction', () {
    test('toJson y fromJson round-trip', () {
      final tx = Transaction(concept: 'Venta mineral', amount: 30);

      final json = tx.toJson();
      final restored = Transaction.fromJson(json);

      expect(restored.concept, 'Venta mineral');
      expect(restored.amount, 30);
    });
  });

  group('Loan', () {
    test('toJson y fromJson round-trip', () {
      final loan = Loan(
        id: 1,
        amount: 100,
        totalRepayment: 120,
        grantDate: '01/03',
        endDate: '01/05',
        monthlyPayment: 6,
        paidInstallments: 5,
      );

      final json = loan.toJson();
      final restored = Loan.fromJson(json);

      expect(restored.id, 1);
      expect(restored.amount, 100);
      expect(restored.totalRepayment, 120);
      expect(restored.grantDate, '01/03');
      expect(restored.endDate, '01/05');
      expect(restored.monthlyPayment, 6);
      expect(restored.paidInstallments, 5);
    });

    test('valores por defecto', () {
      final loan = Loan(id: 1);

      expect(loan.amount, 0);
      expect(loan.paidInstallments, 0);
    });

    test('paidInstallments no supera 20', () {
      final loan = Loan(id: 1, paidInstallments: 20);
      final clamped = loan.copyWith(paidInstallments: 21);

      expect(clamped.paidInstallments, 20);
    });
  });

  group('Treasury', () {
    test('toJson y fromJson producen la misma tesorería', () {
      final treasury = Treasury(
        transactions: [
          Transaction(concept: 'Ingreso', amount: 50),
          Transaction(concept: 'Gasto', amount: -20),
        ],
        loans: [
          Loan(id: 1, amount: 100, paidInstallments: 3),
        ],
      );

      final json = treasury.toJson();
      final restored = Treasury.fromJson(json);

      expect(restored.transactions.length, 2);
      expect(restored.transactions[0].concept, 'Ingreso');
      expect(restored.transactions[1].amount, -20);
      expect(restored.loans.length, 1);
      expect(restored.loans[0].paidInstallments, 3);
    });

    test('valores por defecto', () {
      final treasury = Treasury();

      expect(treasury.transactions, isEmpty);
      expect(treasury.loans, isEmpty);
    });

    test('balance es la suma de importes', () {
      final treasury = Treasury(
        transactions: [
          Transaction(concept: 'A', amount: 100),
          Transaction(concept: 'B', amount: -30),
          Transaction(concept: 'C', amount: 50),
        ],
      );

      expect(treasury.balance, 120);
    });

    test('máximo 10 préstamos', () {
      expect(Loan.maxLoans, 10);
      expect(Loan.maxInstallments, 20);
    });
  });
}

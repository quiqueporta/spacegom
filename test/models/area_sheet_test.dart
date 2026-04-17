import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/area_sheet.dart';

void main() {
  group('SpecialMission', () {
    test('toJson y fromJson round-trip', () {
      final mission = SpecialMission(
        code: 'M-23 p.45',
        acceptanceWorld: '256',
        executionLocations: 'Strikupra, Zolani',
        deadline: '15/03/01',
        result: MissionResult.success,
      );

      final json = mission.toJson();
      final restored = SpecialMission.fromJson(json);

      expect(restored.code, 'M-23 p.45');
      expect(restored.acceptanceWorld, '256');
      expect(restored.executionLocations, 'Strikupra, Zolani');
      expect(restored.deadline, '15/03/01');
      expect(restored.result, MissionResult.success);
    });
  });

  group('TradeRecord', () {
    test('toJson y fromJson round-trip', () {
      final trade = TradeRecord(
        purchaseWorld: '333',
        productCode: 'MIRA',
        purchaseUnits: 10,
        purchaseAmount: 130,
        purchaseDate: '10/02/01',
        saleWorld: '445',
        saleAmount: 300,
        saleDate: '20/03/01',
        traceability: true,
      );

      final json = trade.toJson();
      final restored = TradeRecord.fromJson(json);

      expect(restored.purchaseWorld, '333');
      expect(restored.productCode, 'MIRA');
      expect(restored.purchaseUnits, 10);
      expect(restored.purchaseAmount, 130);
      expect(restored.saleWorld, '445');
      expect(restored.saleAmount, 300);
      expect(restored.traceability, true);
    });

    test('purchaseUnits tiene valor por defecto 0', () {
      final trade = TradeRecord(productCode: 'ALIM');

      expect(trade.purchaseUnits, 0);
    });

    test('voided tiene valor por defecto false', () {
      final trade = TradeRecord(productCode: 'ALIM');

      expect(trade.voided, false);
    });

    test('toJson y fromJson preservan voided', () {
      final trade = TradeRecord(productCode: 'MIRA', voided: true);

      final json = trade.toJson();
      final restored = TradeRecord.fromJson(json);

      expect(restored.voided, true);
    });

    test('profit se calcula automáticamente', () {
      final trade = TradeRecord(
        purchaseWorld: '111',
        productCode: 'ALIM',
        purchaseAmount: 40,
        saleAmount: 110,
      );

      expect(trade.profit, 70);
    });
  });

  group('AreaSheet', () {
    test('toJson y fromJson producen la misma hoja', () {
      final sheet = AreaSheet(
        missions: [
          SpecialMission(code: 'M-1', acceptanceWorld: '111'),
        ],
        trades: [
          TradeRecord(purchaseWorld: '222', productCode: 'INDU', purchaseAmount: 9),
        ],
      );

      final json = sheet.toJson();
      final restored = AreaSheet.fromJson(json);

      expect(restored.missions.length, 1);
      expect(restored.missions[0].code, 'M-1');
      expect(restored.trades.length, 1);
      expect(restored.trades[0].productCode, 'INDU');
    });

    test('valores por defecto', () {
      final sheet = AreaSheet();

      expect(sheet.missions, isEmpty);
      expect(sheet.trades, isEmpty);
    });
  });

  group('ProductReference', () {
    test('tiene 13 productos', () {
      expect(ProductReference.products.length, 13);
    });

    test('MIRA tiene precio compra 13 y venta 30', () {
      final mira = ProductReference.products.firstWhere((p) => p.code == 'MIRA');

      expect(mira.purchasePrice, 13);
      expect(mira.salePrice, 30);
      expect(mira.productionDays, 50);
      expect(mira.demandDays, 60);
    });
  });

  group('ProductInfo cálculos', () {
    final mira = ProductReference.products.firstWhere((p) => p.code == 'MIRA');

    test('calculatePurchase con multiplicador 1.0', () {
      expect(mira.calculatePurchase(multiplier: 1.0, units: 10), 130);
    });

    test('calculatePurchase con multiplicador 1.2', () {
      expect(mira.calculatePurchase(multiplier: 1.2, units: 10), 156);
    });

    test('calculatePurchase con multiplicador 0.8', () {
      expect(mira.calculatePurchase(multiplier: 0.8, units: 10), 104);
    });

    test('calculateSale con multiplicador 1.0', () {
      expect(mira.calculateSale(multiplier: 1.0, units: 10), 300);
    });

    test('calculateSale con multiplicador 1.2', () {
      expect(mira.calculateSale(multiplier: 1.2, units: 10), 360);
    });

    test('calculateSale con multiplicador 0.8', () {
      expect(mira.calculateSale(multiplier: 0.8, units: 10), 240);
    });

    test('calculatePurchase con 0 unidades devuelve 0', () {
      expect(mira.calculatePurchase(multiplier: 1.2, units: 0), 0);
    });

    test('calculatePurchase redondea al alza con multiplicador 1.2', () {
      final indu = ProductReference.products.firstWhere((p) => p.code == 'INDU');
      // 9 * 1.2 * 1 = 10.8 → 11
      expect(indu.calculatePurchase(multiplier: 1.2, units: 1), 11);
    });

    test('calculatePurchase redondea al alza con multiplicador 0.8', () {
      final indu = ProductReference.products.firstWhere((p) => p.code == 'INDU');
      // 9 * 0.8 * 1 = 7.2 → 8 (ceil, no round → 7)
      expect(indu.calculatePurchase(multiplier: 0.8, units: 1), 8);
    });

    test('calculateSale redondea al alza', () {
      final indu = ProductReference.products.firstWhere((p) => p.code == 'INDU');
      // 18 * 0.8 * 1 = 14.4 → 15
      expect(indu.calculateSale(multiplier: 0.8, units: 1), 15);
    });
  });
}

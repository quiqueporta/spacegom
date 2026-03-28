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
      expect(restored.purchaseAmount, 130);
      expect(restored.saleWorld, '445');
      expect(restored.saleAmount, 300);
      expect(restored.traceability, true);
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
}

import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/board_state.dart';
import 'package:spacegom_companion/models/cell_data.dart';

void main() {
  group('BoardState', () {
    test('toJson y fromJson producen el mismo estado', () {
      final state = BoardState(
        shipArea: 2,
        shipRow: 3,
        shipCol: 4,
        month: 5,
        year: 2,
        day: 15,
        hyperjumpDays: 7,
        areaCells: {
          2: {
            (3, 4): CellData(sectionNumber: 256, locationType: LocationType.spaceport),
            (1, 1): CellData(sectionNumber: 111),
          },
          1: {
            (2, 3): CellData(sectionNumber: 300, locationType: LocationType.hyperjump),
          },
        },
        areaDensity: {2: AreaDensity.high, 1: AreaDensity.low},
      );

      final json = state.toJson();
      final restored = BoardState.fromJson(json);

      expect(restored.shipArea, 2);
      expect(restored.shipRow, 3);
      expect(restored.shipCol, 4);
      expect(restored.month, 5);
      expect(restored.year, 2);
      expect(restored.day, 15);
      expect(restored.hyperjumpDays, 7);
      expect(restored.areaCells[2]?[(3, 4)]?.sectionNumber, 256);
      expect(restored.areaCells[2]?[(3, 4)]?.locationType, LocationType.spaceport);
      expect(restored.areaCells[2]?[(1, 1)]?.sectionNumber, 111);
      expect(restored.areaCells[2]?[(1, 1)]?.locationType, LocationType.world);
      expect(restored.areaCells[1]?[(2, 3)]?.sectionNumber, 300);
      expect(restored.areaCells[1]?[(2, 3)]?.locationType, LocationType.hyperjump);
      expect(restored.areaDensity[2], AreaDensity.high);
      expect(restored.areaDensity[1], AreaDensity.low);
    });

    test('valores por defecto', () {
      final state = BoardState();

      expect(state.shipArea, 1);
      expect(state.shipRow, 1);
      expect(state.shipCol, 1);
      expect(state.month, 1);
      expect(state.year, 1);
      expect(state.day, 1);
      expect(state.areaCells, isEmpty);
      expect(state.areaDensity, isEmpty);
    });

    test('copyWith crea copia con campos modificados', () {
      final original = BoardState(shipArea: 1, day: 10);
      final modified = original.copyWith(shipArea: 3);

      expect(modified.shipArea, 3);
      expect(modified.day, 10);
      expect(original.shipArea, 1);
    });

    test('findAreaForSection devuelve null si la sección no existe', () {
      final state = BoardState();

      expect(state.findAreaForSection(256), isNull);
    });

    test('findAreaForSection devuelve el área donde está la sección', () {
      final state = BoardState(
        areaCells: {
          3: {(1, 1): CellData(sectionNumber: 256)},
          5: {(2, 2): CellData(sectionNumber: 111)},
        },
      );

      expect(state.findAreaForSection(256), 3);
      expect(state.findAreaForSection(111), 5);
    });

    test('findAreaForSection ignora celdas sin número de sección', () {
      final state = BoardState(
        areaCells: {
          1: {(1, 1): CellData.deepSpace()},
        },
      );

      expect(state.findAreaForSection(256), isNull);
    });

    test('findAreaForSection encuentra duplicado en la misma área', () {
      final state = BoardState(
        areaCells: {
          3: {
            (1, 1): CellData(sectionNumber: 256),
            (2, 2): CellData(sectionNumber: 111),
          },
        },
      );

      expect(state.findAreaForSection(256), 3);
    });

    test('deserializa formato antiguo con enteros en areaCells', () {
      final legacyJson = {
        'shipArea': 2,
        'shipRow': 1,
        'shipCol': 1,
        'mes': 1,
        'anio': 1,
        'dia': 1,
        'hyperjumpDays': 0,
        'areaCells': {
          '2': {'3,4': 256},
        },
      };

      final restored = BoardState.fromJson(legacyJson);

      expect(restored.areaCells[2]?[(3, 4)]?.sectionNumber, 256);
      expect(restored.areaCells[2]?[(3, 4)]?.locationType, LocationType.world);
    });
  });
}

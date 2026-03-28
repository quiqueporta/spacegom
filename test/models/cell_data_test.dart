import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/cell_data.dart';

void main() {
  group('LocationType', () {
    test('toJson y fromJson round-trip', () {
      for (final type in LocationType.values) {
        final json = type.toJson();
        final restored = LocationTypeExtension.fromJson(json);

        expect(restored, type);
      }
    });
  });

  group('AreaDensity', () {
    test('toJson y fromJson round-trip', () {
      for (final density in AreaDensity.values) {
        final json = density.toJson();
        final restored = AreaDensityExtension.fromJson(json);

        expect(restored, density);
      }
    });
  });

  group('CellData', () {
    test('toJson y fromJson producen el mismo dato', () {
      final cell = CellData(
        sectionNumber: 256,
        locationType: LocationType.spaceport,
      );

      final json = cell.toJson();
      final restored = CellData.fromJson(json);

      expect(restored.sectionNumber, 256);
      expect(restored.locationType, LocationType.spaceport);
    });

    test('valores por defecto tienen tipo mundo', () {
      final cell = CellData(sectionNumber: 111);

      expect(cell.locationType, LocationType.world);
    });

    test('copyWith cambia solo los campos indicados', () {
      final original = CellData(
        sectionNumber: 333,
        locationType: LocationType.world,
      );

      final modified = original.copyWith(
        locationType: LocationType.hyperjump,
      );

      expect(modified.sectionNumber, 333);
      expect(modified.locationType, LocationType.hyperjump);
    });

    test('espacio profundo sin número de sección', () {
      final cell = CellData.deepSpace();

      expect(cell.sectionNumber, isNull);
      expect(cell.isDeepSpace, true);
    });

    test('serializa y deserializa piratas y megacorporación', () {
      final cell = CellData(
        sectionNumber: 256,
        pirates: true,
        megacorporation: 'Weyland',
      );

      final json = cell.toJson();
      final restored = CellData.fromJson(json);

      expect(restored.pirates, true);
      expect(restored.megacorporation, 'Weyland');
    });

    test('valores por defecto sin piratas ni megacorp', () {
      final cell = CellData(sectionNumber: 111);

      expect(cell.pirates, false);
      expect(cell.megacorporation, '');
      expect(cell.isDeepSpace, false);
    });
  });
}

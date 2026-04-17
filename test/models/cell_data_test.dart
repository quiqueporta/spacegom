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
      final cell = CellData(sectionNumber: 256);

      final json = cell.toJson();
      final restored = CellData.fromJson(json);

      expect(restored.sectionNumber, 256);
    });

    test('copyWith cambia solo los campos indicados', () {
      final original = CellData(sectionNumber: 333, pirates: true);

      final modified = original.copyWith(megacorporation: 'Weyland');

      expect(modified.sectionNumber, 333);
      expect(modified.pirates, true);
      expect(modified.megacorporation, 'Weyland');
    });

    test('fromJson ignora locationType de datos antiguos', () {
      final json = {
        'sectionNumber': 256,
        'locationType': 'spaceport',
        'pirates': false,
        'megacorporation': '',
      };

      final restored = CellData.fromJson(json);

      expect(restored.sectionNumber, 256);
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

    test('serializa y deserializa notas', () {
      final cell = CellData(sectionNumber: 256, notes: 'Buen sitio para comerciar');

      final json = cell.toJson();
      final restored = CellData.fromJson(json);

      expect(restored.notes, 'Buen sitio para comerciar');
    });

    test('notas vacías por defecto', () {
      final cell = CellData(sectionNumber: 111);

      expect(cell.notes, '');
    });

    test('hasNotes es true cuando tiene notas', () {
      final cell = CellData(sectionNumber: 111, notes: 'Algo');

      expect(cell.hasNotes, true);
    });

    test('hasNotes es false cuando no tiene notas', () {
      final cell = CellData(sectionNumber: 111);

      expect(cell.hasNotes, false);
    });

    test('fromJson sin notas mantiene compatibilidad', () {
      final json = {
        'sectionNumber': 256,
        'pirates': false,
        'megacorporation': '',
      };

      final restored = CellData.fromJson(json);

      expect(restored.notes, '');
    });

    test('celda sin asignar por defecto tiene type unassigned', () {
      final cell = CellData();

      expect(cell.type, CellType.unassigned);
      expect(cell.isUnassigned, isTrue);
      expect(cell.isWorld, isFalse);
      expect(cell.isDeepSpace, isFalse);
    });

    test('celda con sectionNumber es tipo world', () {
      final cell = CellData(sectionNumber: 256);

      expect(cell.type, CellType.world);
      expect(cell.isWorld, isTrue);
    });

    test('espacio profundo es tipo deepSpace', () {
      final cell = CellData.deepSpace();

      expect(cell.type, CellType.deepSpace);
      expect(cell.isDeepSpace, isTrue);
      expect(cell.isWorld, isFalse);
    });

    test('celda unassigned puede tener megacorporación', () {
      final cell = CellData(megacorporation: 'Weyland');

      expect(cell.isUnassigned, isTrue);
      expect(cell.megacorporation, 'Weyland');
    });

    test('toJson incluye type explícito', () {
      final unassigned = CellData(megacorporation: 'Weyland');
      final world = CellData(sectionNumber: 256);
      final deepSpace = CellData.deepSpace(megacorporation: 'Weyland');

      expect(unassigned.toJson()['type'], 'unassigned');
      expect(world.toJson()['type'], 'world');
      expect(deepSpace.toJson()['type'], 'deepSpace');
    });

    test('fromJson con type explícito lo usa', () {
      final json = {
        'type': 'unassigned',
        'sectionNumber': null,
        'megacorporation': 'Weyland',
      };

      final restored = CellData.fromJson(json);

      expect(restored.type, CellType.unassigned);
      expect(restored.megacorporation, 'Weyland');
    });

    test('backward compat: fromJson con sectionNumber int infiere world', () {
      final legacyJson = <String, dynamic>{
        'sectionNumber': 256,
        'pirates': false,
        'megacorporation': '',
      };

      final restored = CellData.fromJson(legacyJson);

      expect(restored.type, CellType.world);
      expect(restored.sectionNumber, 256);
    });

    test('backward compat: fromJson con sectionNumber null infiere deepSpace', () {
      final legacyJson = <String, dynamic>{
        'sectionNumber': null,
        'pirates': false,
        'megacorporation': '',
      };

      final restored = CellData.fromJson(legacyJson);

      expect(restored.type, CellType.deepSpace);
    });

    test('copyWith cambia el type', () {
      final unassigned = CellData(megacorporation: 'Weyland');
      final asWorld = unassigned.copyWith(type: CellType.world, sectionNumber: 256);

      expect(asWorld.type, CellType.world);
      expect(asWorld.sectionNumber, 256);
      expect(asWorld.megacorporation, 'Weyland');
    });
  });
}

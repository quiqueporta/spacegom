import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/planet.dart';

void main() {
  group('Planet', () {
    test('toJson y fromJson producen el mismo planeta', () {
      final planet = Planet(
        name: 'Pucolla',
        lifeSupport: 'NO/TA*',
        contagionRisk: 'NO',
        agreement: 'SÍ',
        hyperjumpDays: 7,
        legalSystem: '9+',
        spaceport: 'EXC-DA-16',
        cc: 'NO',
        pi: 'SÍ',
        ds: 'SÍ',
        aa: 'NO',
        products: ['INDU', 'BASI', 'ALIM', 'MICO', 'PAVA', 'A', 'AE', 'AEI'],
        selfSufficiency: 5,
        ucnPerOrder: 10,
        passengers: 18,
        missions: '8+',
      );

      final json = planet.toJson();
      final restored = Planet.fromJson(json);

      expect(restored.name, planet.name);
      expect(restored.hyperjumpDays, planet.hyperjumpDays);
      expect(restored.products, planet.products);
      expect(restored.selfSufficiency, planet.selfSufficiency);
      expect(restored.missions, planet.missions);
    });
  });

  group('PlanetDatabase', () {
    test('contiene 216 planetas', () {
      final db = PlanetDatabase.planets;

      expect(db.length, 216);
    });

    test('el planeta 256 es Pucolla', () {
      final planet = PlanetDatabase.planets[256];

      expect(planet, isNotNull);
      expect(planet!.name, 'Pucolla');
      expect(planet.hyperjumpDays, 7);
      expect(planet.spaceport, 'EXC-DA-16');
    });

    test('el primer planeta es Chipethea (111)', () {
      final planet = PlanetDatabase.planets[111];

      expect(planet, isNotNull);
      expect(planet!.name, 'Chipethea');
    });

    test('el último planeta es Vilecarro (666)', () {
      final planet = PlanetDatabase.planets[666];

      expect(planet, isNotNull);
      expect(planet!.name, 'Vilecarro');
    });
  });
}

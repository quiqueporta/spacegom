import 'dart:math';

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

  group('Planet.parsedMissions', () {
    Planet planetWithMissions(String missions) => Planet(
      name: 'X',
      lifeSupport: '',
      contagionRisk: '',
      agreement: '',
      hyperjumpDays: 0,
      legalSystem: '',
      spaceport: '',
      cc: '',
      pi: '',
      ds: '',
      aa: '',
      products: const [],
      selfSufficiency: 0,
      ucnPerOrder: 0,
      passengers: 0,
      missions: missions,
    );

    test('parsea "10+" como 10', () {
      expect(planetWithMissions('10+').parsedMissions, 10);
    });

    test('parsea "7+" como 7', () {
      expect(planetWithMissions('7+').parsedMissions, 7);
    });

    test('parsea "8" sin más como 8', () {
      expect(planetWithMissions('8').parsedMissions, 8);
    });

    test('parsea "0" como 0', () {
      expect(planetWithMissions('0').parsedMissions, 0);
    });

    test('devuelve null si no es parseable', () {
      expect(planetWithMissions('').parsedMissions, isNull);
      expect(planetWithMissions('SIN').parsedMissions, isNull);
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

    test('randomSectionNumber genera un código válido de 3 dígitos (1-6 cada uno)', () {
      for (var i = 0; i < 100; i++) {
        final code = PlanetDatabase.randomSectionNumber();
        final digits = code.toString().split('').map(int.parse).toList();

        expect(digits.length, 3);
        for (final digit in digits) {
          expect(digit, greaterThanOrEqualTo(1));
          expect(digit, lessThanOrEqualTo(6));
        }
      }
    });

    test('randomSectionNumber corresponde a un planeta existente', () {
      for (var i = 0; i < 100; i++) {
        final code = PlanetDatabase.randomSectionNumber();

        expect(PlanetDatabase.planets.containsKey(code), isTrue);
      }
    });

    test('randomSectionNumber usa el Random proporcionado', () {
      final random = Random(42);
      final code1 = PlanetDatabase.randomSectionNumber(random: random);

      final random2 = Random(42);
      final code2 = PlanetDatabase.randomSectionNumber(random: random2);

      expect(code1, code2);
    });
  });
}

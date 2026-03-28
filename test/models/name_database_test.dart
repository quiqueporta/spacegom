import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/name_database.dart';

void main() {
  group('NameDatabase', () {
    test('contiene nombres personales', () {
      expect(NameDatabase.personalNames.length, greaterThan(900));
    });

    test('contiene nombres de megacorporación', () {
      expect(NameDatabase.megacorpNames.length, greaterThan(400));
    });

    test('los nombres personales no están vacíos', () {
      for (final name in NameDatabase.personalNames) {
        expect(name.trim().isNotEmpty, isTrue);
      }
    });

    test('los nombres de megacorp no están vacíos', () {
      for (final name in NameDatabase.megacorpNames) {
        expect(name.trim().isNotEmpty, isTrue);
      }
    });

    test('randomPersonalName devuelve un nombre de la lista', () {
      final name = NameDatabase.randomPersonalName();

      expect(NameDatabase.personalNames.contains(name), isTrue);
    });

    test('randomMegacorpName devuelve un nombre de la lista', () {
      final name = NameDatabase.randomMegacorpName();

      expect(NameDatabase.megacorpNames.contains(name), isTrue);
    });

    test('el primer nombre personal es Widaker Farq', () {
      expect(NameDatabase.personalNames.first, 'Widaker Farq');
    });

    test('la primera megacorp es Orion Holdings', () {
      expect(NameDatabase.megacorpNames.first, 'Orion Holdings');
    });
  });
}

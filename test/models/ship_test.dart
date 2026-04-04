import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/ship.dart';

void main() {
  group('Ship', () {
    test('toJson y fromJson round-trip', () {
      final ship = Ship(
        name: 'Millennium Falcon',
        model: 'Clase B',
        hyperjumpCapacity: 3,
        rollModifier: 1,
        maxPassengers: 20,
        maxCargo: 100,
        lightSupport: 3,
        moderateSupport: 2,
        severeSupport: 1,
      );

      final json = ship.toJson();
      final restored = Ship.fromJson(json);

      expect(restored.name, 'Millennium Falcon');
      expect(restored.model, 'Clase B');
      expect(restored.hyperjumpCapacity, 3);
      expect(restored.rollModifier, 1);
      expect(restored.maxPassengers, 20);
      expect(restored.maxCargo, 100);
      expect(restored.lightSupport, 3);
      expect(restored.moderateSupport, 2);
      expect(restored.severeSupport, 1);
    });

    test('valores por defecto', () {
      final ship = Ship();

      expect(ship.name, '');
      expect(ship.model, '');
      expect(ship.hyperjumpCapacity, 0);
      expect(ship.lightSupport, 0);
    });

    test('fromJson sin nombre mantiene compatibilidad', () {
      final json = {
        'model': 'Clase A',
        'hyperjumpCapacity': 2,
      };

      final restored = Ship.fromJson(json);

      expect(restored.name, '');
      expect(restored.model, 'Clase A');
    });

    test('copyWith cambia solo los campos indicados', () {
      final original = Ship(model: 'Clase A', hyperjumpCapacity: 2);
      final modified = original.copyWith(hyperjumpCapacity: 5);

      expect(modified.model, 'Clase A');
      expect(modified.hyperjumpCapacity, 5);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/weapon.dart';

void main() {
  group('WeaponReference', () {
    test('tiene 10 tipos de arma', () {
      expect(WeaponReference.weapons.length, 10);
    });

    test('Infabots avanzados tiene efecto 3 y coste 300', () {
      final infabot = WeaponReference.weapons.last;

      expect(infabot.weaponName, 'Infabots avanzados');
      expect(infabot.effect, 3);
      expect(infabot.cost, 300);
      expect(infabot.maintenance, 2);
    });
  });

  group('Weapon', () {
    test('toJson y fromJson round-trip', () {
      final weapon = Weapon(
        employeeId: 5,
        weaponName: 'Armas láser básicas',
      );

      final json = weapon.toJson();
      final restored = Weapon.fromJson(json);

      expect(restored.employeeId, 5);
      expect(restored.weaponName, 'Armas láser básicas');
    });

    test('valores por defecto', () {
      final weapon = Weapon(employeeId: 1);

      expect(weapon.weaponName, 'Desarmado');
    });
  });
}

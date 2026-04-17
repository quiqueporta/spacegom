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

    test('arma en reserva tiene employeeId null', () {
      final weapon = Weapon(employeeId: null, weaponName: 'Rifle láser');

      expect(weapon.employeeId, isNull);
      expect(weapon.isInReserve, isTrue);
    });

    test('arma asignada a empleado no está en reserva', () {
      final weapon = Weapon(employeeId: 5, weaponName: 'Rifle láser');

      expect(weapon.isInReserve, isFalse);
    });

    test('toJson y fromJson preservan employeeId null (reserva)', () {
      final weapon = Weapon(employeeId: null, weaponName: 'Rifle láser');

      final json = weapon.toJson();
      final restored = Weapon.fromJson(json);

      expect(restored.employeeId, isNull);
      expect(restored.isInReserve, isTrue);
    });

    test('fromJson con formato antiguo (employeeId no null) funciona', () {
      final legacyJson = <String, dynamic>{
        'employeeId': 3,
        'weaponName': 'Armas láser básicas',
      };

      final restored = Weapon.fromJson(legacyJson);

      expect(restored.employeeId, 3);
      expect(restored.isInReserve, isFalse);
    });
  });
}

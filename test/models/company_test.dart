import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/ship.dart';

void main() {
  group('Company', () {
    test('toJson y fromJson producen la misma compañía', () {
      final company = Company(
        companyName: 'Mi Empresa',
        ships: [Ship(model: 'Clase B', hyperjumpCapacity: 3, rollModifier: 1, maxPassengers: 20, maxCargo: 100)],
        fuel: 15,
        storage: 42,
        reputation: 2,
        lightDamage: 1,
      );

      final json = company.toJson();
      final restored = Company.fromJson(json);

      expect(restored.companyName, 'Mi Empresa');
      expect(restored.activeShip.model, 'Clase B');
      expect(restored.activeShip.hyperjumpCapacity, 3);
      expect(restored.fuel, 15);
      expect(restored.reputation, 2);
      expect(restored.lightDamage, 1);
    });

    test('valores por defecto son cero o vacío', () {
      final company = Company();

      expect(company.companyName, '');
      expect(company.fuel, 0);
      expect(company.reputation, 0);
      expect(company.ships.length, 1);
    });

    test('copyWith crea copia con campos modificados', () {
      final original = Company(companyName: 'A', fuel: 10);
      final modified = original.copyWith(fuel: 20);

      expect(modified.companyName, 'A');
      expect(modified.fuel, 20);
      expect(original.fuel, 10);
    });

    test('soporte a daños está en la nave activa', () {
      final company = Company(
        ships: [Ship(lightSupport: 3, moderateSupport: 2, severeSupport: 1)],
      );

      expect(company.activeShip.lightSupport, 3);
      expect(company.activeShip.moderateSupport, 2);
      expect(company.activeShip.severeSupport, 1);
    });

    test('múltiples naves con una activa', () {
      final company = Company(
        ships: [
          Ship(model: 'Clase A'),
          Ship(model: 'Clase B'),
        ],
        activeShipIndex: 1,
      );

      expect(company.activeShip.model, 'Clase B');
      expect(company.ships.length, 2);
    });

    test('serializa y deserializa empleados', () {
      final company = Company(
        companyName: 'Test Corp',
        employees: [
          Employee(id: 1, name: 'Ana', role: 'Piloto', salary: 5),
          Employee(id: 2, name: 'Luis', experience: ExperienceLevel.veteran),
        ],
      );

      final json = company.toJson();
      final restored = Company.fromJson(json);

      expect(restored.employees.length, 2);
      expect(restored.employees[0].name, 'Ana');
      expect(restored.employees[1].experience, ExperienceLevel.veteran);
    });

    test('saludMarks por defecto es 0', () {
      final company = Company();

      expect(company.saludMarks, 0);
    });

    test('serializa y deserializa saludMarks', () {
      final company = Company(saludMarks: 12);

      final json = company.toJson();
      final restored = Company.fromJson(json);

      expect(restored.saludMarks, 12);
    });

    test('lifeSupportEquipment por defecto vacío', () {
      final company = Company();

      expect(company.lifeSupportEquipment, isEmpty);
    });

    test('serializa y deserializa lifeSupportEquipment', () {
      final company = Company(
        lifeSupportEquipment: {'SO': 7, 'MF': 5, 'TE': 1},
      );

      final json = company.toJson();
      final restored = Company.fromJson(json);

      expect(restored.lifeSupportEquipment['SO'], 7);
      expect(restored.lifeSupportEquipment['MF'], 5);
      expect(restored.lifeSupportEquipment['TE'], 1);
      expect(restored.lifeSupportEquipment.length, 3);
    });

    test('compatibilidad con formato antiguo sin ships', () {
      final legacyJson = {
        'companyName': 'Old Corp',
        'shipModel': 'Vieja',
        'hyperjumpCapacity': 2,
        'rollModifier': 1,
        'maxPassengers': 10,
        'maxCargo': 50,
        'soporteLeves': 3,
        'soporteModerados': 2,
        'soporteGraves': 1,
        'fuel': 5,
      };

      final restored = Company.fromJson(legacyJson);

      expect(restored.activeShip.model, 'Vieja');
      expect(restored.activeShip.hyperjumpCapacity, 2);
      expect(restored.activeShip.lightSupport, 3);
      expect(restored.fuel, 5);
    });
  });
}

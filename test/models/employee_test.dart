import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/employee.dart';

void main() {
  group('ExperienceLevel', () {
    test('toJson y fromJson round-trip', () {
      for (final level in ExperienceLevel.values) {
        final json = level.toJson();
        final restored = ExperienceLevelExtension.fromJson(json);

        expect(restored, level);
      }
    });
  });

  group('MoraleLevel', () {
    test('toJson y fromJson round-trip', () {
      for (final level in MoraleLevel.values) {
        final json = level.toJson();
        final restored = MoraleLevelExtension.fromJson(json);

        expect(restored, level);
      }
    });
  });

  group('Employee', () {
    test('toJson y fromJson producen el mismo empleado', () {
      final employee = Employee(
        id: 1,
        role: 'Piloto',
        name: 'Han Solo',
        salary: 5,
        experience: ExperienceLevel.experienced,
        morale: MoraleLevel.high,
        moralChecks: 3,
        dismissed: false,
      );

      final json = employee.toJson();
      final restored = Employee.fromJson(json);

      expect(restored.id, 1);
      expect(restored.role, 'Piloto');
      expect(restored.name, 'Han Solo');
      expect(restored.salary, 5);
      expect(restored.experience, ExperienceLevel.experienced);
      expect(restored.morale, MoraleLevel.high);
      expect(restored.moralChecks, 3);
      expect(restored.dismissed, false);
    });

    test('valores por defecto', () {
      final employee = Employee(id: 1);

      expect(employee.role, '');
      expect(employee.name, '');
      expect(employee.salary, 0);
      expect(employee.experience, ExperienceLevel.beginner);
      expect(employee.morale, MoraleLevel.medium);
      expect(employee.moralChecks, 0);
      expect(employee.dismissed, false);
    });

    test('experiencia solo sube de nivel', () {
      final beginner = Employee(id: 1, experience: ExperienceLevel.beginner);

      final promoted = beginner.promoteExperience();

      expect(promoted.experience, ExperienceLevel.experienced);

      final veteran = promoted.promoteExperience();

      expect(veteran.experience, ExperienceLevel.veteran);
    });

    test('experiencia veterano no sube más', () {
      final veteran = Employee(id: 1, experience: ExperienceLevel.veteran);

      final same = veteran.promoteExperience();

      expect(same.experience, ExperienceLevel.veteran);
    });

    test('moralChecks no puede superar el máximo', () {
      final employee = Employee(id: 1, moralChecks: Employee.maxMoralChecks);

      final same = employee.copyWith(moralChecks: Employee.maxMoralChecks + 1);

      expect(same.moralChecks, Employee.maxMoralChecks);
    });

    test('copyWith cambia solo los campos indicados', () {
      final original = Employee(
        id: 1,
        name: 'Original',
        experience: ExperienceLevel.beginner,
      );

      final modified = original.copyWith(name: 'Modificado');

      expect(modified.name, 'Modificado');
      expect(modified.id, 1);
      expect(modified.experience, ExperienceLevel.beginner);
    });
  });
}

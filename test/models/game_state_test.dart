import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/board_state.dart';
import 'package:spacegom_companion/models/cell_data.dart';
import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/game_state.dart';

void main() {
  group('GameState', () {
    test('toJson y fromJson producen el mismo estado completo', () {
      final state = GameState(
        company: Company(
          companyName: 'Test Corp',
          fuel: 20,
          reputation: -3,
        ),
        boardState: BoardState(
          shipArea: 2,
          shipRow: 3,
          shipCol: 4,
          day: 15,
          areaCells: {
            2: {(3, 4): CellData(sectionNumber: 256)},
          },
        ),
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.company.companyName, 'Test Corp');
      expect(restored.company.fuel, 20);
      expect(restored.company.reputation, -3);
      expect(restored.boardState.shipArea, 2);
      expect(restored.boardState.areaCells[2]?[(3, 4)]?.sectionNumber, 256);
    });

    test('se puede serializar a JSON string y recuperar', () {
      final state = GameState(
        company: Company(companyName: 'Serialización'),
        boardState: BoardState(day: 25),
      );

      final jsonString = jsonEncode(state.toJson());
      final restored = GameState.fromJson(jsonDecode(jsonString));

      expect(restored.company.companyName, 'Serialización');
      expect(restored.boardState.day, 25);
    });

    test('valores por defecto', () {
      final state = GameState();

      expect(state.company.companyName, '');
      expect(state.boardState.shipArea, 1);
    });
  });

  group('GameState.withDefaultCrew', () {
    test('incluye 11 tripulantes', () {
      final state = GameState.withDefaultCrew();

      expect(state.company.employees.length, 11);
    });

    test('el primer tripulante es Widaker Farq con 20 SC y veterano en experiencia', () {
      final state = GameState.withDefaultCrew();
      final widaker = state.company.employees.first;

      expect(widaker.name, 'Widaker Farq');
      expect(widaker.salary, 20);
      expect(widaker.experience, ExperienceLevel.experienced);
      expect(widaker.morale, MoraleLevel.high);
    });

    test('Thomas Muller es novato en experiencia', () {
      final state = GameState.withDefaultCrew();
      final muller = state.company.employees[2];

      expect(muller.name, 'Thomas Muller');
      expect(muller.salary, 4);
      expect(muller.experience, ExperienceLevel.beginner);
      expect(muller.morale, MoraleLevel.medium);
    });

    test('el resto del estado está vacío', () {
      final state = GameState.withDefaultCrew();

      expect(state.company.companyName, '');
      expect(state.boardState.shipArea, 1);
      expect(state.areaSheets, isEmpty);
    });

    test('los IDs de empleados son consecutivos empezando en 1', () {
      final state = GameState.withDefaultCrew();

      for (var i = 0; i < state.company.employees.length; i++) {
        expect(state.company.employees[i].id, i + 1);
      }
    });
  });
}

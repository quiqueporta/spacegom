import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spacegom_companion/models/board_state.dart';
import 'package:spacegom_companion/models/cell_data.dart';
import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/game_state.dart';
import 'package:spacegom_companion/services/storage_service.dart';

void main() {
  group('StorageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('devuelve estado con tripulación por defecto cuando no hay datos guardados', () async {
      final service = StorageService();

      final state = await service.loadGameState();

      expect(state.company.companyName, '');
      expect(state.boardState.shipArea, 1);
      expect(state.company.employees.length, 11);
      expect(state.company.employees.first.name, 'Widaker Farq');
    });

    test('guarda y recupera un GameState completo', () async {
      final service = StorageService();
      final state = GameState(
        company: Company(
          companyName: 'Nostromo',
          fuel: 42,
          reputation: -3,
        ),
        boardState: BoardState(
          shipArea: 5,
          shipRow: 2,
          shipCol: 4,
          day: 20,
          areaCells: {5: {(2, 4): CellData(sectionNumber: 333)}},
        ),
      );

      await service.saveGameState(state);
      final restored = await service.loadGameState();

      expect(restored.company.companyName, 'Nostromo');
      expect(restored.company.fuel, 42);
      expect(restored.company.reputation, -3);
      expect(restored.boardState.shipArea, 5);
      expect(restored.boardState.shipRow, 2);
      expect(restored.boardState.day, 20);
      expect(restored.boardState.areaCells[5]?[(2, 4)]?.sectionNumber, 333);
    });

    test('sobrescribe datos previos al guardar de nuevo', () async {
      final service = StorageService();

      await service.saveGameState(
        GameState(company: Company(companyName: 'Antigua')),
      );
      await service.saveGameState(
        GameState(company: Company(companyName: 'Nueva')),
      );

      final restored = await service.loadGameState();

      expect(restored.company.companyName, 'Nueva');
    });

    test('elimina los datos guardados', () async {
      final service = StorageService();
      await service.saveGameState(
        GameState(company: Company(companyName: 'Temporal')),
      );

      await service.clearGameState();
      final restored = await service.loadGameState();

      expect(restored.company.companyName, '');
    });
  });

  group('exportar a archivo', () {
    test('genera un archivo JSON con el estado del juego', () async {
      final service = StorageService();
      final state = GameState(
        company: Company(companyName: 'Nostromo', fuel: 42),
        boardState: BoardState(shipArea: 5),
      );
      final dir = Directory.systemTemp.createTempSync('spacegom_test_');

      final file = await service.exportToFile(state, dir.path);

      expect(file.existsSync(), isTrue);
      expect(file.path, endsWith('.json'));

      final content = jsonDecode(file.readAsStringSync());
      expect(content['company']['companyName'], 'Nostromo');
      expect(content['company']['fuel'], 42);
      expect(content['boardState']['shipArea'], 5);

      dir.deleteSync(recursive: true);
    });

    test('el nombre del archivo contiene la fecha', () async {
      final service = StorageService();
      final dir = Directory.systemTemp.createTempSync('spacegom_test_');

      final file = await service.exportToFile(GameState(), dir.path);

      final fileName = file.uri.pathSegments.last;
      expect(fileName, startsWith('spacegom_'));
      expect(fileName, endsWith('.json'));

      dir.deleteSync(recursive: true);
    });
  });

  group('importar desde archivo', () {
    test('lee un archivo JSON y devuelve el GameState', () async {
      final service = StorageService();
      final state = GameState(
        company: Company(companyName: 'Importada', fuel: 99),
      );
      final dir = Directory.systemTemp.createTempSync('spacegom_test_');
      final file = File('${dir.path}/test_import.json');
      file.writeAsStringSync(jsonEncode(state.toJson()));

      final imported = await service.importFromFile(file.path);

      expect(imported.company.companyName, 'Importada');
      expect(imported.company.fuel, 99);

      dir.deleteSync(recursive: true);
    });

    test('lanza excepción si el archivo no existe', () async {
      final service = StorageService();

      expect(
        () => service.importFromFile('/ruta/inexistente.json'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('lanza FormatException si el JSON no es válido', () async {
      final service = StorageService();
      final dir = Directory.systemTemp.createTempSync('spacegom_test_');
      final file = File('${dir.path}/bad.json');
      file.writeAsStringSync('esto no es json');

      expect(
        () => service.importFromFile(file.path),
        throwsA(isA<FormatException>()),
      );

      dir.deleteSync(recursive: true);
    });
  });
}

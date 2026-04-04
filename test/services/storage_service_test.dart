import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spacegom_companion/models/area_sheet.dart';
import 'package:spacegom_companion/models/board_state.dart';
import 'package:spacegom_companion/models/campaign_calendar.dart';
import 'package:spacegom_companion/models/cell_data.dart';
import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/game_state.dart';
import 'package:spacegom_companion/models/ship.dart';
import 'package:spacegom_companion/models/treasury.dart';
import 'package:spacegom_companion/models/weapon.dart';
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

    test('persiste y restaura todos los campos del GameState', () async {
      final service = StorageService();
      final state = GameState(
        company: Company(
          companyName: 'Nostromo',
          ships: [
            Ship(
              model: 'Carguero X',
              hyperjumpCapacity: 3,
              rollModifier: -1,
              maxPassengers: 12,
              maxCargo: 50,
              lightSupport: 2,
              moderateSupport: 1,
              severeSupport: 0,
            ),
          ],
          activeShipIndex: 0,
          fuel: 42,
          storage: 100,
          reputation: -3,
          lightDamage: 1,
          moderateDamage: 2,
          severeDamage: 0,
          saludMarks: 5,
          employees: [
            Employee(
              id: 1,
              name: 'Widaker Farq',
              role: 'Capitán',
              salary: 20,
              experience: ExperienceLevel.veteran,
              morale: MoraleLevel.high,
              moralChecks: 3,
              dismissed: false,
            ),
            Employee(
              id: 2,
              name: 'Despedido',
              salary: 5,
              dismissed: true,
            ),
          ],
          weapons: [
            Weapon(employeeId: 1, weaponName: 'Rifle láser'),
          ],
          lifeSupportEquipment: {'T1': 2, 'T3': 1},
          treasury: Treasury(
            transactions: [
              Transaction(concept: 'Sueldo', amount: -100),
              Transaction(concept: 'Venta', amount: 300),
            ],
            loans: [
              Loan(
                id: 1,
                amount: 500,
                totalRepayment: 600,
                grantDate: '1/1/1',
                endDate: '1/6/1',
                monthlyPayment: 100,
                paidInstallments: 3,
              ),
            ],
          ),
        ),
        boardState: BoardState(
          shipArea: 5,
          shipRow: 2,
          shipCol: 4,
          month: 3,
          year: 2,
          day: 20,
          hyperjumpDays: 7,
          areaCells: {
            5: {(2, 4): CellData(sectionNumber: 333, pirates: true, megacorporation: 'MegaCorp')},
          },
          areaDensity: {5: AreaDensity.high},
          selectedLocation: '333',
        ),
        calendar: CampaignCalendar(
          currentYear: 2,
          markedDays: {2: {(3, 15)}},
          specialDates: {2: [SpecialDate(letter: 'F', month: 3, day: 15, description: 'Festival')]},
          adminDone: {2: {(3, 7)}},
        ),
        areaSheets: {
          5: AreaSheet(
            missions: [
              SpecialMission(
                code: 'M-23',
                acceptanceWorld: '256',
                executionLocations: 'Strikupra',
                deadline: '15/03/01',
                result: MissionResult.success,
              ),
            ],
            trades: [
              TradeRecord(
                purchaseWorld: '333',
                productCode: 'MIRA',
                purchaseUnits: 10,
                purchaseAmount: 130,
                purchaseDate: '10/02/01',
                saleWorld: '445',
                saleAmount: 300,
                saleDate: '20/03/01',
                traceability: true,
                voided: false,
              ),
              TradeRecord(
                purchaseWorld: '111',
                productCode: 'ALIM',
                purchaseUnits: 5,
                purchaseAmount: 40,
                voided: true,
              ),
            ],
          ),
        },
      );

      await service.saveGameState(state);
      final r = await service.loadGameState();

      // Company
      expect(r.company.companyName, 'Nostromo');
      expect(r.company.activeShipIndex, 0);
      expect(r.company.fuel, 42);
      expect(r.company.storage, 100);
      expect(r.company.reputation, -3);
      expect(r.company.lightDamage, 1);
      expect(r.company.moderateDamage, 2);
      expect(r.company.severeDamage, 0);
      expect(r.company.saludMarks, 5);

      // Ship
      final ship = r.company.ships[0];
      expect(ship.model, 'Carguero X');
      expect(ship.hyperjumpCapacity, 3);
      expect(ship.rollModifier, -1);
      expect(ship.maxPassengers, 12);
      expect(ship.maxCargo, 50);
      expect(ship.lightSupport, 2);
      expect(ship.moderateSupport, 1);
      expect(ship.severeSupport, 0);

      // Employees
      expect(r.company.employees.length, 2);
      final emp = r.company.employees[0];
      expect(emp.id, 1);
      expect(emp.name, 'Widaker Farq');
      expect(emp.role, 'Capitán');
      expect(emp.salary, 20);
      expect(emp.experience, ExperienceLevel.veteran);
      expect(emp.morale, MoraleLevel.high);
      expect(emp.moralChecks, 3);
      expect(emp.dismissed, false);
      expect(r.company.employees[1].dismissed, true);

      // Weapons
      expect(r.company.weapons.length, 1);
      expect(r.company.weapons[0].employeeId, 1);
      expect(r.company.weapons[0].weaponName, 'Rifle láser');

      // Life support
      expect(r.company.lifeSupportEquipment, {'T1': 2, 'T3': 1});

      // Treasury
      expect(r.company.treasury.transactions.length, 2);
      expect(r.company.treasury.transactions[0].concept, 'Sueldo');
      expect(r.company.treasury.transactions[0].amount, -100);
      expect(r.company.treasury.transactions[1].amount, 300);
      expect(r.company.treasury.loans.length, 1);
      final loan = r.company.treasury.loans[0];
      expect(loan.id, 1);
      expect(loan.amount, 500);
      expect(loan.totalRepayment, 600);
      expect(loan.grantDate, '1/1/1');
      expect(loan.endDate, '1/6/1');
      expect(loan.monthlyPayment, 100);
      expect(loan.paidInstallments, 3);

      // BoardState
      expect(r.boardState.shipArea, 5);
      expect(r.boardState.shipRow, 2);
      expect(r.boardState.shipCol, 4);
      expect(r.boardState.month, 3);
      expect(r.boardState.year, 2);
      expect(r.boardState.day, 20);
      expect(r.boardState.hyperjumpDays, 7);
      expect(r.boardState.selectedLocation, '333');
      expect(r.boardState.areaDensity[5], AreaDensity.high);
      final cell = r.boardState.areaCells[5]?[(2, 4)];
      expect(cell?.sectionNumber, 333);
      expect(cell?.pirates, true);
      expect(cell?.megacorporation, 'MegaCorp');

      // Calendar
      expect(r.calendar.currentYear, 2);
      expect(r.calendar.markedDays[2], contains((3, 15)));
      expect(r.calendar.specialDates[2]?.length, 1);
      expect(r.calendar.specialDates[2]?[0].letter, 'F');
      expect(r.calendar.specialDates[2]?[0].month, 3);
      expect(r.calendar.specialDates[2]?[0].day, 15);
      expect(r.calendar.specialDates[2]?[0].description, 'Festival');
      expect(r.calendar.adminDone[2], contains((3, 7)));

      // AreaSheets
      expect(r.areaSheets.length, 1);
      final sheet = r.areaSheets[5]!;
      expect(sheet.missions.length, 1);
      expect(sheet.missions[0].code, 'M-23');
      expect(sheet.missions[0].acceptanceWorld, '256');
      expect(sheet.missions[0].executionLocations, 'Strikupra');
      expect(sheet.missions[0].deadline, '15/03/01');
      expect(sheet.missions[0].result, MissionResult.success);

      expect(sheet.trades.length, 2);
      final trade = sheet.trades[0];
      expect(trade.purchaseWorld, '333');
      expect(trade.productCode, 'MIRA');
      expect(trade.purchaseUnits, 10);
      expect(trade.purchaseAmount, 130);
      expect(trade.purchaseDate, '10/02/01');
      expect(trade.saleWorld, '445');
      expect(trade.saleAmount, 300);
      expect(trade.saleDate, '20/03/01');
      expect(trade.traceability, true);
      expect(trade.voided, false);
      expect(sheet.trades[1].voided, true);
      expect(sheet.trades[1].purchaseUnits, 5);
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

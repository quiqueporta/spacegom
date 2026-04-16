import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/ship.dart';
import 'package:spacegom_companion/models/treasury.dart';
import 'package:spacegom_companion/models/weapon.dart';

class Company {
  final String companyName;
  final List<Ship> ships;
  final int activeShipIndex;
  final int fuel;
  final int storage;
  final int reputation;
  final int lightDamage;
  final int moderateDamage;
  final int severeDamage;
  final int saludMarks;
  final List<Employee> employees;
  final List<Weapon> weapons;
  final Map<String, int> lifeSupportEquipment;
  final Treasury treasury;

  Company({
    this.companyName = '',
    List<Ship>? ships,
    this.activeShipIndex = 0,
    this.fuel = 0,
    this.storage = 0,
    this.reputation = 0,
    this.lightDamage = 0,
    this.moderateDamage = 0,
    this.severeDamage = 0,
    this.saludMarks = 0,
    this.employees = const [],
    this.weapons = const [],
    this.lifeSupportEquipment = const {},
    this.treasury = const Treasury(),
  }) : ships = ships ?? [const Ship()];

  Ship get activeShip => ships[activeShipIndex];

  Company copyWith({
    String? companyName,
    List<Ship>? ships,
    int? activeShipIndex,
    int? fuel,
    int? storage,
    int? reputation,
    int? lightDamage,
    int? moderateDamage,
    int? severeDamage,
    int? saludMarks,
    List<Employee>? employees,
    List<Weapon>? weapons,
    Map<String, int>? lifeSupportEquipment,
    Treasury? treasury,
  }) {
    return Company(
      companyName: companyName ?? this.companyName,
      ships: ships ?? this.ships,
      activeShipIndex: activeShipIndex ?? this.activeShipIndex,
      fuel: fuel ?? this.fuel,
      storage: storage ?? this.storage,
      reputation: reputation ?? this.reputation,
      lightDamage: lightDamage ?? this.lightDamage,
      moderateDamage: moderateDamage ?? this.moderateDamage,
      severeDamage: severeDamage ?? this.severeDamage,
      saludMarks: saludMarks ?? this.saludMarks,
      employees: employees ?? this.employees,
      weapons: weapons ?? this.weapons,
      lifeSupportEquipment: lifeSupportEquipment ?? this.lifeSupportEquipment,
      treasury: treasury ?? this.treasury,
    );
  }

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'ships': ships.map((s) => s.toJson()).toList(),
    'activeShipIndex': activeShipIndex,
    'fuel': fuel,
    'storage': storage,
    'reputation': reputation,
    'lightDamage': lightDamage,
    'moderateDamage': moderateDamage,
    'severeDamage': severeDamage,
    'saludMarks': saludMarks,
    'employees': employees.map((e) => e.toJson()).toList(),
    'weapons': weapons.map((w) => w.toJson()).toList(),
    'lifeSupportEquipment': lifeSupportEquipment,
    'treasury': treasury.toJson(),
  };

  factory Company.fromJson(Map<String, dynamic> json) {
    final shipsJson = json['ships'] as List<dynamic>?;

    final ships = shipsJson != null
        ? shipsJson.map((s) => Ship.fromJson(s as Map<String, dynamic>)).toList()
        : [_legacyShipFromJson(json)];

    return Company(
      companyName: json['companyName'] as String? ?? '',
      ships: ships,
      activeShipIndex: json['activeShipIndex'] as int? ?? 0,
      fuel: json['fuel'] as int? ?? 0,
      storage: json['storage'] as int? ?? 0,
      reputation: json['reputation'] as int? ?? 0,
      lightDamage: json['lightDamage'] as int? ?? 0,
      moderateDamage: json['moderateDamage'] as int? ?? 0,
      severeDamage: json['severeDamage'] as int? ?? 0,
      saludMarks: json['saludMarks'] as int? ?? 0,
      employees: _deduplicateEmployeeIds(
        (json['employees'] as List<dynamic>?)
            ?.map((e) => Employee.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      ),
      weapons: (json['weapons'] as List<dynamic>?)
          ?.map((w) => Weapon.fromJson(w as Map<String, dynamic>))
          .toList() ?? [],
      lifeSupportEquipment: (json['lifeSupportEquipment'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
      treasury: json['treasury'] != null
          ? Treasury.fromJson(json['treasury'] as Map<String, dynamic>)
          : const Treasury(),
    );
  }

  static List<Employee> _deduplicateEmployeeIds(List<Employee> employees) {
    final seenIds = <int>{};
    var maxId = employees.fold(0, (max, e) => e.id > max ? e.id : max);
    final result = <Employee>[];

    for (final employee in employees) {
      if (seenIds.contains(employee.id)) {
        maxId++;
        result.add(employee.copyWith(id: maxId));
      } else {
        seenIds.add(employee.id);
        result.add(employee);
      }
    }

    return result;
  }

  static Ship _legacyShipFromJson(Map<String, dynamic> json) {
    return Ship(
      model: json['shipModel'] as String? ?? '',
      hyperjumpCapacity: json['hyperjumpCapacity'] as int? ?? 0,
      rollModifier: json['rollModifier'] as int? ?? 0,
      maxPassengers: json['maxPassengers'] as int? ?? 0,
      maxCargo: json['maxCargo'] as int? ?? 0,
      lightSupport: json['soporteLeves'] as int? ?? 0,
      moderateSupport: json['soporteModerados'] as int? ?? 0,
      severeSupport: json['soporteGraves'] as int? ?? 0,
    );
  }
}

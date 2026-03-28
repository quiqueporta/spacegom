class WeaponType {
  final String weaponName;
  final String techLevel;
  final int effect;
  final int cost;
  final int maintenance;

  const WeaponType({
    required this.weaponName,
    required this.techLevel,
    required this.effect,
    required this.cost,
    required this.maintenance,
  });
}

class WeaponReference {
  static const weapons = [
    WeaponType(weaponName: 'Desarmado', techLevel: 'N/A', effect: -5, cost: 0, maintenance: 0),
    WeaponType(weaponName: 'Arma primitiva', techLevel: 'Primitivo', effect: -3, cost: 1, maintenance: 0),
    WeaponType(weaponName: 'Arma de fuego rudimentaria', techLevel: 'Rud. industrial básico', effect: -2, cost: 2, maintenance: 0),
    WeaponType(weaponName: '2ª Guerra Mundial', techLevel: 'Rud. industrial avanzado', effect: -1, cost: 3, maintenance: 0),
    WeaponType(weaponName: 'Arma del siglo XXI', techLevel: 'Rud. postindustrial', effect: 0, cost: 5, maintenance: 0),
    WeaponType(weaponName: 'Armas láser básicas', techLevel: 'Espacial-medio', effect: 1, cost: 10, maintenance: 0),
    WeaponType(weaponName: 'Armas láser avanzada', techLevel: 'Interestelar primitivo', effect: 2, cost: 25, maintenance: 0),
    WeaponType(weaponName: 'Infabots básicos', techLevel: 'Interestelar-medio', effect: 1, cost: 150, maintenance: 2),
    WeaponType(weaponName: 'Infabots medios', techLevel: 'Postinterestelar', effect: 2, cost: 225, maintenance: 2),
    WeaponType(weaponName: 'Infabots avanzados', techLevel: 'Nivel superior', effect: 3, cost: 300, maintenance: 2),
  ];
}

class Weapon {
  final int employeeId;
  final String weaponName;

  const Weapon({
    required this.employeeId,
    this.weaponName = 'Desarmado',
  });

  WeaponType? get weaponType =>
      WeaponReference.weapons.where((w) => w.weaponName == weaponName).firstOrNull;

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'weaponName': weaponName,
  };

  factory Weapon.fromJson(Map<String, dynamic> json) => Weapon(
    employeeId: json['employeeId'] as int,
    weaponName: json['weaponName'] as String? ?? 'Desarmado',
  );
}

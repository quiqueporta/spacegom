import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/life_support.dart';
import 'package:spacegom_companion/models/ship.dart';
import 'package:spacegom_companion/models/weapon.dart';
import 'package:spacegom_companion/screens/employee_form_screen.dart';
import 'package:spacegom_companion/widgets/digit_counter.dart';
import 'package:spacegom_companion/widgets/employee_list.dart';
import 'package:spacegom_companion/widgets/level_selector.dart';
import 'package:spacegom_companion/widgets/health_tracker.dart';
import 'package:spacegom_companion/widgets/ship_info_card.dart';

class CompanySheetScreen extends StatefulWidget {
  final Company initialCompany;
  final ValueChanged<Company> onChanged;

  const CompanySheetScreen({
    super.key,
    required this.initialCompany,
    required this.onChanged,
  });

  @override
  State<CompanySheetScreen> createState() => _CompanySheetScreenState();
}

class _CompanySheetScreenState extends State<CompanySheetScreen> {
  late String _companyName;
  late List<Ship> _ships;
  late int _activeShipIndex;
  late int _fuel;
  late int _storage;
  late int _reputation;
  late int _lightDamage;
  late int _moderateDamage;
  late int _severeDamage;
  late int _saludMarks;
  late List<Employee> _employees;
  late List<Weapon> _weapons;
  late Map<String, int> _lifeSupportEquipment;

  Ship get _activeShip => _ships[_activeShipIndex];

  @override
  void initState() {
    super.initState();

    final c = widget.initialCompany;
    _companyName = c.companyName;
    _ships = List.from(c.ships);
    _activeShipIndex = c.activeShipIndex;
    _fuel = c.fuel;
    _storage = c.storage;
    _reputation = c.reputation;
    _lightDamage = c.lightDamage;
    _moderateDamage = c.moderateDamage;
    _severeDamage = c.severeDamage;
    _saludMarks = c.saludMarks;
    _employees = List.from(c.employees);
    _weapons = List.from(c.weapons);
    _lifeSupportEquipment = Map.from(c.lifeSupportEquipment);
  }

  Company _buildCompany() {
    return Company(
      companyName: _companyName,
      ships: List.from(_ships),
      activeShipIndex: _activeShipIndex,
      fuel: _fuel,
      storage: _storage,
      reputation: _reputation,
      lightDamage: _lightDamage,
      moderateDamage: _moderateDamage,
      severeDamage: _severeDamage,
      saludMarks: _saludMarks,
      employees: List.from(_employees),
      weapons: List.from(_weapons),
      lifeSupportEquipment: Map.from(_lifeSupportEquipment),
    );
  }

  void _notifyChanged() => widget.onChanged(_buildCompany());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildShipInfo(),

          const SizedBox(height: 16),

          _buildReputation(),

          const SizedBox(height: 16),

          _buildResources(),

          const SizedBox(height: 16),

          _buildDamageSupport(),

          const SizedBox(height: 16),

          _buildDamage(),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: HealthTracker(
                marks: _saludMarks,
                onChanged: (v) => setState(() { _saludMarks = v; _notifyChanged(); }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildStaff(),

          const SizedBox(height: 16),

          _buildWeapons(),

          const SizedBox(height: 16),

          _buildLifeSupport(),
        ],
      ),
    );
  }

  Widget _buildShipInfo() {
    return ShipInfoCard(
      key: ValueKey('ship_$_activeShipIndex'),
      companyName: _companyName,
      ship: _activeShip,
      shipCount: _ships.length,
      activeIndex: _activeShipIndex,
      onCompanyNameChanged: (v) => setState(() { _companyName = v; _notifyChanged(); }),
      onShipChanged: (ship) => setState(() { _ships[_activeShipIndex] = ship; _notifyChanged(); }),
      onAddShip: _addShip,
      onSwitchShip: _ships.length > 1 ? _switchShip : null,
    );
  }

  void _addShip() {
    setState(() {
      _ships.add(const Ship());
      _activeShipIndex = _ships.length - 1;
      _notifyChanged();
    });
  }

  void _switchShip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Astronaves'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _ships.length; i++)
              ListTile(
                leading: i == _activeShipIndex
                    ? const Icon(Icons.rocket_launch, size: 20, color: Color(0xFF2EA043))
                    : const Icon(Icons.rocket_launch_outlined, size: 20, color: Color(0xFF8B949E)),
                title: Text(
                  _ships[i].model.isEmpty ? 'Nave ${i + 1} (sin nombre)' : _ships[i].model,
                  style: TextStyle(
                    fontWeight: i == _activeShipIndex ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'Hipersalto: ${_ships[i].hyperjumpCapacity}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                ),
                onTap: () {
                  setState(() { _activeShipIndex = i; _notifyChanged(); });
                  Navigator.pop(ctx);
                },
                trailing: _ships.length > 1
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDA3633)),
                        onPressed: () {
                          setState(() {
                            _ships.removeAt(i);

                            if (_activeShipIndex >= _ships.length) {
                              _activeShipIndex = _ships.length - 1;
                            }

                            _notifyChanged();
                          });
                          Navigator.pop(ctx);
                        },
                      )
                    : null,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildReputation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LevelSelector(
          label: 'REPUTACIÓN',
          values: List.generate(11, (i) => i - 5),
          selectedValue: _reputation,
          onChanged: (v) => setState(() { _reputation = v; _notifyChanged(); }),
        ),
      ),
    );
  }

  Widget _buildResources() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DigitCounter(
                label: 'COMBUSTIBLE',
                value: _fuel,
                digitCount: 2,
                onChanged: (v) => setState(() { _fuel = v; _notifyChanged(); }),
              ),
            ),
          ),
        ),

        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DigitCounter(
                label: 'ALMACÉN',
                value: _storage,
                digitCount: 3,
                onChanged: (v) => setState(() { _storage = v; _notifyChanged(); }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateActiveShip(Ship updated) {
    setState(() {
      _ships[_activeShipIndex] = updated;
      _notifyChanged();
    });
  }

  Widget _buildDamageSupport() {
    final ship = _activeShip;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LevelSelector(
              label: 'SOPORTE LEVES',
              values: List.generate(6, (i) => i),
              selectedValue: ship.lightSupport,
              onChanged: (v) => _updateActiveShip(ship.copyWith(lightSupport: v)),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LevelSelector(
              label: 'SOPORTE MODERADOS',
              values: List.generate(6, (i) => i),
              selectedValue: ship.moderateSupport,
              onChanged: (v) => _updateActiveShip(ship.copyWith(moderateSupport: v)),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LevelSelector(
              label: 'SOPORTE GRAVES',
              values: List.generate(6, (i) => i),
              selectedValue: ship.severeSupport,
              onChanged: (v) => _updateActiveShip(ship.copyWith(severeSupport: v)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDamage() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LevelSelector(
              label: 'DAÑOS LEVES',
              values: List.generate(6, (i) => i),
              selectedValue: _lightDamage,
              onChanged: (v) => setState(() { _lightDamage = v; _notifyChanged(); }),
              colorResolver: LevelSelector.damageColor,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LevelSelector(
              label: 'DAÑOS MODERADOS',
              values: List.generate(6, (i) => i),
              selectedValue: _moderateDamage,
              onChanged: (v) => setState(() { _moderateDamage = v; _notifyChanged(); }),
              colorResolver: LevelSelector.damageColor,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LevelSelector(
              label: 'DAÑOS GRAVES',
              values: List.generate(6, (i) => i),
              selectedValue: _severeDamage,
              onChanged: (v) => setState(() { _severeDamage = v; _notifyChanged(); }),
              colorResolver: LevelSelector.damageColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaff() {
    final totalSalary = _employees.fold(0, (sum, e) => sum + e.salary);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'PLANTILLA (${_employees.length}/50) — $totalSalary SC/mes',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),

            IconButton(
              onPressed: _employees.length < 50 ? _addEmployee : null,
              icon: const Icon(Icons.person_add),
              iconSize: 20,
            ),
          ],
        ),

        EmployeeList(
          employees: _employees,
          onEdit: _editEmployee,
          onDelete: _deleteEmployee,
        ),
      ],
    );
  }

  Future<void> _addEmployee() async {
    final nextId = _employees.isEmpty ? 1 : _employees.last.id + 1;

    final result = await Navigator.push<Employee>(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormScreen(employeeId: nextId),
      ),
    );

    if (result != null) {
      setState(() {
        _employees.add(result);
        _notifyChanged();
      });
    }
  }

  Future<void> _editEmployee(Employee employee) async {
    final result = await Navigator.push<Employee>(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormScreen(
          employeeId: employee.id,
          employee: employee,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _employees.indexWhere((e) => e.id == result.id);

        if (index >= 0) {
          _employees[index] = result;
        }

        _notifyChanged();
      });
    }
  }

  void _deleteEmployee(int employeeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text('¿Eliminar empleado #$employeeId de la plantilla?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _employees.removeWhere((e) => e.id == employeeId);
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }

  String _employeeName(int id) {
    final employee = _employees.where((e) => e.id == id).firstOrNull;

    if (employee == null) return '#$id';
    if (employee.name.isNotEmpty) return employee.name;
    if (employee.role.isNotEmpty) return employee.role;

    return '#$id';
  }

  Widget _buildWeapons() {
    final totalMaintenance = _weapons.fold(0, (sum, w) {
      final type = w.weaponType;

      return sum + (type?.maintenance ?? 0);
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ARMAS (${_weapons.length}) — $totalMaintenance SC/mes mant.',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),

            IconButton(
              onPressed: _addWeapon,
              icon: const Icon(Icons.add),
              iconSize: 20,
            ),
          ],
        ),

        if (_weapons.isEmpty)
          const Text('Sin armas', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),

        for (var i = 0; i < _weapons.length; i++)
          _buildWeaponCard(i, _weapons[i]),
      ],
    );
  }

  Widget _buildWeaponCard(int index, Weapon weapon) {
    final type = weapon.weaponType;
    final effect = type?.effect ?? 0;
    final effectColor = effect >= 0 ? const Color(0xFF2EA043) : const Color(0xFFDA3633);
    final prefix = effect >= 0 ? '+' : '';

    return GestureDetector(
      onLongPress: () => _deleteWeapon(index),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _employeeName(weapon.employeeId),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  weapon.weaponName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),

              Text(
                '$prefix$effect',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: effectColor),
              ),

              if (type != null && type.maintenance > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '${type.maintenance} SC',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF8B949E)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _addWeapon() {
    int? selectedEmployeeId;
    String selectedWeaponName = WeaponReference.weapons.first.weaponName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Añadir arma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedEmployeeId,
                isExpanded: true,
                hint: const Text('Empleado'),
                items: _employees.map((e) => DropdownMenuItem(
                  value: e.id,
                  child: Text('${e.id} - ${e.name.isEmpty ? e.role : e.name}'),
                )).toList(),
                onChanged: (v) => setDialogState(() => selectedEmployeeId = v),
              ),

              const SizedBox(height: 8),

              DropdownButton<String>(
                value: selectedWeaponName,
                isExpanded: true,
                items: WeaponReference.weapons.map((w) => DropdownMenuItem(
                  value: w.weaponName,
                  child: Text('${w.weaponName} (${w.effect >= 0 ? '+' : ''}${w.effect}) ${w.cost} SC', style: const TextStyle(fontSize: 13)),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedWeaponName = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: selectedEmployeeId != null ? () {
                setState(() {
                  _weapons.add(Weapon(employeeId: selectedEmployeeId!, weaponName: selectedWeaponName));
                  _notifyChanged();
                });
                Navigator.pop(ctx);
              } : null,
              child: const Text('Añadir'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteWeapon(int index) {
    final weapon = _weapons[index];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar arma'),
        content: Text('¿Eliminar ${weapon.weaponName} del empleado #${weapon.employeeId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _weapons.removeAt(index);
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeSupport() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.air, size: 16, color: Color(0xFF58A6FF)),
              const SizedBox(width: 6),
              const Text(
                'SOPORTE VITAL',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
              ),
            ],
          ),
        ),

        for (final type in LifeSupportReference.equipment)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      type.code,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      type.equipmentName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: (_lifeSupportEquipment[type.code] ?? 0) > 0
                        ? () => setState(() {
                              _lifeSupportEquipment[type.code] =
                                  (_lifeSupportEquipment[type.code] ?? 0) - 1;
                              if (_lifeSupportEquipment[type.code] == 0) {
                                _lifeSupportEquipment.remove(type.code);
                              }
                              _notifyChanged();
                            })
                        : null,
                  ),

                  SizedBox(
                    width: 24,
                    child: Text(
                      '${_lifeSupportEquipment[type.code] ?? 0}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => setState(() {
                      _lifeSupportEquipment[type.code] =
                          (_lifeSupportEquipment[type.code] ?? 0) + 1;
                      _notifyChanged();
                    }),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

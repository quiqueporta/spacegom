import 'dart:math';

import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/weapon.dart';
import 'package:spacegom_companion/screens/employee_form_screen.dart';
import 'package:spacegom_companion/widgets/employee_list.dart';

class CrewScreen extends StatefulWidget {
  final List<Employee> employees;
  final List<Weapon> weapons;
  final void Function(List<Employee>, List<Weapon>) onChanged;
  final ValueChanged<int> onPaySalaries;

  const CrewScreen({
    super.key,
    required this.employees,
    required this.weapons,
    required this.onChanged,
    required this.onPaySalaries,
  });

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> with AutomaticKeepAliveClientMixin {
  late List<Employee> _employees;
  late List<Weapon> _weapons;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _employees = List.from(widget.employees);
    _weapons = List.from(widget.weapons);
  }

  void _reorderEmployees(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;

      final employee = _employees.removeAt(oldIndex);
      _employees.insert(newIndex, employee);
      _notifyChanged();
    });
  }

  void _notifyChanged() {
    widget.onChanged(List.from(_employees), List.from(_weapons));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final employeeList = EmployeeList(
      employees: _employees,
      onEdit: _editEmployee,
      onDelete: _deleteEmployee,
      onReorder: _reorderEmployees,
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverToBoxAdapter(child: _buildStaffHeader()),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: employeeList.buildSliver(),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          sliver: SliverToBoxAdapter(child: _buildWeapons()),
        ),
      ],
    );
  }

  Widget _buildStaffHeader() {
    final totalSalary = _employees.fold(0, (sum, e) => sum + e.salary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'PLANTILLA (${_employees.length}/50) — $totalSalary SC/mes',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),

        IconButton(
          onPressed: _employees.isNotEmpty ? _paySalaries : null,
          icon: const Icon(Icons.payments),
          iconSize: 20,
        ),

        IconButton(
          onPressed: _employees.length < 50 ? _addEmployee : null,
          icon: const Icon(Icons.person_add),
          iconSize: 20,
        ),
      ],
    );
  }

  void _paySalaries() {
    final total = _employees
        .where((e) => !e.dismissed)
        .fold(0, (sum, e) => sum + e.salary);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pagar salarios'),
        content: Text('Se descontarán $total SC de la tesorería.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.onPaySalaries(total);
              Navigator.pop(ctx);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addEmployee() async {
    final nextId = _employees.isEmpty
        ? 1
        : _employees.map((e) => e.id).reduce(max) + 1;

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
}

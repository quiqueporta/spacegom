import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/name_database.dart';

class EmployeeFormScreen extends StatefulWidget {
  final int employeeId;
  final Employee? employee;

  const EmployeeFormScreen({
    super.key,
    required this.employeeId,
    this.employee,
  });

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _salaryController;
  late String? _role;
  late ExperienceLevel _experience;
  late MoraleLevel _morale;
  late int _moralChecks;
  late bool _dismissed;

  @override
  void initState() {
    super.initState();

    final e = widget.employee;
    _nameController = TextEditingController(text: e?.name ?? '');
    _salaryController = TextEditingController(text: e != null && e.salary > 0 ? '${e.salary}' : '');
    _role = e != null && e.role.isNotEmpty ? e.role : null;
    _experience = e?.experience ?? ExperienceLevel.beginner;
    _morale = e?.morale ?? MoraleLevel.medium;
    _moralChecks = e?.moralChecks ?? 0;
    _dismissed = e?.dismissed ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empleado #${widget.employeeId}'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.casino_outlined, size: 20),
                  onPressed: () {
                    _nameController.text = NameDatabase.randomPersonalName();
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButton<String>(
              value: _role,
              isExpanded: true,
              hint: const Text('Puesto'),
              items: Employee.roles.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p, style: const TextStyle(fontSize: 14)),
              )).toList(),
              onChanged: (v) => setState(() => _role = v),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Salario (SC)'),
            ),

            const SizedBox(height: 20),

            _buildExperienceSelector(),

            const SizedBox(height: 20),

            _buildMoraleSelector(),

            const SizedBox(height: 12),

            _buildMoraleChecks(),

            const SizedBox(height: 20),

            _buildDismissedSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSelector() {
    final minLevel = widget.employee?.experience ?? ExperienceLevel.beginner;
    final minIndex = ExperienceLevel.values.indexOf(minLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPERIENCIA',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
        ),

        const SizedBox(height: 8),

        Row(
          children: ExperienceLevel.values.map((level) {
            final index = ExperienceLevel.values.indexOf(level);
            final isSelected = level == _experience;
            final canSelect = index >= minIndex;

            final (label, color) = switch (level) {
              ExperienceLevel.beginner => ('N', const Color(0xFF8B949E)),
              ExperienceLevel.experienced => ('E', const Color(0xFF58A6FF)),
              ExperienceLevel.veteran => ('V', const Color(0xFF2EA043)),
            };

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: canSelect ? () => setState(() => _experience = level) : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : canSelect ? const Color(0xFF30363D) : const Color(0xFF1C2333),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canSelect ? color : const Color(0xFF30363D),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoraleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MORAL',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
        ),

        const SizedBox(height: 8),

        Row(
          children: MoraleLevel.values.map((level) {
            final isSelected = level == _morale;

            final (label, color) = switch (level) {
              MoraleLevel.low => ('B', const Color(0xFFDA3633)),
              MoraleLevel.medium => ('M', const Color(0xFFE8B830)),
              MoraleLevel.high => ('A', const Color(0xFF2EA043)),
            };

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _morale = level),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFF30363D),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : const Color(0xFF8B949E),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoraleChecks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CASILLAS MORAL ($_moralChecks/${Employee.maxMoralChecks})',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
        ),

        const SizedBox(height: 4),

        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: List.generate(Employee.maxMoralChecks, (i) {
            return SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: i < _moralChecks,
                onChanged: (checked) {
                  setState(() {
                    _moralChecks = checked == true ? i + 1 : i;
                  });
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDismissedSwitch() {
    return Row(
      children: [
        const Text(
          'ADIÓS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
        ),

        const Spacer(),

        Switch(
          value: _dismissed,
          onChanged: (v) => setState(() => _dismissed = v),
        ),
      ],
    );
  }

  void _save() {
    final employee = Employee(
      id: widget.employeeId,
      name: _nameController.text,
      role: _role ?? '',
      salary: int.tryParse(_salaryController.text) ?? 0,
      experience: _experience,
      morale: _morale,
      moralChecks: _moralChecks,
      dismissed: _dismissed,
    );

    Navigator.pop(context, employee);
  }
}

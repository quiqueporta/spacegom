import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/employee.dart';

class EmployeeList extends StatelessWidget {
  final List<Employee> employees;
  final ValueChanged<Employee> onEdit;
  final ValueChanged<int> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  const EmployeeList({
    super.key,
    required this.employees,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const Center(
        child: Text(
          'Sin empleados',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      onReorder: onReorder,
      buildDefaultDragHandles: false,
      proxyDecorator: _proxyDecorator,
      itemBuilder: (context, index) => _buildEmployeeCard(index, employees[index]),
    );
  }

  Widget buildSliver() {
    if (employees.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'Sin empleados',
            style: const TextStyle(color: Color(0xFF8B949E)),
          ),
        ),
      );
    }

    return SliverReorderableList(
      itemCount: employees.length,
      onReorder: onReorder,
      proxyDecorator: _proxyDecorator,
      itemBuilder: (context, index) => _buildEmployeeCard(index, employees[index]),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Material(
        elevation: 8,
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
      child: child,
    );
  }

  Widget _buildEmployeeCard(int index, Employee employee) {
    final isGone = employee.dismissed;

    return Card(
      key: ValueKey(employee.id),
      color: isGone ? const Color(0xFF1C2333).withValues(alpha: 0.5) : null,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReorderableDelayedDragStartListener(
              index: index,
              child: Container(
                width: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF1C2333),
                  border: Border(right: BorderSide(color: Color(0xFF30363D), width: 0.5)),
                ),
                child: const Icon(Icons.drag_handle, size: 20, color: Color(0xFF8B949E)),
              ),
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onEdit(employee),
                onLongPress: () => onDelete(employee.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                      width: 24,
                      child: Text(
                        '${employee.id}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.role.isEmpty ? '—' : employee.role,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              decoration: isGone ? TextDecoration.lineThrough : null,
                            ),
                          ),

                          Text(
                            employee.name.isEmpty ? '—' : employee.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF8B949E),
                              decoration: isGone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 36,
                      child: Text(
                        '${employee.salary} SC',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(width: 4),

                    _buildExperienceBadge(employee.experience),

                    const SizedBox(width: 4),

                    _buildMoraleBadge(employee.morale),

                    const SizedBox(width: 4),

                    _buildMoraleChecks(employee.moralChecks),

                    const SizedBox(width: 4),

                    _buildRollModifier(employee.rollModifier),

                    if (isGone) ...[
                      const SizedBox(width: 4),
                      const Text(
                        'ADIÓS',
                        style: TextStyle(fontSize: 9, color: Color(0xFFDA3633), fontWeight: FontWeight.bold),
                      ),
                    ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceBadge(ExperienceLevel level) {
    final (label, color) = switch (level) {
      ExperienceLevel.beginner => ('N', const Color(0xFF8B949E)),
      ExperienceLevel.experienced => ('E', const Color(0xFF58A6FF)),
      ExperienceLevel.veteran => ('V', const Color(0xFF2EA043)),
    };

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMoraleBadge(MoraleLevel level) {
    final (label, color) = switch (level) {
      MoraleLevel.low => ('B', const Color(0xFFDA3633)),
      MoraleLevel.medium => ('M', const Color(0xFFE8B830)),
      MoraleLevel.high => ('A', const Color(0xFF2EA043)),
    };

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRollModifier(int modifier) {
    final label = modifier > 0 ? '+$modifier' : '$modifier';
    final color = switch (modifier) {
      > 0 => const Color(0xFF2EA043),
      < 0 => const Color(0xFFDA3633),
      _ => const Color(0xFF8B949E),
    };

    return SizedBox(
      width: 22,
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMoraleChecks(int checks) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$checks/${Employee.maxMoralChecks}',
          style: const TextStyle(fontSize: 9, color: Color(0xFF8B949E)),
        ),
      ],
    );
  }
}

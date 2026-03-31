import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/widgets/employee_list.dart';

Widget buildTestable({
  List<Employee> employees = const [],
  void Function(Employee)? onEdit,
  void Function(int)? onDelete,
}) {
  return MaterialApp(
    home: Scaffold(
      body: EmployeeList(
        employees: employees,
        onEdit: onEdit ?? (_) {},
        onDelete: onDelete ?? (_) {},
      ),
    ),
  );
}

void main() {
  group('EmployeeList', () {
    testWidgets('muestra mensaje cuando no hay empleados', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Sin empleados'), findsOneWidget);
    });

    testWidgets('muestra los datos de cada empleado', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Ana', role: 'Piloto', salary: 5),
          Employee(id: 2, name: 'Luis', role: 'Ingeniero', salary: 3),
        ],
      ));

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Piloto'), findsOneWidget);
      expect(find.text('Luis'), findsOneWidget);
      expect(find.text('Ingeniero'), findsOneWidget);
    });

    testWidgets('muestra el rol en grande y el nombre debajo', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Ana', role: 'Piloto', salary: 5),
        ],
      ));

      final roleText = tester.widget<Text>(find.text('Piloto'));
      final nameText = tester.widget<Text>(find.text('Ana'));

      expect(roleText.style!.fontWeight, FontWeight.bold);
      expect(roleText.style!.fontSize, 13);
      expect(nameText.style!.fontSize, 11);
      expect(nameText.style!.color, const Color(0xFF8B949E));
    });

    testWidgets('muestra la experiencia del empleado', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Ana', experience: ExperienceLevel.veteran),
        ],
      ));

      expect(find.text('V'), findsOneWidget);
    });

    testWidgets('muestra la moral del empleado', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Ana', morale: MoraleLevel.high),
        ],
      ));

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('marca empleado con adiós visualmente', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Despedido', dismissed: true),
        ],
      ));

      expect(find.text('Despedido'), findsOneWidget);
      expect(find.text('ADIÓS'), findsOneWidget);
    });
  });
}

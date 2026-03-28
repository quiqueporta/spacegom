import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/screens/employee_form_screen.dart';

void main() {
  group('EmployeeFormScreen', () {
    testWidgets('muestra formulario para nuevo empleado', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(employeeId: 1),
      ));

      expect(find.text('Empleado #1'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('carga datos de empleado existente', (tester) async {
      final employee = Employee(
        id: 3,
        name: 'Ana',
        role: 'Piloto',
        salary: 5,
        experience: ExperienceLevel.experienced,
      );

      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(employeeId: 3, employee: employee),
      ));

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Piloto'), findsOneWidget);
    });

    testWidgets('devuelve empleado al guardar', (tester) async {
      Employee? result;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.push<Employee>(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeFormScreen(
                    employeeId: 1,
                    employee: Employee(id: 1, role: 'Piloto'),
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Nuevo');
      await tester.enterText(find.byType(TextField).at(1), '7');

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.name, 'Nuevo');
      expect(result!.role, 'Piloto');
      expect(result!.salary, 7);
    });

    testWidgets('muestra casillas de moral marcables', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(
          employeeId: 1,
          employee: Employee(id: 1, moralChecks: 3),
        ),
      ));

      expect(find.byType(Checkbox), findsNWidgets(Employee.maxMoralChecks));
    });

    testWidgets('experiencia solo permite subir de nivel', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(
          employeeId: 1,
          employee: Employee(id: 1, experience: ExperienceLevel.beginner),
        ),
      ));

      expect(find.text('N'), findsWidgets);
      expect(find.text('E'), findsWidgets);
      expect(find.text('V'), findsWidgets);
    });

    testWidgets('muestra desplegable de puestos', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(employeeId: 1),
      ));

      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('carga puesto existente en desplegable', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(
          employeeId: 1,
          employee: Employee(id: 1, role: 'Piloto'),
        ),
      ));

      expect(find.text('Piloto'), findsOneWidget);
    });

    testWidgets('muestra botón de nombre aleatorio', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(employeeId: 1),
      ));

      expect(find.byIcon(Icons.casino_outlined), findsOneWidget);
    });

    testWidgets('al pulsar el dado se rellena el nombre', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EmployeeFormScreen(employeeId: 1),
      ));

      final nameField = find.byType(TextField).first;
      expect(tester.widget<TextField>(nameField).controller!.text, isEmpty);

      await tester.tap(find.byIcon(Icons.casino_outlined));
      await tester.pump();

      expect(tester.widget<TextField>(nameField).controller!.text, isNotEmpty);
    });
  });
}

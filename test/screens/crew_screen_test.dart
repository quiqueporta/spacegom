import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/weapon.dart';
import 'package:spacegom_companion/screens/crew_screen.dart';

Widget buildTestable({
  List<Employee> employees = const [],
  List<Weapon> weapons = const [],
  void Function(List<Employee>, List<Weapon>)? onChanged,
  void Function(int)? onPaySalaries,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CrewScreen(
        employees: employees,
        weapons: weapons,
        onChanged: onChanged ?? (_, __) {},
        onPaySalaries: onPaySalaries ?? (_) {},
      ),
    ),
  );
}

void main() {
  group('CrewScreen', () {
    testWidgets('muestra la sección de plantilla', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.textContaining('PLANTILLA'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('muestra la sección de armas', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.textContaining('ARMAS'), findsOneWidget);
    });

    testWidgets('muestra empleados existentes', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Ana', role: 'Piloto'),
        ],
      ));

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Piloto'), findsOneWidget);
    });

    testWidgets('muestra coste total de la plantilla', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Ana', salary: 5),
          Employee(id: 2, name: 'Luis', salary: 3),
        ],
      ));

      expect(find.textContaining('8 SC'), findsOneWidget);
    });

    testWidgets('muestra botón de pagar salarios', (tester) async {
      await tester.pumpWidget(buildTestable(
        employees: [Employee(id: 1, name: 'Ana', salary: 5)],
      ));

      expect(find.byIcon(Icons.payments), findsOneWidget);
    });

    testWidgets('pagar salarios llama al callback con el total', (tester) async {
      int? paidAmount;

      await tester.pumpWidget(buildTestable(
        employees: [
          Employee(id: 1, name: 'Ana', salary: 5),
          Employee(id: 2, name: 'Luis', salary: 3),
        ],
        onPaySalaries: (amount) => paidAmount = amount,
      ));

      await tester.tap(find.byIcon(Icons.payments));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aceptar'));
      await tester.pump();

      expect(paidAmount, 8);
    });
  });
}

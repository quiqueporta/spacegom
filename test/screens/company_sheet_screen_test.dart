import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/screens/company_sheet_screen.dart';

Widget buildTestable({Company? initialCompany}) {
  return MaterialApp(
    home: Scaffold(
      body: CompanySheetScreen(
        initialCompany: initialCompany ?? Company(),
        onChanged: (_) {},
      ),
    ),
  );
}

void main() {
  group('CompanySheetScreen', () {
    testWidgets('muestra las secciones de recursos', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('COMBUSTIBLE'), findsOneWidget);
      expect(find.text('ALMACÉN'), findsOneWidget);
    });

    testWidgets('muestra la sección de reputación', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('REPUTACIÓN'), findsOneWidget);
    });

    testWidgets('muestra las secciones de daños', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('DAÑOS LEVES'), findsOneWidget);
      expect(find.text('DAÑOS MODERADOS'), findsOneWidget);
      expect(find.text('DAÑOS GRAVES'), findsOneWidget);
    });

    testWidgets('incrementar combustible actualiza el valor', (tester) async {
      await tester.pumpWidget(buildTestable());

      final plusButtons = find.descendant(
        of: find.ancestor(
          of: find.text('COMBUSTIBLE'),
          matching: find.byType(Column),
        ).first,
        matching: find.byIcon(Icons.add),
      );

      await tester.tap(plusButtons.first);
      await tester.pump();

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('carga estado inicial proporcionado', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialCompany: Company(fuel: 42),
      ));

      expect(find.text('4'), findsWidgets);
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('notifica cambios al callback', (tester) async {
      Company? lastCompany;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CompanySheetScreen(
            initialCompany: Company(),
            onChanged: (company) => lastCompany = company,
          ),
        ),
      ));

      final plusButtons = find.descendant(
        of: find.ancestor(
          of: find.text('COMBUSTIBLE'),
          matching: find.byType(Column),
        ).first,
        matching: find.byIcon(Icons.add),
      );
      await tester.tap(plusButtons.last);
      await tester.pump();

      expect(lastCompany, isNotNull);
      expect(lastCompany!.fuel, 1);
    });

    testWidgets('muestra la sección PLANTILLA con botón añadir', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.textContaining('PLANTILLA'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('muestra coste total de la plantilla', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialCompany: Company(
          employees: [
            Employee(id: 1, name: 'Ana', salary: 5),
            Employee(id: 2, name: 'Luis', salary: 3),
          ],
        ),
      ));

      expect(find.textContaining('8 SC'), findsOneWidget);
    });

    testWidgets('muestra empleados existentes', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialCompany: Company(
          employees: [
            Employee(id: 1, name: 'Ana', role: 'Piloto'),
          ],
        ),
      ));

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Piloto'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/ship.dart';
import 'package:spacegom_companion/models/treasury.dart';
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

    testWidgets('muestra la sección unificada de daños', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('DAÑOS'), findsOneWidget);
      expect(find.text('LEVES'), findsOneWidget);
      expect(find.text('MODERADOS'), findsOneWidget);
      expect(find.text('GRAVES'), findsOneWidget);
    });

    testWidgets('muestra indicador de exceso cuando daño supera soporte', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialCompany: Company(
          ships: [Ship(lightSupport: 2)],
          lightDamage: 3,
        ),
      ));

      expect(find.text('3/2'), findsOneWidget);
    });

    testWidgets('muestra indicador normal cuando daño no supera soporte', (tester) async {
      await tester.pumpWidget(buildTestable(
        initialCompany: Company(
          ships: [Ship(lightSupport: 3)],
          lightDamage: 1,
        ),
      ));

      expect(find.text('1/3'), findsOneWidget);
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

    testWidgets('preserva la tesorería al notificar cambios', (tester) async {
      Company? lastCompany;
      final treasury = Treasury(
        transactions: [Transaction(concept: 'Sueldo', amount: -100)],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CompanySheetScreen(
            initialCompany: Company(treasury: treasury),
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
      expect(lastCompany!.treasury.transactions.length, 1);
      expect(lastCompany!.treasury.transactions.first.concept, 'Sueldo');
    });

    testWidgets('no muestra sección de plantilla ni armas', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.textContaining('PLANTILLA'), findsNothing);
      expect(find.textContaining('ARMAS'), findsNothing);
    });
  });
}

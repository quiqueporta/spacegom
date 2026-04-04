import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacegom_companion/models/ship.dart';
import 'package:spacegom_companion/widgets/ship_info_card.dart';

Widget buildTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('ShipInfoCard', () {
    testWidgets('muestra todos los campos de la astronave', (tester) async {
      await tester.pumpWidget(buildTestable(
        ShipInfoCard(
          companyName: '',
          ship: const Ship(),
          onCompanyNameChanged: (_) {},
          onShipChanged: (_) {},
        ),
      ));

      expect(find.text('COMPAÑÍA'), findsOneWidget);
      expect(find.textContaining('NOMBRE NAVE'), findsOneWidget);
      expect(find.text('MODELO'), findsOneWidget);
      expect(find.text('HIPERSALTO'), findsOneWidget);
      expect(find.text('MOD. TIRADAS'), findsOneWidget);
      expect(find.text('PASAJEROS'), findsOneWidget);
      expect(find.text('ALMACÉN MÁX.'), findsOneWidget);
    });

    testWidgets('muestra los valores iniciales', (tester) async {
      await tester.pumpWidget(buildTestable(
        ShipInfoCard(
          companyName: 'Mi Empresa',
          ship: Ship(model: 'Clase B', hyperjumpCapacity: 3),
          onCompanyNameChanged: (_) {},
          onShipChanged: (_) {},
        ),
      ));

      expect(find.text('Mi Empresa'), findsOneWidget);
      expect(find.text('Clase B'), findsOneWidget);
    });

    testWidgets('muestra botón añadir nave', (tester) async {
      await tester.pumpWidget(buildTestable(
        ShipInfoCard(
          companyName: '',
          ship: const Ship(),
          onCompanyNameChanged: (_) {},
          onShipChanged: (_) {},
          onAddShip: () {},
        ),
      ));

      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('muestra botón cambiar nave cuando hay más de una', (tester) async {
      await tester.pumpWidget(buildTestable(
        ShipInfoCard(
          companyName: '',
          ship: const Ship(),
          shipCount: 2,
          onCompanyNameChanged: (_) {},
          onShipChanged: (_) {},
          onSwitchShip: () {},
        ),
      ));

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('muestra botón de megacorp aleatoria', (tester) async {
      await tester.pumpWidget(buildTestable(
        ShipInfoCard(
          companyName: '',
          ship: const Ship(),
          onCompanyNameChanged: (_) {},
          onShipChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.casino_outlined), findsOneWidget);
    });

    testWidgets('al pulsar el dado de megacorp se notifica un nombre', (tester) async {
      String? receivedName;

      await tester.pumpWidget(buildTestable(
        ShipInfoCard(
          companyName: '',
          ship: const Ship(),
          onCompanyNameChanged: (name) => receivedName = name,
          onShipChanged: (_) {},
        ),
      ));

      await tester.tap(find.byIcon(Icons.casino_outlined));
      await tester.pump();

      expect(receivedName, isNotNull);
      expect(receivedName, isNotEmpty);
    });
  });
}

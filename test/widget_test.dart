import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spacegom_companion/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('la app usa tema oscuro', (tester) async {
    await tester.pumpWidget(SpacegomApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('la app muestra el logo en el AppBar', (tester) async {
    await tester.pumpWidget(SpacegomApp());

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('la app tiene navegación por tabs', (tester) async {
    await tester.pumpWidget(SpacegomApp());

    expect(find.text('Tablero'), findsOneWidget);
    expect(find.text('Compañía'), findsOneWidget);
  });
}

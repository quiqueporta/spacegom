import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spacegom_companion/screens/home_screen.dart';

Widget buildTestable() {
  return MaterialApp(
    home: HomeScreen(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('navegación por swipe', () {
    testWidgets('deslizar a la izquierda cambia a la siguiente pestaña', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Tablero'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, 1);
    });

    testWidgets('deslizar a la derecha vuelve a la pestaña anterior', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(300, 0), 1000);
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, 0);
    });
  });

  group('menú de datos', () {
    testWidgets('muestra el botón de menú en el AppBar', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('al pulsar el menú muestra opciones de exportar e importar', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Exportar datos'), findsOneWidget);
      expect(find.text('Importar datos'), findsOneWidget);
    });

    testWidgets('exportar muestra los iconos correctos', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.upload_outlined), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    });

    testWidgets('muestra opción de resetear datos', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Resetear datos'), findsOneWidget);
      expect(find.byIcon(Icons.restore_outlined), findsOneWidget);
    });

    testWidgets('resetear muestra diálogo de confirmación', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resetear datos'));
      await tester.pumpAndSettle();

      expect(find.text('¿Resetear todos los datos?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Resetear'), findsOneWidget);
    });
  });
}

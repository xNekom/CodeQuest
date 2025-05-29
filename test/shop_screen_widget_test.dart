import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:codequest/screens/shop_screen.dart';

void main() {
  group('ShopScreen Widget Tests', () {
    testWidgets('ShopScreen displays correctly with loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShopScreen(),
        ),
      );

      // Verificar que la pantalla de tienda se muestra
      expect(find.text('TIENDA'), findsOneWidget);
      
      // Verificar que muestra el estado de carga inicialmente
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ShopScreen shows error state when items fail to load', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShopScreen(),
        ),
      );

      // Simular error en la carga
      await tester.pump(Duration(seconds: 2));

      // Buscar indicadores de error
      expect(find.textContaining('Error'), findsWidgets);
    });

    testWidgets('ShopScreen filter dropdown works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShopScreen(),
        ),
      );

      // Esperar a que cargue
      await tester.pump(Duration(seconds: 1));

      // Buscar el dropdown de filtros
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('ShopScreen pagination controls are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShopScreen(),
        ),
      );

      // Esperar a que cargue
      await tester.pump(Duration(seconds: 1));

      // Buscar controles de paginación
      expect(find.text('Anterior'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
    });
  });
}

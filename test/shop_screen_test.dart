import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codequest/screens/shop_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:codequest/firebase_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase for ShopScreen tests
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  setUp(() {
    // Nota: Este test necesitaría ser actualizado para usar mocks de Firestore
    // en lugar del asset bundle. Por ahora, mantenemos la funcionalidad básica
    // pero comentamos el mock del asset bundle ya que ItemService ahora usa Firestore
    
    // TODO: Implementar mock de Firestore para ItemService
    // Este test necesita ser actualizado para funcionar con la nueva implementación
    final codec = StandardMethodCodec();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        final call = codec.decodeMethodCall(message);
        // Return empty JSON for JSON reads (e.g., AssetManifest)
        if (call.method == 'loadString' && call.arguments.toString().endsWith('.json')) {
          return codec.encodeSuccessEnvelope('{}');
        }
        // Return empty bytes for binary asset loads (e.g., images)
        if (call.method == 'load' || call.method == 'loadBuffer') {
          return codec.encodeSuccessEnvelope(Uint8List(0).buffer.asByteData());
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('ShopScreen shows items >0 and paginates and filters by type',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ShopScreen()));
    await tester.pumpAndSettle();

    // Should display 10 items on first page
    expect(find.byType(ListTile), findsNWidgets(10));

    // Item 0 has price 0, so should not appear
    expect(find.text('Item 0'), findsNothing);

    // Check page indicator
    expect(find.text('Página 1/2'), findsOneWidget);

    // Navigate to next page
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Página 2/2'), findsOneWidget);

    // Filter by type 'weapon'
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weapon').last);
    await tester.pumpAndSettle();

    // Now only items with type weapon and price>0 should appear
    final weapons = List.generate(5, (i) => 'Item ${2 + i * 2}');
    for (var name in weapons) {
      expect(find.text(name), findsWidgets);
    }
  });
}

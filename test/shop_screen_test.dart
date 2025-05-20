import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
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

  // Construct sample JSON with 12 items: 1 item with price 0, 11 items with price 5
  late String sampleJson;

  setUp(() {
    // Build items list
    final items = <Map<String, dynamic>>[];
    items.add({
      'id': 'item0',
      'name': 'Item 0',
      'description': 'Desc',
      'icon': 'icon0.png',
      'type': 'potion',
      'rareza': 'Común',
      'valor_monetario': 0,
      'es_consumible': true
    });
    for (var i = 1; i <= 11; i++) {
      items.add({
        'id': 'item$i',
        'name': 'Item $i',
        'description': 'Desc',
        'icon': 'icon$i.png',
        'type': i % 2 == 0 ? 'potion' : 'weapon',
        'rareza': 'Común',
        'valor_monetario': 5,
        'es_consumible': i % 2 == 0,
      });
    }
    sampleJson = jsonEncode(items);
    final codec = StandardMethodCodec();
    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        final call = codec.decodeMethodCall(message);
        // Return shop items JSON
        if (call.method == 'loadString' && call.arguments == 'assets/data/items_data.json') {
          return codec.encodeSuccessEnvelope(sampleJson);
        }
        // Return empty JSON for other JSON reads (e.g., AssetManifest)
        if (call.method == 'loadString' && (call.arguments.toString().endsWith('.json') || call.method == 'loadString')) {
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
    ServicesBinding.instance.defaultBinaryMessenger
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

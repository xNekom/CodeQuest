import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codequest/services/item_service.dart';
import 'package:codequest/models/item_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleJson = '''[
    {
      "id": "item_test_1",
      "name": "Test Item 1",
      "description": "Desc1",
      "icon": "icon1.png",
      "type": "potion",
      "rareza": "Común",
      "valor_monetario": 10,
      "es_consumible": true
    },
    {
      "id": "item_test_2",
      "name": "Test Item 2",
      "description": "Desc2",
      "icon": "icon2.png",
      "type": "weapon",
      "rareza": "Raro",
      "valor_monetario": 0
    }
  ]''';

  setUp(() {
    // Mock asset bundle for loadString
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        final methodCall = const StandardMethodCodec().decodeMethodCall(message);
        if (methodCall.method == 'loadString' &&
            methodCall.arguments == 'assets/data/items_data.json') {
          return StandardMethodCodec().encodeSuccessEnvelope(sampleJson);
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
  });

  test('ItemService loads items and parses JSON correctly', () async {
    final service = ItemService();
    final items = await service.getItems();
    expect(items, isA<List<ItemModel>>());
    expect(items.length, 2);

    final first = items.first;    expect(first.itemId, 'item_test_1');
    expect(first.name, 'Test Item 1');
    expect(first.attributes['valor_monetario'], 10);
    expect(first.type, 'material');

    final second = items[1];
    expect(second.itemId, 'item_test_2');
    expect(second.attributes['valor_monetario'], 0);
  });
}

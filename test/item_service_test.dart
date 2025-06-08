import 'package:flutter_test/flutter_test.dart';
import 'package:codequest/services/item_service.dart';
import 'package:codequest/models/item_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ItemService Tests', () {
    test('ItemService can be instantiated', () {
      final itemService = ItemService();
      expect(itemService, isNotNull);
    });

    test('ItemModel can be created with required fields', () {
      final item = ItemModel(
        itemId: 'test_item_1',
        name: 'Test Item',
        description: 'Test Description',
        type: 'potion',
        rarity: 'Común',
        attributes: {
          'valor_monetario': 10,
          'es_consumible': true,
        },
      );
      
      expect(item.itemId, 'test_item_1');
      expect(item.name, 'Test Item');
      expect(item.rarity, 'Común');
      expect(item.attributes['valor_monetario'], 10);
      expect(item.type, 'potion');
    });
  });
}

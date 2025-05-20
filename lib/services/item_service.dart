// filepath: lib/services/item_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/item_model.dart';

/// Servicio para cargar items desde JSON local
class ItemService {
  /// Carga la lista de items desde assets/data/items_data.json
  Future<List<ItemModel>> getItems() async {
    final jsonStr = await rootBundle.loadString('assets/data/items_data.json');
    final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
    return jsonList.map((data) {
      final map = data as Map<String, dynamic>;
      final id = map['id'] as String;
      return ItemModel.fromJson(map, id);
    }).toList();
  }
}

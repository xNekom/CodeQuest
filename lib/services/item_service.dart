// filepath: lib/services/item_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

/// Servicio para cargar items desde Firestore
class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Carga la lista de items desde Firestore
  Future<List<ItemModel>> getItems() async {
    final QuerySnapshot snapshot = await _firestore.collection('items').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ItemModel.fromJson(data, doc.id);
    }).toList();
  }
}

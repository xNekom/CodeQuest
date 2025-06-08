import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/enemy_model.dart';

class EnemyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<EnemyModel?> getEnemyById(String enemyId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('enemies').doc(enemyId).get();
      if (doc.exists) {
        return EnemyModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
    }
    return null;
  }

  Future<List<EnemyModel>> getEnemiesByIds(List<String> enemyIds) async {
    List<EnemyModel> enemies = [];
    try {
      for (String id in enemyIds) {
        DocumentSnapshot doc = await _firestore.collection('enemies').doc(id).get();
        if (doc.exists) {
          enemies.add(EnemyModel.fromJson(doc.data() as Map<String, dynamic>, doc.id));
        }
      }
    } catch (e) {
    }
    return enemies;
  }

  Future<List<EnemyModel>> getAllEnemies() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('enemies').get();
      return snapshot.docs.map((doc) =>
        EnemyModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
    } catch (e) {
      return [];
    }
  }
}

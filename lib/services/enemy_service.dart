import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/enemy_model.dart';
import 'package:codequest/config/app_config.dart';
import 'package:flutter/foundation.dart' show FlutterError;

class EnemyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<EnemyModel?> getEnemyById(String enemyId) async {
    // [EnemyService] getEnemyById called with ID: "$enemyId"
    if (AppConfig.shouldUseFirebase) {
      try {
        DocumentSnapshot doc = await _firestore.collection('enemies').doc(enemyId).get();
        if (doc.exists) {
          return EnemyModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }
      } catch (e) {
        // Error al obtener enemigo por ID desde Firebase: $e
      }
      return null;
    } else {
      return _getEnemyByIdFromLocalJson(enemyId);
    }
  }

  Future<List<EnemyModel>> getEnemiesByIds(List<String> enemyIds) async {
    if (AppConfig.shouldUseFirebase) {
      List<EnemyModel> enemies = [];
      try {
        for (String id in enemyIds) {
          DocumentSnapshot doc = await _firestore.collection('enemies').doc(id).get();
          if (doc.exists) {
            enemies.add(EnemyModel.fromJson(doc.data() as Map<String, dynamic>, doc.id));
          }
        }
      } catch (e) {
        // Error al obtener enemigos por IDs desde Firebase: $e
      }
      return enemies;
    } else {
      // [EnemyService] Loading enemies locally for IDs: $enemyIds
      List<EnemyModel> enemies = [];
      final allLocalEnemies = await _loadEnemiesFromLocalJson();
      // [EnemyService] Total local enemies available: ${allLocalEnemies.length}
      
      if (allLocalEnemies.isEmpty && enemyIds.isNotEmpty) {
        // [EnemyService] Warning: No local enemies found in enemies_data.json, but IDs were requested: $enemyIds
      }

      for (String id in enemyIds) {
        // [EnemyService] Searching for local enemy with ID: "$id"
        try {
          final foundEnemy = allLocalEnemies.firstWhere(
            (e) => e.enemyId == id,
          );
          enemies.add(foundEnemy);
          // [EnemyService] Found local enemy for ID "$id": ${foundEnemy.name}
        } catch (e) {
          // [EnemyService] Local enemy with ID "$id" NOT FOUND in allLocalEnemies. Error: $e
        }
      }
      // [EnemyService] Returning ${enemies.length} local enemies for requested IDs: $enemyIds
      return enemies;
    }
  }

  Future<List<EnemyModel>> _loadEnemiesFromLocalJson() async {
    try {
      // [EnemyService] Attempting to load enemies from local JSON: assets/data/enemies_data.json
      final String jsonString = await rootBundle.loadString('assets/data/enemies_data.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      List<EnemyModel> enemies = [];
      
      for (var data in jsonList) {
        final jsonData = data as Map<String, dynamic>;
        try {
          // Usar fromLocalJson en lugar de fromJson
          final enemy = EnemyModel.fromLocalJson(jsonData);
          enemies.add(enemy);
          // [EnemyService] Successfully parsed enemy: ${enemy.enemyId} - ${enemy.name}
        } catch (e) {
          // [EnemyService] Error parsing individual enemy: $e
          // [EnemyService] Problematic JSON data: $jsonData
        }
      }
      
      // [EnemyService] Successfully loaded ${enemies.length} enemies from local JSON.
      return enemies;
    } catch (e) {
      // [EnemyService] CRITICAL Error loading or decoding local enemies from assets/data/enemies_data.json: $e
      if (e is FlutterError && e.message.contains('Unable to load asset')) {
        // [EnemyService] Asset loading error - enemies_data.json not found or inaccessible
      }
      return [];
    }
  }

  Future<EnemyModel?> _getEnemyByIdFromLocalJson(String enemyId) async {
    try {
      // [EnemyService] _getEnemyByIdFromLocalJson called with ID: "$enemyId"
      final List<EnemyModel> allEnemies = await _loadEnemiesFromLocalJson();
      // [EnemyService] Available enemy IDs: ${allEnemies.map((e) => e.enemyId).toList()}
      
      final enemy = allEnemies.firstWhere((e) => e.enemyId == enemyId);
      // [EnemyService] Successfully found enemy: ${enemy.name}
      return enemy;
    } catch (e) {
      // Enemigo local con ID $enemyId no encontrado: $e
      // [EnemyService] Available enemies: (commented out to avoid unused variable)
      return null;
    }
  }

  Future<List<EnemyModel>> getAllEnemies() async {
    if (AppConfig.shouldUseFirebase) {
      try {
        QuerySnapshot snapshot = await _firestore.collection('enemies').get();
        return snapshot.docs.map((doc) => 
          EnemyModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)
        ).toList();
      } catch (e) {
        // Error al obtener todos los enemigos desde Firebase: $e
        return [];
      }
    } else {
      return _loadEnemiesFromLocalJson();
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'reward_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RewardService _rewardService = RewardService();

  // Obtener datos del usuario actual
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      debugPrint('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  // Actualizar datos del usuario
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('Error al actualizar datos del usuario: $e');
      rethrow;
    }
  }

  // Incrementar la experiencia del usuario
  Future<void> addExperience(String uid, int amount) async {
    try {
      // Obtenemos los datos actuales
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      int currentExp = userData['experience'] ?? 0;
      int currentLevel = userData['level'] ?? 1;

      // Calculamos la nueva experiencia
      int newExp = currentExp + amount;
      
      // Verificamos si subió de nivel (fórmula simplificada)
      // Requerimiento de experiencia para el siguiente nivel: nivel actual * 100
      int expRequiredForNextLevel = currentLevel * 100;
      
      // Si alcanzó la experiencia necesaria, sube de nivel
      if (newExp >= expRequiredForNextLevel) {
        int newLevel = currentLevel + 1;
        
        await _firestore.collection('users').doc(uid).update({
          'experience': newExp % expRequiredForNextLevel, // Experiencia restante
          'level': newLevel,
          'coins': FieldValue.increment(newLevel * 10), // Bonificación de monedas por subir de nivel
        });
      } else {
        // Solo actualiza la experiencia
        await _firestore.collection('users').doc(uid).update({
          'experience': newExp,
        });
      }
    } catch (e) {
      debugPrint('Error al añadir experiencia: $e');
      rethrow;
    }
  }

  // Actualizar estadísticas después de responder una pregunta
  Future<void> updateStatsAfterQuestion(String uid, bool isCorrect) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'stats.questionsAnswered': FieldValue.increment(1),
        'stats.correctAnswers': isCorrect ? FieldValue.increment(1) : FieldValue.increment(0),
      });
    } catch (e) {
      debugPrint('Error al actualizar estadísticas: $e');
      rethrow;
    }
  }

  // Actualizar estadísticas después de una batalla
  Future<void> updateStatsAfterBattle(String uid, bool isWinner) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        isWinner ? 'stats.battlesWon' : 'stats.battlesLost': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error al actualizar estadísticas de batalla: $e');
      rethrow;
    }
  }
  // Marcar una misión como completada
  Future<void> completeMission(String uid, String missionId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'completedMissions': FieldValue.arrayUnion([missionId]),
        'currentMissionId': '',
        'progressInMission': {},
      });
      
      // Verificar si se desbloquean logros al completar esta misión
      await _rewardService.checkAndUnlockAchievement(uid, missionId);
    } catch (e) {
      debugPrint('Error al completar misión: $e');
      rethrow;
    }
  }

  // Añadir un item al inventario
  Future<void> addItemToInventory(String uid, Map<String, dynamic> item) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'inventory.items': FieldValue.arrayUnion([item]),
      });
    } catch (e) {
      debugPrint('Error al añadir item al inventario: $e');
      rethrow;
    }
  }

  // Iniciar misión: actualizar misión actual y progreso inicial
  Future<void> startMission(String uid, String missionId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'currentMissionId': missionId,
        'progressInMission': {},
      });
    } catch (e) {
      debugPrint('Error al iniciar misión: $e');
      rethrow;
    }
  }

  // Actualizar progreso dentro de una misión (mapa de progresoInMission)
  Future<void> updateProgressInMission(String uid, String questionId, bool isCorrect) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'progressInMission.$questionId': isCorrect,
      });
    } catch (e) {
      debugPrint('Error al actualizar progreso en misión: $e');
      rethrow;
    }
  }

  /// Marks the theory part of a mission as completed for the user.
  /// This would typically update a specific field in the user's progress for that mission.
  Future<void> markTheoryAsComplete(String uid, String missionId) async {
    // TODO: Implement actual Firestore update logic.
    // Example structure in Firestore: users/{uid}/missionProgress/{missionId}/theoryCompleted = true
    // Or add to a subcollection: users/{uid}/completedTheories/{missionId} = {completedAt: Timestamp}
    // print('[UserService] TODO: Implement markTheoryAsComplete for user $uid, mission $missionId');
    // For now, this is a placeholder.
    await Future.value(); 
  }

  /// Checks if the theory part of a mission has been completed by the user.
  /// This would read the corresponding status from Firestore.
  Future<bool> isTheoryCompleted(String uid, String missionId) async {
    // TODO: Implement actual Firestore read logic.
    // Example: Check users/{uid}/missionProgress/{missionId}/theoryCompleted
    // print('[UserService] TODO: Implement isTheoryCompleted for user $uid, mission $missionId');
    // For ahora, por defecto es falso.
    return Future.value(false);
  }

  Future<void> updateUserProgress(String userId, Map<String, dynamic> progressData) async {
    // TODO: Implement actual Firestore update logic.
    // print("Actualizando progreso del usuario $userId con: $progressData");
    // Ejemplo:
    // await _firestore.collection('users').doc(userId).update({'progress': progressData});
  }

  Future<Map<String, dynamic>?> getUserProgress(String userId) async {
    // TODO: Implement actual Firestore read logic.
    // print("Obteniendo progreso del usuario $userId");
    // Ejemplo:
    // DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    // return doc.exists ? doc.data() as Map<String, dynamic> : null;
    return null;
  }
}
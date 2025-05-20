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
}
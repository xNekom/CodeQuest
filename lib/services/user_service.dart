import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/reward_service.dart';
import '../services/leaderboard_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RewardService _rewardService = RewardService();
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Obtener datos del usuario actual
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
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

  // Añadir experiencia al usuario
  Future<void> addExperience(
    String uid,
    int experiencePoints, {
    String? missionId,
  }) async {
    // Si se proporciona un missionId, verificar que no esté ya completada
    if (missionId != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final List<String> completedMissions = List<String>.from(
            userData['completedMissions'] ?? [],
          );

          // Si la misión ya está completada, no otorgar experiencia adicional
          if (completedMissions.contains(missionId)) {
            debugPrint(
              '[UserService] No se otorga experiencia adicional para misión ya completada: $missionId',
            );
            return;
          }
        }
      } catch (e) {
        debugPrint(
          '[UserService] Error al verificar misión completada antes de otorgar experiencia: $e',
        );
        return;
      }
    }

    try {
      // Obtener datos actuales del usuario
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      int currentExp = userData['experience'] ?? 0;
      int currentLevel = userData['level'] ?? 1;

      // Calcular experiencia máxima para el nivel actual
      int maxExpForCurrentLevel = currentLevel * 100;

      // Calcular nueva experiencia
      int newExp = currentExp + experiencePoints;

      Map<String, dynamic> updateData = {};

      // Verificar si excede la experiencia máxima del nivel actual
      if (newExp >= maxExpForCurrentLevel) {
        // No se puede ganar más experiencia hasta subir de nivel por misiones
        // Mantener la experiencia en el máximo del nivel actual
        updateData['experience'] = maxExpForCurrentLevel;

        debugPrint(
          '[UserService] Experiencia limitada al máximo del nivel $currentLevel: $maxExpForCurrentLevel XP',
        );
        debugPrint(
          '[UserService] Para subir de nivel, completa 3 misiones de teoría y 1 de batalla',
        );
      } else {
        updateData['experience'] = newExp;
        debugPrint(
          '[UserService] Experiencia actualizada: $newExp/$maxExpForCurrentLevel XP',
        );
      }

      await _firestore.collection('users').doc(uid).update(updateData);

      // Actualizar puntuación en el leaderboard
      await _leaderboardService.updateUserScore(uid);
    } catch (e) {
      debugPrint('Error al añadir experiencia: $e');
      rethrow;
    }
  }

  // Actualizar estadísticas después de responder una pregunta
  Future<void> updateStatsAfterQuestion(String uid, bool isCorrect) async {
    try {
      Map<String, dynamic> updateData = {
        'stats.questionsAnswered': FieldValue.increment(1),
      };

      if (isCorrect) {
        updateData['stats.correctAnswers'] = FieldValue.increment(1);
      }

      await _firestore.collection('users').doc(uid).update(updateData);

      // Actualizar puntuación en el leaderboard
      await _leaderboardService.updateUserScore(uid);
    } catch (e) {
      debugPrint('Error al actualizar estadísticas: $e');
      rethrow;
    }
  }

  // Verificar progreso de nivel basado en misiones completadas
  Future<void> _checkLevelProgression(String uid, bool isBattleMission) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> completedMissions = List<String>.from(
        userData['completedMissions'] ?? [],
      );
      int currentLevel = userData['level'] ?? 1;

      // Obtener información de todas las misiones para clasificarlas
      final missionsSnapshot = await _firestore.collection('missions').get();

      // Clasificar misiones completadas por tipo
      int theoryMissionsCompleted = 0;
      int battleMissionsCompleted = 0;

      for (String missionId in completedMissions) {
        final missionDoc = missionsSnapshot.docs.firstWhere(
          (doc) => doc.id == missionId,
          orElse: () => throw Exception('Misión no encontrada'),
        );

        if (missionDoc.exists) {
          final missionData = missionDoc.data();
          final objectives = List<Map<String, dynamic>>.from(
            missionData['objectives'] ?? [],
          );

          // Verificar si es una misión de batalla
          bool isBattle = objectives.any((obj) => obj['type'] == 'batalla');

          if (isBattle) {
            battleMissionsCompleted++;
          } else {
            theoryMissionsCompleted++;
          }
        }
      }

      // Calcular cuántos niveles completos ha alcanzado el usuario
      // Cada nivel requiere 3 misiones de teoría + 1 de batalla
      int completeLevels = (theoryMissionsCompleted ~/ 3).clamp(
        0,
        battleMissionsCompleted,
      );
      int newLevel =
          completeLevels +
          1; // El nivel actual es el siguiente al último completo

      // Verificar si debe subir de nivel basado en misiones completadas
      if (newLevel > currentLevel) {
        // Calcular experiencia redistribuida para el nuevo nivel
        // Misiones de teoría restantes en el nivel actual (después de los grupos de 3)
        int remainingTheoryMissions = theoryMissionsCompleted % 3;
        // Experiencia base: 25 XP por misión de teoría restante, 50 XP por misión de batalla extra
        int redistributedExp = (remainingTheoryMissions * 25);

        // Si hay misiones de batalla extra (más allá de las necesarias para el nivel)
        int extraBattleMissions = battleMissionsCompleted - completeLevels;
        if (extraBattleMissions > 0) {
          redistributedExp += (extraBattleMissions * 50);
        }

        // Limitar la experiencia al máximo del nuevo nivel
        int maxExpForNewLevel = newLevel * 100;
        redistributedExp = redistributedExp.clamp(0, maxExpForNewLevel);

        Map<String, dynamic> updateData = {
          'level': newLevel,
          'experience': redistributedExp, // Resetear y redistribuir experiencia
          'coins': FieldValue.increment(
            (newLevel - currentLevel) * 200,
          ), // Bonificación por subir de nivel
        };

        await _firestore.collection('users').doc(uid).update(updateData);

        debugPrint(
          '[UserService] ¡Usuario $uid subió del nivel $currentLevel al nivel $newLevel por misiones completadas!',
        );
        debugPrint(
          '[UserService] Misiones completadas: $theoryMissionsCompleted teoría, $battleMissionsCompleted batalla',
        );
        debugPrint(
          '[UserService] Experiencia redistribuida: $redistributedExp/$maxExpForNewLevel XP',
        );

        // Actualizar puntuación en el leaderboard
        await _leaderboardService.updateUserScore(uid);
      }
    } catch (e) {
      debugPrint('[UserService] Error al verificar progreso de nivel: $e');
    }
  }

  // Actualizar estadísticas después de una batalla
  Future<void> updateStatsAfterBattle(String uid, bool isWinner) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        isWinner
            ? 'stats.battlesWon'
            : 'stats.battlesLost': FieldValue.increment(1),
      });

      // Actualizar puntuación en el leaderboard
      await _leaderboardService.updateUserScore(uid);
    } catch (e) {
      debugPrint('Error al actualizar estadísticas de batalla: $e');
      rethrow;
    }
  }

  // Actualizar estadísticas de enemigos derrotados
  Future<void> updateEnemyDefeatedStats(String uid, String enemyId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'stats.enemiesDefeated.$enemyId': FieldValue.increment(1),
        'stats.totalEnemiesDefeated': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error al actualizar estadísticas de enemigos: $e');
      rethrow;
    }
  }

  // Marcar una misión como completada
  Future<void> completeMission(
    String uid,
    String missionId, {
    bool isBattleMission = false,
  }) async {
    // Verificar si la misión ya está completada
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final List<String> completedMissions = List<String>.from(
          userData['completedMissions'] ?? [],
        );

        // Si la misión ya está completada, no hacer nada
        if (completedMissions.contains(missionId)) {
          debugPrint(
            '[UserService] Misión $missionId ya está completada para el usuario $uid',
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('[UserService] Error al verificar misiones completadas: $e');
      return;
    }

    // Marcar misión como completada en Firestore
    try {
      Map<String, dynamic> updateData = {
        'completedMissions': FieldValue.arrayUnion([missionId]),
        'currentMissionId': '',
        'progressInMission': {},
      };

      // Otorgar monedas según el tipo de misión
      if (isBattleMission) {
        updateData['coins'] = FieldValue.increment(
          50,
        ); // Más monedas por misiones de batalla
      } else {
        updateData['coins'] = FieldValue.increment(
          10,
        ); // Monedas estándar por misiones de teoría
      }

      await _firestore.collection('users').doc(uid).update(updateData);

      // Verificar progreso de nivel después de completar la misión
      await _checkLevelProgression(uid, isBattleMission);
    } catch (e) {
      debugPrint('[UserService] Error al actualizar misión en usuario: $e');
    }

    // Intentar desbloquear logros y otorgar recompensas sin propagar errores
    try {
      await _rewardService.checkAndUnlockAchievement(uid, missionId);
    } catch (e) {
      debugPrint('[UserService] Error al desbloquear logros: $e');
    }

    // Actualizar puntuación en el leaderboard
    try {
      await _leaderboardService.updateUserScore(uid);
    } catch (e) {
      debugPrint('[UserService] Error al actualizar leaderboard: $e');
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
  Future<void> updateProgressInMission(
    String uid,
    String questionId,
    bool isCorrect,
  ) async {
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
    try {
      // Actualizar el progreso de la misión en Firestore
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('missionProgress')
          .doc(missionId)
          .set({
            'theoryCompleted': true,
            'completedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint(
        '[UserService] Teoría marcada como completada para usuario $uid, misión $missionId',
      );
    } catch (e) {
      debugPrint('[UserService] Error al marcar teoría como completada: $e');
      rethrow;
    }
  }

  /// Checks if the theory part of a mission has been completed by the user.
  /// This would read the corresponding status from Firestore.
  Future<bool> isTheoryCompleted(String uid, String missionId) async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('missionProgress')
              .doc(missionId)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['theoryCompleted'] ?? false;
      }

      return false;
    } catch (e) {
      debugPrint(
        '[UserService] Error al verificar si teoría está completada: $e',
      );
      return false;
    }
  }

  Future<void> updateUserProgress(
    String userId,
    Map<String, dynamic> progressData,
  ) async {
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

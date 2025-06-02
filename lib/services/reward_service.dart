import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reward_notification_service.dart';
import '../config/app_config.dart';
import '../models/reward_model.dart';
import '../models/achievement_model.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _rewardsCol;
  late final CollectionReference _achievementsCol;
  late final CollectionReference _userAchievementsCol;
  final RewardNotificationService _notificationService =
      RewardNotificationService();

  RewardService() {
    _rewardsCol = _firestore.collection('rewards');
    _achievementsCol = _firestore.collection('achievements');
    _userAchievementsCol = _firestore.collection('user_achievements');
  }

  // --- Gestión de Recompensas (Admin) ---
  Future<void> createReward(Reward reward) async {
    if (!AppConfig.shouldUseFirebase) return;
    await _rewardsCol.doc(reward.id).set(reward.toMap());
  }

  Future<void> updateReward(Reward reward) async {
    if (!AppConfig.shouldUseFirebase) return;
    await _rewardsCol.doc(reward.id).update(reward.toMap());
  }

  Future<void> deleteReward(String rewardId) async {
    if (!AppConfig.shouldUseFirebase) return;
    await _rewardsCol.doc(rewardId).delete();
  }

  Stream<List<Reward>> getRewards() {
    if (!AppConfig.shouldUseFirebase) {
      return Stream.fromFuture(_loadRewardsFromLocalJson());
    }
    return _rewardsCol.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => Reward.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<Reward?> getRewardById(String rewardId) async {
    if (!AppConfig.shouldUseFirebase) {
      final rewards = await _loadRewardsFromLocalJson();
      try {
        return rewards.firstWhere((r) => r.id == rewardId);
      } catch (e) {
        return null;
      }
    }

    final doc = await _rewardsCol.doc(rewardId).get();
    if (doc.exists) {
      return Reward.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Reward>> _loadRewardsFromLocalJson() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/rewards_data.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Reward.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading rewards from local JSON: $e');
      return [];
    }
  }

  // --- Gestión de Logros (Admin y local) ---
  Stream<List<Achievement>> getAchievements() {
    if (!AppConfig.shouldUseFirebase) {
      return Stream.fromFuture(_loadAchievementsFromLocalJson());
    }
    return _achievementsCol.snapshots().map(
      (s) =>
          s.docs
              .map((d) => Achievement.fromMap(d.data() as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<List<Achievement>> _loadAchievementsFromLocalJson() async {
    try {
      final js = await rootBundle.loadString(
        'assets/data/achievements_data.json',
      );
      final list = json.decode(js) as List<dynamic>;
      return list
          .map((e) => Achievement.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading achievements from local JSON: $e');
      return [];
    }
  }

  Future<void> createAchievement(Achievement achievement) async {
    if (!AppConfig.shouldUseFirebase) return;
    await _achievementsCol.doc(achievement.id).set(achievement.toMap());
  }

  Future<void> updateAchievement(Achievement achievement) async {
    if (!AppConfig.shouldUseFirebase) return;
    await _achievementsCol.doc(achievement.id).update(achievement.toMap());
  }

  Future<void> deleteAchievement(String achievementId) async {
    if (!AppConfig.shouldUseFirebase) return;
    await _achievementsCol.doc(achievementId).delete();
  }

  // --- Lógica de Desbloqueo de Logros y Entrega de Recompensas (Juego) ---
  Future<void> checkAndUnlockAchievement(
    String userId,
    String missionId,
  ) async {
    debugPrint("Verificando logros para misión: $missionId");

    // Obtener logros que dependen de la misión - usar achievementType y requiredMissionIds juntos
    final snap =
        await _achievementsCol
            .where('achievementType', isEqualTo: 'mission')
            .where('requiredMissionIds', arrayContains: missionId)
            .get();

    debugPrint("Encontrados ${snap.docs.length} logros por misión");

    final achievementsToCheck =
        snap.docs
            .map(
              (doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

    for (var achievement in achievementsToCheck) {
      debugPrint("Procesando logro: ${achievement.id} - ${achievement.name}");

      if (await _isAchievementUnlocked(userId, achievement.id)) {
        debugPrint("Logro ya desbloqueado: ${achievement.id}");
        continue;
      }

      // Registrar en la subcolección y en users/{userId}.unlockedAchievements
      debugPrint("Desbloqueando logro: ${achievement.id}");
      await _unlockAchievementForUser(userId, achievement);

      // Otorgar recompensa según configuración Firebase
      debugPrint("Otorgando recompensa: ${achievement.rewardId}");
      await _grantRewardToUser(userId, achievement.rewardId);
    }
  }

  // Lógica de desbloqueo de logros de enemigos (solo Firebase)
  Future<void> checkAndUnlockEnemyAchievements(
    String userId,
    String enemyId,
  ) async {
    // Consultar logros de tipo enemy para este enemigo
    final snap =
        await _achievementsCol
            .where('achievementType', isEqualTo: 'enemy')
            .where('requiredEnemyId', isEqualTo: enemyId)
            .get();
    final achievementsToCheck =
        snap.docs
            .map(
              (doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

    for (var achievement in achievementsToCheck) {
      // Verificar si ya está desbloqueado
      if (await _isAchievementUnlocked(userId, achievement.id)) continue;
      // Obtener conteo de derrotas
      final count = await _getEnemyDefeatCount(userId, enemyId);
      if (count >= (achievement.requiredEnemyDefeats ?? 1)) {
        await _unlockAchievementForUser(userId, achievement);
        await _grantRewardToUser(userId, achievement.rewardId);
      }
    }
  }

  // Esta función puede ser útil en futuras mejoras para verificación previa
  // de requisitos completos para desbloquear logros
  /* 
  Future<bool> _checkAllRequiredMissionsCompleted(String userId, List<String> requiredMissionIds) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;
    final data = userDoc.data();
    final completed = List<String>.from((data?['completedMissions'] as List<dynamic>?) ?? []);
    
    for (final missionId in requiredMissionIds) {
      if (!completed.contains(missionId)) {
        return false;
      }
    }
    return true;
  }
  */
  Future<void> _unlockAchievementForUser(
    String userId,
    Achievement achievement,
  ) async {
    try {
      // Primero, intentar almacenar en la colección separada
      debugPrint("Guardando logro en subcolección user_achievements");
      await _userAchievementsCol
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id)
          .set({
            'achievementId': achievement.id,
            'name': achievement.name,
            'description': achievement.description,
            'iconUrl': achievement.iconUrl,
            'unlockedDate': FieldValue.serverTimestamp(),
            'category': achievement.category,
            'points': achievement.points,
          });

      debugPrint("Logro guardado en subcolección correctamente");
    } catch (e) {
      debugPrint("Error al guardar logro en subcolección: $e");
      // No propagamos el error para continuar con la siguiente operación
    }

    try {
      // Segundo, intentar actualizar el array en el documento del usuario
      debugPrint(
        "Actualizando array unlockedAchievements en documento de usuario",
      );
      await _firestore.collection('users').doc(userId).update({
        'unlockedAchievements': FieldValue.arrayUnion([achievement.id]),
      });

      debugPrint("Array de logros actualizado correctamente");
    } catch (e) {
      debugPrint("Error al actualizar array de logros: $e");
      rethrow; // Propagamos este error ya que es crítico
    }
  }

  Future<bool> _isAchievementUnlocked(
    String userId,
    String achievementId,
  ) async {
    // Leer directamente el arreglo unlockedAchievements desde el documento de usuario
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;
    final data = userDoc.data();
    final ids = List<String>.from(
      (data?['unlockedAchievements'] as List<dynamic>?) ?? [],
    );
    return ids.contains(achievementId);
  }

  Future<void> _grantRewardToUser(String userId, String rewardId) async {
    final reward = await getRewardById(rewardId);
    if (reward == null) return;

    if (!AppConfig.shouldUseFirebase) {
      _notificationService.showRewardNotification(reward);
      return;
    }

    final userDocRef = _firestore.collection('users').doc(userId);

    switch (reward.type) {
      case 'points':
      case 'experience':
        await userDocRef.update({
          'experiencePoints': FieldValue.increment(reward.value),
        });
        break;
      case 'item':
        await userDocRef.collection('inventory').add({
          'itemId': reward.value,
          'itemName': reward.name,
          'acquiredDate': FieldValue.serverTimestamp(),
        });
        break;
      case 'badge':
        await userDocRef.collection('badges').doc(reward.id).set({
          'badgeName': reward.name,
          'description': reward.description,
          'iconUrl': reward.iconUrl,
          'acquiredDate': FieldValue.serverTimestamp(),
        });
        break;
      case 'coins':
        await userDocRef.update({'coins': FieldValue.increment(reward.value)});
        break;
    }

    _notificationService.showRewardNotification(reward);
  }

  Future<int> _getEnemyDefeatCount(String userId, String enemyId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;

      final data = userDoc.data();
      final enemiesDefeated =
          data?['stats']?['enemiesDefeated'] as Map<String, dynamic>?;

      return (enemiesDefeated?[enemyId] as int?) ?? 0;
    } catch (e) {
      debugPrint('Error al obtener estadísticas de enemigos: $e');
      return 0;
    }
  }

  Stream<List<Achievement>> getUnlockedAchievements(String userId) {
    // Leer siempre desde el campo unlockedAchievements del documento de usuario
    debugPrint('DEBUG getUnlockedAchievements: Starting for userId: $userId');
    debugPrint(
      'DEBUG getUnlockedAchievements: shouldUseFirebase: ${AppConfig.shouldUseFirebase}',
    );

    if (!AppConfig.shouldUseFirebase) {
      debugPrint(
        'DEBUG getUnlockedAchievements: Firebase disabled, returning empty list',
      );
      return Stream.value(<Achievement>[]);
    }

    return _firestore.collection('users').doc(userId).snapshots().asyncMap((
      doc,
    ) async {
      try {
        debugPrint(
          'DEBUG getUnlockedAchievements: Document exists: ${doc.exists}',
        );
        final data = doc.data();
        debugPrint(
          'DEBUG getUnlockedAchievements: User data exists: ${data != null}',
        );
        debugPrint('DEBUG getUnlockedAchievements: Full user data: $data');

        final ids =
            data == null
                ? <String>[]
                : List<String>.from(
                  (data['unlockedAchievements'] as List<dynamic>?) ?? [],
                );

        debugPrint(
          'DEBUG getUnlockedAchievements: Found ${ids.length} achievement IDs: $ids',
        );

        if (ids.isEmpty) {
          debugPrint(
            'DEBUG getUnlockedAchievements: No achievements found, returning empty list',
          );
          return <Achievement>[];
        }

        // Firestore whereIn tiene límite de 10 elementos, dividir si es necesario
        final List<Achievement> allAchievements = [];

        // Procesar en lotes de 10 (límite de Firestore whereIn)
        for (int i = 0; i < ids.length; i += 10) {
          final batch = ids.skip(i).take(10).toList();
          debugPrint('DEBUG getUnlockedAchievements: Querying batch: $batch');

          final snap =
              await _achievementsCol
                  .where(FieldPath.documentId, whereIn: batch)
                  .get();

          debugPrint(
            'DEBUG getUnlockedAchievements: Found ${snap.docs.length} achievements in batch',
          );

          final batchAchievements =
              snap.docs
                  .map(
                    (d) =>
                        Achievement.fromMap(d.data() as Map<String, dynamic>),
                  )
                  .toList();

          allAchievements.addAll(batchAchievements);
        }

        debugPrint(
          'DEBUG getUnlockedAchievements: Total achievements loaded: ${allAchievements.length}',
        );
        return allAchievements;
      } catch (e) {
        debugPrint('ERROR getUnlockedAchievements: $e');
        return <Achievement>[];
      }
    });
  }
}

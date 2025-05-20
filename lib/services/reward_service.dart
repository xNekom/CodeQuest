import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';
import '../models/achievement_model.dart';
import 'reward_notification_service.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _rewardsCol;
  late final CollectionReference _achievementsCol;
  late final CollectionReference _userAchievementsCol;
  final RewardNotificationService _notificationService = RewardNotificationService();

  RewardService() {
    _rewardsCol = _firestore.collection('rewards');
    _achievementsCol = _firestore.collection('achievements');
    // Colección para rastrear los logros desbloqueados por cada usuario
    _userAchievementsCol = _firestore.collection('user_achievements');
  }

  // --- Gestión de Recompensas (Admin) ---
  Future<void> createReward(Reward reward) async {
    await _rewardsCol.doc(reward.id).set(reward.toMap());
  }

  Future<void> updateReward(Reward reward) async {
    await _rewardsCol.doc(reward.id).update(reward.toMap());
  }

  Future<void> deleteReward(String rewardId) async {
    await _rewardsCol.doc(rewardId).delete();
  }

  Stream<List<Reward>> getRewards() {
    return _rewardsCol.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Reward.fromMap(doc.data() as Map<String, dynamic>)).toList()
    );
  }

  Future<Reward?> getRewardById(String rewardId) async {
    final doc = await _rewardsCol.doc(rewardId).get();
    if (doc.exists) {
      return Reward.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // --- Gestión de Logros (Admin) ---
  Future<void> createAchievement(Achievement achievement) async {
    await _achievementsCol.doc(achievement.id).set(achievement.toMap());
  }

  Future<void> updateAchievement(Achievement achievement) async {
    await _achievementsCol.doc(achievement.id).update(achievement.toMap());
  }

  Future<void> deleteAchievement(String achievementId) async {
    await _achievementsCol.doc(achievementId).delete();
    // Opcional: eliminar de user_achievements también
  }

  Stream<List<Achievement>> getAchievements() {
    return _achievementsCol.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>)).toList()
    );
  }

  // --- Lógica de Desbloqueo de Logros y Entrega de Recompensas (Juego) ---

  Future<void> checkAndUnlockAchievement(String userId, String missionId) async {
    // 1. Obtener todos los logros que podrían ser desbloqueados por esta misión
    final achievementsSnapshot = await _achievementsCol
        .where('requiredMissionIds', arrayContains: missionId)
        .get();

    for (var achievementDoc in achievementsSnapshot.docs) {
      Achievement achievement = Achievement.fromMap(achievementDoc.data() as Map<String, dynamic>);
      
      // 2. Verificar si el usuario ya desbloqueó este logro
      final userAchievementDoc = await _userAchievementsCol
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id)
          .get();

      if (userAchievementDoc.exists) {
        continue; // Ya desbloqueado
      }

      // 3. Verificar si el usuario ha completado TODAS las misiones requeridas para este logro
      // Esto requiere que tengas una forma de rastrear las misiones completadas por el usuario.
      // Asumiremos que tienes una colección `user_completed_missions` o similar.
      bool allMissionsCompleted = await _checkAllRequiredMissionsCompleted(userId, achievement.requiredMissionIds);

      if (allMissionsCompleted) {
        await _unlockAchievementForUser(userId, achievement);
        await _grantRewardToUser(userId, achievement.rewardId);
        // Aquí podrías disparar una notificación al usuario
      }
    }
  }

  Future<bool> _checkAllRequiredMissionsCompleted(String userId, List<String> requiredMissionIds) async {
    // Esta es una implementación placeholder. Necesitas adaptarla a cómo almacenas las misiones completadas.
    // Ejemplo: Consultar una colección `users/{userId}/completedMissions`
    final completedMissionsCol = _firestore.collection('users').doc(userId).collection('completedMissions');
    for (String missionId in requiredMissionIds) {
      final missionDoc = await completedMissionsCol.doc(missionId).get();
      if (!missionDoc.exists) {
        return false; // Falta al menos una misión
      }
    }
    return true;
  }

  Future<void> _unlockAchievementForUser(String userId, Achievement achievement) async {
    await _userAchievementsCol
        .doc(userId)
        .collection('achievements')
        .doc(achievement.id)
        .set({
          ...achievement.toMap(), // Guarda una copia del logro
          'unlockedDate': FieldValue.serverTimestamp(),
        });
    print('Logro ${achievement.name} desbloqueado para el usuario $userId');
  }
  Future<void> _grantRewardToUser(String userId, String rewardId) async {
    Reward? reward = await getRewardById(rewardId);
    if (reward == null) {
      print('Error: Recompensa con ID $rewardId no encontrada.');
      return;
    }

    // Aquí implementas la lógica para dar la recompensa al usuario
    // Por ejemplo, actualizar puntos, añadir item al inventario, etc.
    // Esto dependerá de tu `UserService` y la estructura de datos del usuario.
    final userDocRef = _firestore.collection('users').doc(userId);

    switch (reward.type) {
      case RewardType.points:
        await userDocRef.update({
          'experiencePoints': FieldValue.increment(reward.value), // O gameCurrency, etc.
        });
        print('Otorgados ${reward.value} puntos al usuario $userId');
        break;
      case RewardType.item:
        // Asume que tienes una subcolección de inventario para el usuario
        await userDocRef.collection('inventory').add({
          'itemId': reward.value, // Asumiendo que value es el ID del item
          'itemName': reward.name, // Podrías guardar más detalles del item
          'acquiredDate': FieldValue.serverTimestamp(),
        });
        print('Otorgado item ${reward.name} al usuario $userId');
        break;
      case RewardType.badge:
        // Asume que tienes un campo o subcolección para las insignias del usuario
        await userDocRef.collection('badges').doc(reward.id).set({
          'badgeName': reward.name,
          'description': reward.description,
          'iconUrl': reward.iconUrl,
          'acquiredDate': FieldValue.serverTimestamp(),
        });
        print('Otorgada insignia ${reward.name} al usuario $userId');
        break;
    }
    // Notificar al servicio de notificaciones para mostrar la alerta de recompensa
    _notificationService.showRewardNotification(reward);
  }

  // Obtener logros desbloqueados por un usuario
  Stream<List<Achievement>> getUnlockedAchievements(String userId) {
    return _userAchievementsCol
        .doc(userId)
        .collection('achievements')
        .orderBy('unlockedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromMap(doc.data()))
            .toList());
  }
}

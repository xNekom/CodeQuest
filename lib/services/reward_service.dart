import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_model.dart';
import '../models/achievement_model.dart';
import 'reward_notification_service.dart';
import '../config/app_config.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _rewardsCol;
  late final CollectionReference _achievementsCol;
  late final CollectionReference _userAchievementsCol;
  final RewardNotificationService _notificationService = RewardNotificationService();

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
    return _rewardsCol.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Reward.fromMap(doc.data() as Map<String, dynamic>)).toList()
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
      final jsonString = await rootBundle.loadString('assets/data/rewards_data.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((e) => Reward.fromMap(e as Map<String, dynamic>)).toList();
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
    return _achievementsCol.snapshots().map((s) =>
        s.docs.map((d) => Achievement.fromMap(d.data() as Map<String, dynamic>)).toList());
  }

  Future<List<Achievement>> _loadAchievementsFromLocalJson() async {
    try {
      final js = await rootBundle.loadString('assets/data/achievements_data.json');
      final list = json.decode(js) as List<dynamic>;
      return list.map((e) => Achievement.fromMap(e as Map<String, dynamic>)).toList();
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
  Future<void> checkAndUnlockAchievement(String userId, String missionId) async {
    List<Achievement> achievementsToCheck;
    
    if (!AppConfig.shouldUseFirebase) {
      final all = await _loadAchievementsFromLocalJson();
      achievementsToCheck = all.where((a) => a.requiredMissionIds.contains(missionId)).toList();
      
      if (achievementsToCheck.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'unlocked_$userId';
        final unlocked = prefs.getStringList(key) ?? <String>[];
        
        for (var achievement in achievementsToCheck) {
          if (!unlocked.contains(achievement.id)) {
            unlocked.add(achievement.id);
            // Notificar recompensa local
            final fakeReward = Reward(
              id: achievement.rewardId,
              name: achievement.name,
              description: achievement.description,
              iconUrl: achievement.iconUrl,
              type: 'badge',
              value: 0,
            );
            _notificationService.showRewardNotification(fakeReward);
          }
        }
        await prefs.setStringList(key, unlocked);
      }
      return;
    }
    
    final snap = await _achievementsCol.where('requiredMissionIds', arrayContains: missionId).get();
    achievementsToCheck = snap.docs
        .map((doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    
    for (var achievement in achievementsToCheck) {
      if (await _isAchievementUnlocked(userId, achievement.id)) {
        continue;
      }

      bool allMissionsCompleted = await _checkAllRequiredMissionsCompleted(userId, achievement.requiredMissionIds);

      if (allMissionsCompleted) {
        await _unlockAchievementForUser(userId, achievement);
        await _grantRewardToUser(userId, achievement.rewardId);
      }
    }
  }

  Future<void> checkAndUnlockEnemyAchievements(String userId, String enemyId) async {
    List<Achievement> achievementsToCheck;
    
    if (!AppConfig.shouldUseFirebase) {
      final all = await _loadAchievementsFromLocalJson();
      achievementsToCheck = all.where((a) => 
          a.achievementType == 'enemy' && a.requiredEnemyId == enemyId).toList();
    } else {
      final snap = await _achievementsCol
          .where('achievementType', isEqualTo: 'enemy')
          .where('requiredEnemyId', isEqualTo: enemyId)
          .get();
      achievementsToCheck = snap.docs
          .map((doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    }

    for (var achievement in achievementsToCheck) {
      if (!AppConfig.shouldUseFirebase) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'unlocked_$userId';
        final unlocked = prefs.getStringList(key) ?? <String>[];
        if (unlocked.contains(achievement.id)) continue;
        
        // En modo local, simplemente desbloqueamos después de derrotar el enemigo
        unlocked.add(achievement.id);
        await prefs.setStringList(key, unlocked);
      } else {
        if (await _isAchievementUnlocked(userId, achievement.id)) continue;
        
        final enemyDefeatCount = await _getEnemyDefeatCount(userId, enemyId);
        if (enemyDefeatCount >= (achievement.requiredEnemyDefeats ?? 1)) {
          await _unlockAchievementForUser(userId, achievement);
          await _grantRewardToUser(userId, achievement.rewardId);
        }
      }
    }
  }

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

  Future<void> _unlockAchievementForUser(String userId, Achievement achievement) async {
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
  }

  Future<bool> _isAchievementUnlocked(String userId, String achievementId) async {
    if (!AppConfig.shouldUseFirebase) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'unlocked_$userId';
      final unlocked = prefs.getStringList(key) ?? <String>[];
      return unlocked.contains(achievementId);
    }
    
    final userAchievementDoc = await _userAchievementsCol
        .doc(userId)
        .collection('achievements')
        .doc(achievementId)
        .get();
    return userAchievementDoc.exists;
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
        await userDocRef.update({
          'coins': FieldValue.increment(reward.value),
        });
        break;
    }
    
    _notificationService.showRewardNotification(reward);
  }

  Future<int> _getEnemyDefeatCount(String userId, String enemyId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0;
      
      final data = userDoc.data();
      final enemiesDefeated = data?['stats']?['enemiesDefeated'] as Map<String, dynamic>?;
      
      return (enemiesDefeated?[enemyId] as int?) ?? 0;
    } catch (e) {
      debugPrint('Error al obtener estadísticas de enemigos: $e');
      return 0;
    }
  }

  Stream<List<Achievement>> getUnlockedAchievements(String userId) {
    if (!AppConfig.shouldUseFirebase) {
      return Stream.fromFuture(_loadLocalUnlocked(userId));
    }
    
    return _userAchievementsCol
        .doc(userId)
        .collection('achievements')
        .orderBy('unlockedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromMap(doc.data()))
            .toList());
  }

  Future<List<Achievement>> _loadLocalUnlocked(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'unlocked_$userId';
    final ids = prefs.getStringList(key) ?? <String>[];
    
    final all = await _loadAchievementsFromLocalJson();
    
    return all.where((a) => ids.contains(a.id)).map((a) => Achievement(
      id: a.id,
      name: a.name,
      description: a.description,
      iconUrl: a.iconUrl,
      requiredMissionIds: a.requiredMissionIds,
      rewardId: a.rewardId,
      category: a.category,
      points: a.points,
      conditions: a.conditions,
      unlockedDate: Timestamp.fromDate(DateTime.now()),
      requiredEnemyId: a.requiredEnemyId,
      requiredEnemyDefeats: a.requiredEnemyDefeats,
      achievementType: a.achievementType,
    )).toList();
  }
}

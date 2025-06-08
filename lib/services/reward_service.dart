import 'package:cloud_firestore/cloud_firestore.dart';
import 'reward_notification_service.dart';
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
    await _rewardsCol.doc(reward.id).set(reward.toMap());
  }

  Future<void> updateReward(Reward reward) async {
    await _rewardsCol.doc(reward.id).update(reward.toMap());
  }

  Future<void> deleteReward(String rewardId) async {
    await _rewardsCol.doc(rewardId).delete();
  }

  Stream<List<Reward>> getRewards() {
    return _rewardsCol.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => Reward.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<Reward?> getRewardById(String rewardId) async {
    final doc = await _rewardsCol.doc(rewardId).get();
    if (doc.exists) {
      return Reward.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // --- Gestión de Logros ---
  Stream<List<Achievement>> getAchievements() {
    return _achievementsCol.snapshots().map(
      (s) =>
          s.docs
              .map((d) => Achievement.fromMap(d.data() as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<void> createAchievement(Achievement achievement) async {
    await _achievementsCol.doc(achievement.id).set(achievement.toMap());
  }

  Future<void> updateAchievement(Achievement achievement) async {
    await _achievementsCol.doc(achievement.id).update(achievement.toMap());
  }

  Future<void> deleteAchievement(String achievementId) async {
    await _achievementsCol.doc(achievementId).delete();
  }

  // --- Lógica de Desbloqueo de Logros y Entrega de Recompensas (Juego) ---
  Future<void> checkAndUnlockAchievement(
    String userId,
    String missionId,
  ) async {
    final snap1 =
        await _achievementsCol
            .where('achievementType', isEqualTo: 'mission')
            .where('requiredMissionIds', arrayContains: missionId)
            .get();

    final snap2 =
        await _achievementsCol
            .where('achievementType', isEqualTo: 'mission_completion')
            .where('requiredMissionIds', arrayContains: missionId)
            .get();

    final allDocs = [...snap1.docs, ...snap2.docs];

    final achievementsToCheck =
        allDocs
            .map(
              (doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

    for (var achievement in achievementsToCheck) {
      if (await _isAchievementUnlocked(userId, achievement.id)) {
        continue;
      }

      await _unlockAchievementForUser(userId, achievement);
      await _grantRewardToUser(userId, achievement.rewardId);
    }
  }

  Future<void> checkAndUnlockEnemyAchievements(
    String userId,
    String enemyId,
  ) async {
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
      if (await _isAchievementUnlocked(userId, achievement.id)) continue;
      final count = await _getEnemyDefeatCount(userId, enemyId);
      if (count >= (achievement.requiredEnemyDefeats ?? 1)) {
        await _unlockAchievementForUser(userId, achievement);
        await _grantRewardToUser(userId, achievement.rewardId);
      }
    }
  }

  Future<void> _unlockAchievementForUser(
    String userId,
    Achievement achievement,
  ) async {
    try {
      await _userAchievementsCol
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id)
          .set({
            'achievementId': achievement.id,
            'name': achievement.name,
            'description': achievement.description,
            'unlockedDate': FieldValue.serverTimestamp(),
            'category': achievement.category,
            'points': achievement.points,
          });
    } catch (e) {
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'unlockedAchievements': FieldValue.arrayUnion([achievement.id]),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _isAchievementUnlocked(
    String userId,
    String achievementId,
  ) async {
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
          'acquiredDate': FieldValue.serverTimestamp(),
        });
        break;
      case 'coins':
        await userDocRef.update({'coins': FieldValue.increment(reward.value)});
        break;
    }

    _notificationService.showRewardNotification(reward);
  }

  // --- Gestión de Logros para Ejercicios de Código ---
  Future<void> checkAndUnlockCodeExerciseAchievements(
    String userId,
    String exerciseId,
  ) async {
    try {
      await _updateUserCodeExerciseProgress(userId, exerciseId);

      final achievements = await _loadAchievementsFromFirestore();

      final codeExerciseAchievements = achievements.where((achievement) =>
        achievement.achievementType == 'code_exercise_completion' ||
        achievement.achievementType == 'code_exercise_milestone'
      ).toList();

      for (final achievement in codeExerciseAchievements) {
        final isUnlocked = await _isAchievementUnlocked(userId, achievement.id);
        if (!isUnlocked && await _checkCodeExerciseAchievementConditions(userId, achievement)) {
          await _unlockAchievementForUser(userId, achievement);
          await _grantRewardToUser(userId, achievement.rewardId);
        }
      }
    } catch (e) {
    }
  }

  Future<void> _updateUserCodeExerciseProgress(String userId, String exerciseId) async {
    final userDocRef = _firestore.collection('users').doc(userId);

    await userDocRef.update({
      'completedCodeExercises': FieldValue.arrayUnion([exerciseId]),
      'lastCompletedCodeExercise': exerciseId,
      'lastActivityDate': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> _checkCodeExerciseAchievementConditions(
    String userId,
    Achievement achievement,
  ) async {
    final conditions = achievement.conditions;

    if (conditions.containsKey('completedCodeExerciseId')) {
      final requiredExerciseId = conditions['completedCodeExerciseId'] as String;
      return await _hasCompletedCodeExercise(userId, requiredExerciseId);
    }

    if (conditions.containsKey('completedCodeExercisesCount')) {
      final requiredCount = conditions['completedCodeExercisesCount'] as int;
      final completedCount = await _getCompletedCodeExercisesCount(userId);
      return completedCount >= requiredCount;
    }

    if (conditions.containsKey('completedAllCodeExercises')) {
      return await _hasCompletedAllCodeExercises(userId);
    }

    return false;
  }

  Future<bool> _hasCompletedCodeExercise(String userId, String exerciseId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final data = userDoc.data();
    final completedExercises = List<String>.from(
      (data?['completedCodeExercises'] as List<dynamic>?) ?? [],
    );

    return completedExercises.contains(exerciseId);
  }

  Future<int> _getCompletedCodeExercisesCount(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return 0;

    final data = userDoc.data();
    final completedExercises = List<String>.from(
      (data?['completedCodeExercises'] as List<dynamic>?) ?? [],
    );

    return completedExercises.length;
  }

  Future<bool> _hasCompletedAllCodeExercises(String userId) async {
    final exercisesSnapshot = await _firestore.collection('code_exercises').get();
    final totalExercises = exercisesSnapshot.size;
    final completedCount = await _getCompletedCodeExercisesCount(userId);

    return completedCount >= totalExercises;
  }

  Future<List<Achievement>> _loadAchievementsFromFirestore() async {
    final snapshot = await _achievementsCol.get();
    return snapshot.docs
        .map((doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
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
      return 0;
    }
  }

  Stream<List<Achievement>> getUnlockedAchievements(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((
      doc,
    ) async {
      try {
        final data = doc.data();

        final ids =
            data == null
                ? <String>[]
                : List<String>.from(
                  (data['unlockedAchievements'] as List<dynamic>?) ?? [],
                );

        if (ids.isEmpty) {
          return <Achievement>[];
        }

        final List<Achievement> allAchievements = [];

        for (int i = 0; i < ids.length; i += 10) {
          final batch = ids.skip(i).take(10).toList();

          final snap =
              await _achievementsCol
                  .where(FieldPath.documentId, whereIn: batch)
                  .get();

          final batchAchievements =
              snap.docs
                  .map(
                    (d) =>
                        Achievement.fromMap(d.data() as Map<String, dynamic>),
                  )
                  .toList();

          allAchievements.addAll(batchAchievements);
        }

        return allAchievements;
      } catch (e) {
        return <Achievement>[];
      }
    });
  }
}

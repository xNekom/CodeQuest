import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reward_notification_service.dart';
import '../config/app_config.dart';
import '../models/reward_model.dart';
import '../models/achievement_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // debugPrint('Error loading rewards from local JSON: $e'); // REMOVIDO PARA PRODUCCIÓN
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
      // debugPrint('Error loading achievements from local JSON: $e'); // REMOVIDO PARA PRODUCCIÓN
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
    if (!AppConfig.shouldUseFirebase) {
      await _checkAndUnlockMissionAchievementsLocal(userId, missionId);
      return;
    }
    
    // debugPrint("Verificando logros para misión: $missionId"); // REMOVIDO PARA PRODUCCIÓN

    // Obtener logros que dependen de la misión - incluir tanto 'mission' como 'mission_completion'
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
    
    // Combinar resultados de ambas consultas
    final allDocs = [...snap1.docs, ...snap2.docs];

    // debugPrint("Encontrados ${allDocs.length} logros por misión"); // REMOVIDO PARA PRODUCCIÓN

    final achievementsToCheck =
        allDocs
            .map(
              (doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

    for (var achievement in achievementsToCheck) {
      // debugPrint("Procesando logro: ${achievement.id} - ${achievement.name}"); // REMOVIDO PARA PRODUCCIÓN

      if (await _isAchievementUnlocked(userId, achievement.id)) {
        // debugPrint("Logro ya desbloqueado: ${achievement.id}"); // REMOVIDO PARA PRODUCCIÓN
        continue;
      }

      // Registrar en la subcolección y en users/{userId}.unlockedAchievements
      // debugPrint("Desbloqueando logro: ${achievement.id}"); // REMOVIDO PARA PRODUCCIÓN
      await _unlockAchievementForUser(userId, achievement);

      // Otorgar recompensa según configuración Firebase
      // debugPrint("Otorgando recompensa: ${achievement.rewardId}"); // REMOVIDO PARA PRODUCCIÓN
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
      // debugPrint("Guardando logro en subcolección user_achievements"); // REMOVIDO PARA PRODUCCIÓN
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

      // debugPrint("Logro guardado en subcolección correctamente"); // REMOVIDO PARA PRODUCCIÓN
    } catch (e) {
      // debugPrint("Error al guardar logro en subcolección: $e"); // REMOVIDO PARA PRODUCCIÓN
      // No propagamos el error para continuar con la siguiente operación
    }

    try {
      // Segundo, intentar actualizar el array en el documento del usuario
      // debugPrint("Actualizando array unlockedAchievements en documento de usuario"); // REMOVIDO PARA PRODUCCIÓN
      await _firestore.collection('users').doc(userId).update({
        'unlockedAchievements': FieldValue.arrayUnion([achievement.id]),
      });

      // debugPrint("Array de logros actualizado correctamente"); // REMOVIDO PARA PRODUCCIÓN
    } catch (e) {
      // debugPrint("Error al actualizar array de logros: $e"); // REMOVIDO PARA PRODUCCIÓN
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
    if (!AppConfig.shouldUseFirebase) {
      // Implementación local cuando Firebase está deshabilitado
      await _checkAndUnlockCodeExerciseAchievementsLocal(userId, exerciseId);
      return;
    }

    try {
      // Actualizar progreso del usuario
      await _updateUserCodeExerciseProgress(userId, exerciseId);

      // Obtener todos los logros
      final achievements = await _loadAchievementsFromFirestore();
      
      // Filtrar logros relacionados con ejercicios de código
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
      // debugPrint('Error checking code exercise achievements: $e'); // REMOVIDO PARA PRODUCCIÓN
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
    
    // Verificar logro por ejercicio específico
    if (conditions.containsKey('completedCodeExerciseId')) {
      final requiredExerciseId = conditions['completedCodeExerciseId'] as String;
      return await _hasCompletedCodeExercise(userId, requiredExerciseId);
    }
    
    // Verificar logro por cantidad de ejercicios
    if (conditions.containsKey('completedCodeExercisesCount')) {
      final requiredCount = conditions['completedCodeExercisesCount'] as int;
      final completedCount = await _getCompletedCodeExercisesCount(userId);
      return completedCount >= requiredCount;
    }
    
    // Verificar logro por completar todos los ejercicios
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
    // Obtener total de ejercicios disponibles
    final exercisesSnapshot = await _firestore.collection('code_exercises').get();
    final totalExercises = exercisesSnapshot.size;
    
    // Obtener ejercicios completados por el usuario
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
      // debugPrint('Error al obtener estadísticas de enemigos: $e'); // REMOVIDO PARA PRODUCCIÓN
      return 0;
    }
  }

  Stream<List<Achievement>> getUnlockedAchievements(String userId) {
    // Leer siempre desde el campo unlockedAchievements del documento de usuario
    // debugPrint('DEBUG getUnlockedAchievements: Starting for userId: $userId'); // REMOVIDO PARA PRODUCCIÓN
    // debugPrint('DEBUG getUnlockedAchievements: shouldUseFirebase: ${AppConfig.shouldUseFirebase}'); // REMOVIDO PARA PRODUCCIÓN

    if (!AppConfig.shouldUseFirebase) {
      // debugPrint('DEBUG getUnlockedAchievements: Firebase disabled, using local storage'); // REMOVIDO PARA PRODUCCIÓN
      return _getUnlockedAchievementsLocal(userId);
    }

    return _firestore.collection('users').doc(userId).snapshots().asyncMap((
      doc,
    ) async {
      try {
        // debugPrint('DEBUG getUnlockedAchievements: Document exists: ${doc.exists}'); // REMOVIDO PARA PRODUCCIÓN
        final data = doc.data();
        // debugPrint('DEBUG getUnlockedAchievements: User data exists: ${data != null}'); // REMOVIDO PARA PRODUCCIÓN
        // debugPrint('DEBUG getUnlockedAchievements: Full user data: $data'); // REMOVIDO PARA PRODUCCIÓN

        final ids =
            data == null
                ? <String>[]
                : List<String>.from(
                  (data['unlockedAchievements'] as List<dynamic>?) ?? [],
                );

        // debugPrint('DEBUG getUnlockedAchievements: Found ${ids.length} achievement IDs: $ids'); // REMOVIDO PARA PRODUCCIÓN

        if (ids.isEmpty) {
          // debugPrint('DEBUG getUnlockedAchievements: No achievements found, returning empty list'); // REMOVIDO PARA PRODUCCIÓN
          return <Achievement>[];
        }

        // Firestore whereIn tiene límite de 10 elementos, dividir si es necesario
        final List<Achievement> allAchievements = [];

        // Procesar en lotes de 10 (límite de Firestore whereIn)
        for (int i = 0; i < ids.length; i += 10) {
          final batch = ids.skip(i).take(10).toList();
          // debugPrint('DEBUG getUnlockedAchievements: Querying batch: $batch'); // REMOVIDO PARA PRODUCCIÓN

          final snap =
              await _achievementsCol
                  .where(FieldPath.documentId, whereIn: batch)
                  .get();

          // debugPrint('DEBUG getUnlockedAchievements: Found ${snap.docs.length} achievements in batch'); // REMOVIDO PARA PRODUCCIÓN

          final batchAchievements =
              snap.docs
                  .map(
                    (d) =>
                        Achievement.fromMap(d.data() as Map<String, dynamic>),
                  )
                  .toList();

          allAchievements.addAll(batchAchievements);
        }

        // debugPrint('DEBUG getUnlockedAchievements: Total achievements loaded: ${allAchievements.length}'); // REMOVIDO PARA PRODUCCIÓN
        return allAchievements;
      } catch (e) {
        // debugPrint('ERROR getUnlockedAchievements: $e'); // REMOVIDO PARA PRODUCCIÓN
        return <Achievement>[];
      }
    });
  }

  // Implementación local de logros para cuando Firebase está deshabilitado
  Stream<List<Achievement>> _getUnlockedAchievementsLocal(String userId) {
    return Stream.fromFuture(_loadUnlockedAchievementsLocal(userId));
  }

  Future<List<Achievement>> _loadUnlockedAchievementsLocal(String userId) async {
    try {
      print('🔍 DEBUG: Cargando logros desbloqueados localmente para usuario: $userId');
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_${userId}_unlocked_achievements';
      final unlockedIds = prefs.getStringList(key) ?? [];
      print('📋 DEBUG: IDs de logros desbloqueados encontrados: $unlockedIds');
      
      if (unlockedIds.isEmpty) {
        print('⚠️ DEBUG: No hay logros desbloqueados');
        return <Achievement>[];
      }
      
      // Cargar todos los logros desde JSON
      final allAchievements = await _loadAchievementsFromLocalJson();
      print('📚 DEBUG: Total de logros cargados desde JSON: ${allAchievements.length}');
      
      // Filtrar solo los logros desbloqueados
      final unlockedAchievements = allAchievements
          .where((achievement) => unlockedIds.contains(achievement.id))
          .toList();
      
      print('🏆 DEBUG: Logros desbloqueados encontrados: ${unlockedAchievements.length}');
      for (final achievement in unlockedAchievements) {
        print('  - ${achievement.name} (${achievement.id})');
      }
      
      return unlockedAchievements;
    } catch (e) {
      print('❌ DEBUG: Error cargando logros desbloqueados localmente: $e');
      return <Achievement>[];
    }
  }

  Future<void> _checkAndUnlockMissionAchievementsLocal(
    String userId,
    String missionId,
  ) async {
    try {
      print('🔍 DEBUG: Iniciando verificación de logros de misión local para: $missionId');
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar logros desde JSON local
      final achievements = await _loadAchievementsFromLocalJson();
      print('📚 DEBUG: Cargados ${achievements.length} logros desde JSON');
      
      // Filtrar logros relacionados con misiones (incluyendo batallas)
      final missionAchievements = achievements.where((achievement) => 
        (achievement.achievementType == 'mission_completion' || achievement.achievementType == 'mission') &&
        achievement.requiredMissionIds.contains(missionId)
      ).toList();
      print('🎯 DEBUG: Encontrados ${missionAchievements.length} logros de misión para $missionId');

      for (final achievement in missionAchievements) {
        print('🔎 DEBUG: Verificando logro: ${achievement.name} (${achievement.id})');
        final isUnlocked = await _isAchievementUnlockedLocal(prefs, userId, achievement.id);
        print('🔓 DEBUG: Logro ya desbloqueado: $isUnlocked');
        
        if (!isUnlocked) {
          print('🏆 DEBUG: ¡Logro desbloqueado! ${achievement.name}');
          await _unlockAchievementForUserLocal(prefs, userId, achievement);
          // Mostrar notificación del logro
          _notificationService.showAchievementNotification(achievement);
        }
      }
    } catch (e) {
      print('❌ DEBUG: Error checking local mission achievements: $e');
    }
  }

  Future<void> _checkAndUnlockCodeExerciseAchievementsLocal(
    String userId,
    String exerciseId,
  ) async {
    try {
      print('🔍 DEBUG: Iniciando verificación de logros local para ejercicio: $exerciseId');
      final prefs = await SharedPreferences.getInstance();
      
      // Actualizar progreso local del usuario
      await _updateUserCodeExerciseProgressLocal(prefs, userId, exerciseId);
      print('✅ DEBUG: Progreso actualizado para ejercicio: $exerciseId');
      
      // Cargar logros desde JSON local
      final achievements = await _loadAchievementsFromLocalJson();
      print('📚 DEBUG: Cargados ${achievements.length} logros desde JSON');
      
      // Filtrar logros relacionados con ejercicios de código
      final codeExerciseAchievements = achievements.where((achievement) => 
        achievement.achievementType == 'code_exercise_completion' ||
        achievement.achievementType == 'code_exercise_milestone'
      ).toList();
      print('🎯 DEBUG: Encontrados ${codeExerciseAchievements.length} logros de ejercicios de código');

      for (final achievement in codeExerciseAchievements) {
        print('🔎 DEBUG: Verificando logro: ${achievement.name} (${achievement.id})');
        final isUnlocked = await _isAchievementUnlockedLocal(prefs, userId, achievement.id);
        print('🔓 DEBUG: Logro ya desbloqueado: $isUnlocked');
        
        if (!isUnlocked) {
          final conditionsMet = await _checkCodeExerciseAchievementConditionsLocal(prefs, userId, achievement);
          print('✔️ DEBUG: Condiciones cumplidas: $conditionsMet');
          
          if (conditionsMet) {
            await _unlockAchievementForUserLocal(prefs, userId, achievement);
            print('🏆 DEBUG: ¡Logro desbloqueado! ${achievement.name}');
            // Mostrar notificación del logro
            _notificationService.showAchievementNotification(achievement);
          }
        }
      }
    } catch (e) {
      print('❌ DEBUG: Error checking local code exercise achievements: $e');
    }
  }

  Future<void> _updateUserCodeExerciseProgressLocal(
    SharedPreferences prefs,
    String userId,
    String exerciseId,
  ) async {
    final key = 'user_${userId}_completed_exercises';
    final completedExercises = prefs.getStringList(key) ?? [];
    
    print('📝 DEBUG: Lista actual de ejercicios completados: $completedExercises');
    
    if (!completedExercises.contains(exerciseId)) {
      completedExercises.add(exerciseId);
      await prefs.setStringList(key, completedExercises);
      print('➕ DEBUG: Ejercicio $exerciseId agregado a la lista');
    } else {
      print('⚠️ DEBUG: Ejercicio $exerciseId ya estaba en la lista');
    }
    
    print('📋 DEBUG: Lista final de ejercicios completados: $completedExercises');
    
    await prefs.setString('user_${userId}_last_completed_exercise', exerciseId);
    await prefs.setInt('user_${userId}_last_activity', DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> _isAchievementUnlockedLocal(
    SharedPreferences prefs,
    String userId,
    String achievementId,
  ) async {
    final key = 'user_${userId}_unlocked_achievements';
    final unlockedAchievements = prefs.getStringList(key) ?? [];
    return unlockedAchievements.contains(achievementId);
  }

  Future<bool> _checkCodeExerciseAchievementConditionsLocal(
    SharedPreferences prefs,
    String userId,
    Achievement achievement,
  ) async {
    final conditions = achievement.conditions;
    print('🔍 DEBUG: Verificando condiciones para ${achievement.name}: $conditions');
    
    // Verificar logro por ejercicio específico
    if (conditions.containsKey('completedCodeExerciseId')) {
      final requiredExerciseId = conditions['completedCodeExerciseId'] as String;
      print('🎯 DEBUG: Verificando si se completó ejercicio específico: $requiredExerciseId');
      final result = await _hasCompletedCodeExerciseLocal(prefs, userId, requiredExerciseId);
      print('✅ DEBUG: Ejercicio $requiredExerciseId completado: $result');
      return result;
    }
    
    // Verificar logro por cantidad de ejercicios
    if (conditions.containsKey('completedCodeExercisesCount')) {
      final requiredCount = conditions['completedCodeExercisesCount'] as int;
      final completedCount = await _getCompletedCodeExercisesCountLocal(prefs, userId);
      print('📊 DEBUG: Ejercicios completados: $completedCount, requeridos: $requiredCount');
      return completedCount >= requiredCount;
    }
    
    // Verificar logro por completar todos los ejercicios
    if (conditions.containsKey('completedAllCodeExercises')) {
      final result = await _hasCompletedAllCodeExercisesLocal(prefs, userId);
      print('🎯 DEBUG: Todos los ejercicios completados: $result');
      return result;
    }
    
    print('❌ DEBUG: No se encontraron condiciones válidas');
    return false;
  }

  Future<bool> _hasCompletedCodeExerciseLocal(
    SharedPreferences prefs,
    String userId,
    String exerciseId,
  ) async {
    final key = 'user_${userId}_completed_exercises';
    final completedExercises = prefs.getStringList(key) ?? [];
    print('🔍 DEBUG: Buscando ejercicio "$exerciseId" en lista: $completedExercises');
    final result = completedExercises.contains(exerciseId);
    print('🎯 DEBUG: Ejercicio "$exerciseId" encontrado: $result');
    return result;
  }

  Future<int> _getCompletedCodeExercisesCountLocal(
    SharedPreferences prefs,
    String userId,
  ) async {
    final key = 'user_${userId}_completed_exercises';
    final completedExercises = prefs.getStringList(key) ?? [];
    return completedExercises.length;
  }

  Future<bool> _hasCompletedAllCodeExercisesLocal(
    SharedPreferences prefs,
    String userId,
  ) async {
    // Cargar ejercicios desde JSON local para obtener el total
    try {
      final exercisesJson = await rootBundle.loadString('assets/data/code_exercises.json');
      final exercisesList = json.decode(exercisesJson) as List<dynamic>;
      final totalExercises = exercisesList.length;
      
      final completedCount = await _getCompletedCodeExercisesCountLocal(prefs, userId);
      return completedCount >= totalExercises;
    } catch (e) {
      return false;
    }
  }

  Future<void> _unlockAchievementForUserLocal(
    SharedPreferences prefs,
    String userId,
    Achievement achievement,
  ) async {
    final key = 'user_${userId}_unlocked_achievements';
    final unlockedAchievements = prefs.getStringList(key) ?? [];
    
    if (!unlockedAchievements.contains(achievement.id)) {
      unlockedAchievements.add(achievement.id);
      await prefs.setStringList(key, unlockedAchievements);
      
      // Guardar fecha de desbloqueo
      await prefs.setInt(
        'user_${userId}_achievement_${achievement.id}_unlocked_at',
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}

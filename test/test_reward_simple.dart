import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Simulación simple del sistema de logros local
void main() async {
  debugPrint('=== Prueba del Sistema de Logros Local ===\n');
  
  // Simular datos de SharedPreferences
  Map<String, dynamic> mockPrefs = {};
  
  const userId = 'test_user_123';
  const exerciseId = 'variables_declaracion_asignacion';
  
  debugPrint('👤 Usuario: $userId');
  debugPrint('📝 Ejercicio a completar: $exerciseId\n');
  
  // Paso 1: Simular actualización del progreso
  debugPrint('📊 PASO 1: Actualizando progreso del usuario...');
  await updateUserCodeExerciseProgressLocal(mockPrefs, userId, exerciseId);
  
  final completedExercises = mockPrefs['user_${userId}_completed_exercises'] as List<String>? ?? [];
  debugPrint('✅ Ejercicios completados: $completedExercises\n');
  
  // Paso 2: Cargar logros desde JSON
  debugPrint('📚 PASO 2: Cargando logros desde JSON...');
  final achievements = await loadAchievementsFromLocalJson();
  debugPrint('📖 Total de logros cargados: ${achievements.length}');
  
  // Filtrar logros de ejercicios de código
  final codeAchievements = achievements.where((achievement) => 
    achievement['achievementType'] == 'code_exercise_completion' ||
    achievement['achievementType'] == 'code_exercise_milestone'
  ).toList();
  debugPrint('🎯 Logros de ejercicios de código: ${codeAchievements.length}\n');
  
  // Paso 3: Verificar condiciones de logros
  debugPrint('🔍 PASO 3: Verificando condiciones de logros...');
  
  for (final achievement in codeAchievements) {
    final achievementId = achievement['id'] as String;
    final achievementName = achievement['name'] as String;
    final conditions = achievement['conditions'] as Map<String, dynamic>;
    
    debugPrint('\n🏆 Verificando: $achievementName ($achievementId)');
    debugPrint('📋 Condiciones: $conditions');
    
    // Verificar si ya está desbloqueado
    final isUnlocked = isAchievementUnlockedLocal(mockPrefs, userId, achievementId);
    debugPrint('🔓 Ya desbloqueado: $isUnlocked');
    
    if (!isUnlocked) {
      // Verificar condiciones
      bool conditionsMet = false;
      
      if (conditions.containsKey('completedCodeExerciseId')) {
        final requiredExerciseId = conditions['completedCodeExerciseId'] as String;
        conditionsMet = hasCompletedCodeExerciseLocal(mockPrefs, userId, requiredExerciseId);
        debugPrint('✔️ Ejercicio requerido ($requiredExerciseId) completado: $conditionsMet');
      }
      
      if (conditionsMet) {
        unlockAchievementForUserLocal(mockPrefs, userId, achievement);
        debugPrint('🎉 ¡LOGRO DESBLOQUEADO: $achievementName!');
      } else {
        debugPrint('❌ Condiciones no cumplidas');
      }
    }
  }
  
  // Mostrar estado final
  debugPrint('\n=== ESTADO FINAL ===');
  final finalCompleted = mockPrefs['user_${userId}_completed_exercises'] as List<String>? ?? [];
  final finalUnlocked = mockPrefs['user_${userId}_unlocked_achievements'] as List<String>? ?? [];
  
  debugPrint('📝 Ejercicios completados: $finalCompleted');
  debugPrint('🏆 Logros desbloqueados: $finalUnlocked');
  debugPrint('\n=== Prueba Completada ===');
}

// Funciones auxiliares simuladas
Future<void> updateUserCodeExerciseProgressLocal(
  Map<String, dynamic> prefs,
  String userId,
  String exerciseId,
) async {
  final key = 'user_${userId}_completed_exercises';
  final completedExercises = prefs[key] as List<String>? ?? <String>[];
  
  if (!completedExercises.contains(exerciseId)) {
    completedExercises.add(exerciseId);
    prefs[key] = completedExercises;
  }
  
  prefs['user_${userId}_last_completed_exercise'] = exerciseId;
  prefs['user_${userId}_last_activity'] = DateTime.now().millisecondsSinceEpoch;
}

bool isAchievementUnlockedLocal(
  Map<String, dynamic> prefs,
  String userId,
  String achievementId,
) {
  final key = 'user_${userId}_unlocked_achievements';
  final unlockedAchievements = prefs[key] as List<String>? ?? <String>[];
  return unlockedAchievements.contains(achievementId);
}

bool hasCompletedCodeExerciseLocal(
  Map<String, dynamic> prefs,
  String userId,
  String exerciseId,
) {
  final key = 'user_${userId}_completed_exercises';
  final completedExercises = prefs[key] as List<String>? ?? <String>[];
  return completedExercises.contains(exerciseId);
}

void unlockAchievementForUserLocal(
  Map<String, dynamic> prefs,
  String userId,
  Map<String, dynamic> achievement,
) {
  final key = 'user_${userId}_unlocked_achievements';
  final unlockedAchievements = prefs[key] as List<String>? ?? <String>[];
  final achievementId = achievement['id'] as String;
  
  if (!unlockedAchievements.contains(achievementId)) {
    unlockedAchievements.add(achievementId);
    prefs[key] = unlockedAchievements;
  }
  
  prefs['user_${userId}_achievement_${achievementId}_unlocked_at'] = DateTime.now().millisecondsSinceEpoch;
}

Future<List<Map<String, dynamic>>> loadAchievementsFromLocalJson() async {
  try {
    final file = File('assets/data/achievements_data.json');
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  } catch (e) {
    debugPrint('❌ Error cargando logros: $e');
    return [];
  }
}

// ignore_for_file: avoid_print

import '../services/reward_service.dart';
import 'package:codequest/models/achievement_model.dart';
import 'package:codequest/models/reward_model.dart';

class InitialData {
  static final RewardService _rewardService = RewardService(); // Hacer estático

  static Future<void> createInitialData() async {
    // Crear recompensas iniciales
    await _createInitialRewards();
    
    // Crear logros iniciales
    await _createInitialAchievements();
  }

  static Future<void> _createInitialRewards() async {
    try {
      // Recompensa 1: Monedas
      final reward1 = Reward(
        id: 'reward_coins_50',
        name: '50 Monedas',
        description: 'Una pequeña cantidad de monedas de oro',
        type: 'coins',
        value: 50,
        iconUrl: '',
        conditions: {},
      );
      await _rewardService.createReward(reward1);

      // Recompensa 2: Experiencia
      final reward2 = Reward(
        id: 'reward_exp_100',
        name: '100 Experiencia',
        description: 'Puntos de experiencia adicionales',
        type: 'experience',
        value: 100,
        iconUrl: '',
        conditions: {},
      );
      await _rewardService.createReward(reward2);

      // Recompensas iniciales creadas exitosamente
    } catch (e) {
      // Error al crear recompensas iniciales: $e
    }
  }

  static Future<void> _createInitialAchievements() async {
    try {
      // Logro 1: Primer enemigo derrotado
      final achievement1 = Achievement(
        id: 'achievement_first_enemy',
        name: 'Primer Adversario',
        description: 'Derrota tu primer enemigo de programación',
        iconUrl: '',
        category: 'enemy',
        points: 10,
        conditions: {
          'enemyId': 'enemigo_error_de_java',
          'count': 1,
        },
        requiredMissionIds: [],
        rewardId: 'reward_coins_50',
      );
      await _rewardService.createAchievement(achievement1);

      // Logro 2: Cazador de bugs
      final achievement2 = Achievement(
        id: 'achievement_bug_hunter',
        name: 'Cazador de Bugs',
        description: 'Derrota 3 enemigos de programación',
        iconUrl: '',
        category: 'combat',
        points: 25,
        conditions: {
          'type': 'total_enemies_defeated',
          'count': 3,
        },
        requiredMissionIds: [],
        rewardId: 'reward_exp_100',
      );
      await _rewardService.createAchievement(achievement2);

      // Logros iniciales creados exitosamente
    } catch (e) {
      // Error al crear logros iniciales: $e
    }
  }
}

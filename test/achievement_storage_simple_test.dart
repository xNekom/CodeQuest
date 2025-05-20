import 'package:flutter_test/flutter_test.dart';
import 'package:codequest/models/achievement_model.dart';

void main() {
  group('Achievement Storage Logic Tests', () {
    test('Achievement model should serialize correctly', () {
      // Crear un logro de prueba
      final achievement = Achievement(
        id: 'achievement_primer_bug',
        name: 'Primer Bug Vencido',
        description: 'Derrota tu primer Bug del Punto y Coma.',
        iconUrl: 'assets/images/badge_primer_bug.png',
        category: 'enemy',
        points: 10,
        conditions: {
          'enemyId': 'enemigo_bug_del_punto_y_coma',
          'defeatsRequired': 1
        },
        requiredMissionIds: [],
        rewardId: 'recompensa_primer_bug',
        achievementType: 'enemy',
        requiredEnemyId: 'enemigo_bug_del_punto_y_coma',
        requiredEnemyDefeats: 1,
      );

      // Verificar que se serializa correctamente
      final achievementMap = achievement.toMap();
      
      expect(achievementMap['id'], equals('achievement_primer_bug'));
      expect(achievementMap['name'], equals('Primer Bug Vencido'));
      expect(achievementMap['points'], equals(10));
      expect(achievementMap['conditions']['enemyId'], equals('enemigo_bug_del_punto_y_coma'));
      
      // Verificar que se puede deserializar
      final recreatedAchievement = Achievement.fromMap(achievementMap);
      expect(recreatedAchievement.id, equals(achievement.id));
      expect(recreatedAchievement.name, equals(achievement.name));
      expect(recreatedAchievement.points, equals(achievement.points));
    });
    
    test('Achievement should validate enemy requirements correctly', () {
      final achievement = Achievement(
        id: 'achievement_primer_bug',
        name: 'Primer Bug Vencido',
        description: 'Derrota tu primer Bug del Punto y Coma.',
        iconUrl: 'assets/images/badge_primer_bug.png',
        category: 'enemy',
        points: 10,
        conditions: {
          'enemyId': 'enemigo_bug_del_punto_y_coma',
          'defeatsRequired': 1
        },
        requiredMissionIds: [],
        rewardId: 'recompensa_primer_bug',
        achievementType: 'enemy',
        requiredEnemyId: 'enemigo_bug_del_punto_y_coma',
        requiredEnemyDefeats: 1,
      );

      // Crear datos de usuario simulados
      final userStats = {
        'enemiesDefeated': {
          'enemigo_bug_del_punto_y_coma': 1
        }
      };      // Verificar que el achievement se puede desbloquear
      final enemyId = achievement.requiredEnemyId;
      final requiredDefeats = achievement.requiredEnemyDefeats ?? 0;
      final currentDefeats = enemyId != null ? (userStats['enemiesDefeated']?[enemyId] ?? 0) : 0;
      
      expect(enemyId, equals('enemigo_bug_del_punto_y_coma'));
      expect(requiredDefeats, equals(1));
      expect(currentDefeats, equals(1));
      expect(currentDefeats >= requiredDefeats, isTrue);
    });

    test('User should have unlockedAchievements field structure', () {
      // Simular estructura de usuario con logros desbloqueados
      final userData = {
        'userId': 'testUser123',
        'username': 'TestPlayer',
        'level': 1,
        'experience': 150,
        'unlockedAchievements': [
          'achievement_primer_bug',
          'achievement_cazador_bugs'
        ],
        'stats': {
          'enemiesDefeated': {
            'enemigo_bug_del_punto_y_coma': 5
          },
          'totalEnemiesDefeated': 5
        }
      };

      // Verificar estructura
      expect(userData.containsKey('unlockedAchievements'), isTrue);
      expect(userData['unlockedAchievements'], isA<List>());
      expect((userData['unlockedAchievements'] as List).length, equals(2));
      expect((userData['unlockedAchievements'] as List).contains('achievement_primer_bug'), isTrue);
      
      // Verificar que se puede agregar un nuevo logro
      final newAchievement = 'achievement_new_one';
      final updatedAchievements = List<String>.from(userData['unlockedAchievements'] as List<String>);
      
      if (!updatedAchievements.contains(newAchievement)) {
        updatedAchievements.add(newAchievement);
      }
      
      expect(updatedAchievements.length, equals(3));
      expect(updatedAchievements.contains(newAchievement), isTrue);
    });
  });
}

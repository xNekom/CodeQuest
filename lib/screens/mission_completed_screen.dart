// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../models/reward_model.dart';
import '../widgets/achievement_card.dart';
import '../widgets/pixel_widgets.dart';
import '../theme/pixel_theme.dart';

class MissionCompletedScreen extends StatelessWidget {
  final String missionId;
  final String missionName;
  final Achievement? unlockedAchievement;
  final Reward? earnedReward;
  final int experiencePoints;
  final int coinsEarned;
  final bool isBattleMission;
  final VoidCallback onContinue;

  const MissionCompletedScreen({
    super.key,
    required this.missionId,
    required this.missionName,
    this.unlockedAchievement,
    this.earnedReward,
    required this.experiencePoints,
    this.coinsEarned = 100,
    this.isBattleMission = false,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PixelTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PixelTheme.accentColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: PixelTheme.accentColor.withValues(alpha: 0.6),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                '¡MISIÓN COMPLETADA!',
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                missionName,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Recompensas obtenidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Experiencia ganada
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.amber,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$experiencePoints',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const Text(
                          'XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Monedas ganadas
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.yellow.shade700,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.yellow.shade700,
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$coinsEarned',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow.shade700,
                          ),
                        ),
                        Text(
                          'Monedas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.yellow.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Tipo de misión completada
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isBattleMission ? Colors.red.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isBattleMission ? Colors.red : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Text(
                  isBattleMission ? '🗡️ Misión de Batalla' : '📚 Misión de Teoría',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isBattleMission ? Colors.red : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Logro desbloqueado (si existe)
              if (unlockedAchievement != null) ...[
                Text(
                  '¡Nuevo Logro Desbloqueado!',
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                AchievementCard(
                  achievement: unlockedAchievement!,
                  isUnlocked: true,
                ),
                const SizedBox(height: 20),
              ],
              
              // Recompensa obtenida (si existe)
              if (earnedReward != null) ...[
                Text(
                  '¡Recompensa Obtenida!',
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildRewardItem(context, earnedReward!),
                const SizedBox(height: 20),
              ],
              
              // Botón de continuar
              PixelButton(
                onPressed: onContinue,
                color: PixelTheme.accentColor,
                width: 180,
                height: 50,
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, Reward reward) {
    Color rewardColor = Colors.purple; // Inicializar con valor por defecto
    IconData rewardIcon = Icons.card_giftcard; // Inicializar con valor por defecto
    String rewardText = 'Recompensa'; // Inicializar con valor por defecto

    switch (reward.type.toLowerCase()) {
      case 'points':
        rewardColor = Colors.amber;
        rewardIcon = Icons.star;
        rewardText = '+${reward.value} puntos';
        break;
      case 'item':
        rewardColor = Colors.blue;
        rewardIcon = Icons.inventory_2;
        rewardText = 'Nuevo item';
        break;
      case 'badge':
        rewardColor = Colors.orange;
        rewardIcon = Icons.emoji_events;
        rewardText = 'Nueva insignia';
        break;
      case 'coins':
        rewardColor = Colors.yellow;
        rewardIcon = Icons.monetization_on;
        rewardText = '+${reward.value} monedas';
        break;
      case 'experience':
        rewardColor = Colors.green;
        rewardIcon = Icons.trending_up;
        rewardText = '+${reward.value} experiencia';
        break;
      default:
        // Ya inicializados arriba
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rewardColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rewardColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: rewardColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Image.network(
                reward.iconUrl,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    rewardIcon,
                    color: rewardColor,
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rewardText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: rewardColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

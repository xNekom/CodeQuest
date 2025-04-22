import 'package:codequest/models/achievement_model.dart';
import 'package:codequest/models/reward_model.dart';
import 'package:codequest/services/reward_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:codequest/firebase_options.dart';

Future<void> seedInitialData() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final rewardService = RewardService();

  // Recompensas
  final r1 = Reward(
    id: 'puntos_novato_100',
    name: '100 Puntos de Experiencia',
    description: '¡Bien hecho! Aquí tienes 100 puntos para empezar.',
    iconUrl: 'assets/images/rewards/points_icon.png',
    type: RewardType.points,
    value: 100,
  );
  await rewardService.createReward(r1);

  final r2 = Reward(
    id: 'insignia_explorador_alpha',
    name: 'Insignia del Explorador Alpha',
    description: 'Otorgada por ser uno de los primeros en explorar CodeQuest.',
    iconUrl: 'assets/images/achievements/founder_explorer_ach.png',
    type: RewardType.badge,
    value: 1,
  );
  await rewardService.createReward(r2);

  final r3 = Reward(
    id: 'item_pocion_sabiduria_p',
    name: 'Poción de Sabiduría (Pequeña)',
    description: 'Un pequeño impulso a tu conocimiento. ¡Úsala sabiamente!',
    iconUrl: 'assets/images/items/potion_wisdom_small.png',
    type: RewardType.item,
    value: 101,
  );
  await rewardService.createReward(r3);

  // Logros
  final a1 = Achievement(
    id: 'logro_primeros_pasos',
    name: 'Primeros Pasos',
    description: 'Completa tu primera misión en CodeQuest.',
    iconUrl: 'assets/images/achievements/first_steps_ach.png',
    requiredMissionIds: ['mision_intro_1'],
    rewardId: r1.id,
  );
  await rewardService.createAchievement(a1);

  final a2 = Achievement(
    id: 'logro_explorador_fundador',
    name: 'Explorador Fundador',
    description: 'Completa la misión de bienvenida durante la fase alpha.',
    iconUrl: 'assets/images/achievements/founder_explorer_ach.png',
    requiredMissionIds: ['mision_bienvenida_alpha'],
    rewardId: r2.id,
  );
  await rewardService.createAchievement(a2);

  print('Initial data seeded successfully.');
}

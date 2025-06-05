import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../services/mission_service.dart';
import '../../models/mission_model.dart';
import 'theory_screen.dart';
import '../game/enemy_encounter_screen.dart';
import 'question_screen.dart';
import '../../widgets/pixel_widgets.dart';
import '../../utils/custom_page_route.dart'; // Import FadePageRoute
import '../../services/tutorial_service.dart';
import '../../widgets/tutorial_floating_button.dart';

/// Pantalla de detalle de misión y primer paso de aventura
class MissionDetailScreen extends StatefulWidget {
  final String missionId;

  const MissionDetailScreen({super.key, required this.missionId});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _missionTitleKey = GlobalKey();
  final GlobalKey _missionDescriptionKey = GlobalKey();
  final GlobalKey _startMissionButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Verificar si debemos mostrar el tutorial
    Future.microtask(() {
      if (mounted) {
        _checkAndStartTutorial();
      }
    });
  }

  void _checkAndStartTutorial() {
    TutorialService.startTutorialIfNeeded(
      context,
      TutorialService.missionDetailTutorial,
      TutorialService.getMissionDetailTutorial(
        descriptionKey: _missionDescriptionKey,
        startButtonKey: _startMissionButtonKey,
      ),
    );
  }

  /// Navega al ejercicio correspondiente después de completar la teoría
  void _navigateToExercise(MissionModel mission) {
    // Buscar el primer objetivo de tipo 'questions'
    final questionObjective = mission.objectives.firstWhere(
      (obj) => obj.type == 'questions',
      orElse: () => mission.objectives.first,
    );

    if (questionObjective.type == 'questions' &&
        questionObjective.questionIds.isNotEmpty) {
      // Navegar a la pantalla de preguntas
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  QuestionScreen(missionId: mission.missionId, isReplay: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Misión')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/background_mission.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          MissionService().getMissionById(widget.missionId),
          UserService().getUserData(
            FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null || data.length < 2) {
            return const Center(child: Text('Error al cargar datos'));
          }

          final mission = data[0] as MissionModel?;
          final userData = data[1] as Map<String, dynamic>?;

          if (mission == null) {
            return const Center(child: Text('Misión no encontrada'));
          }

          // Verificar si la misión ya está completada
          final List<String> completedMissions = List<String>.from(
            userData?['completedMissions'] ?? [],
          );
          final bool isMissionCompleted = completedMissions.contains(
            widget.missionId,
          );

          final name = mission.name;
          final description = mission.description;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    key: _missionTitleKey,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    key: _missionDescriptionKey,
                  ),
                ),
                const SizedBox(height: 24),
                if (isMissionCompleted)
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Misión Completada!',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ya has completado esta misión y recibido las recompensas.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withValues(alpha: 0.8),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                         ),
                         const SizedBox(height: 16),
                        PixelButton(
                          onPressed: () {
                            // Permitir repetir la lección sin recompensas
                            // Verificar si es una misión de batalla
                            final firstObjective =
                                mission.objectives.isNotEmpty
                                    ? mission.objectives.first
                                    : null;

                            if (firstObjective?.type == 'batalla' &&
                                firstObjective?.battleConfig != null) {
                              // Navegar directamente a la pantalla de encuentro con enemigo
                              Navigator.push(
                                context,
                                FadePageRoute(
                                  builder:
                                      (_) => EnemyEncounterScreen(
                                        battleConfig:
                                            firstObjective!.battleConfig!,
                                        isReplay:
                                            true, // Indicar que es una repetición
                                      ),
                                ),
                              );
                            } else {
                              // Navegar a la pantalla de teoría
                              Navigator.push(
                                context,
                                FadePageRoute(
                                  builder:
                                      (_) => TheoryScreen(
                                        missionId: widget.missionId,
                                        theoryText: mission.theory,
                                        examples: mission.examples,
                                        storyPages: mission.storyPages,
                                        isReplay:
                                            true, // Indicar que es una repetición
                                      ),
                                ),
                              );
                            }
                          },
                          child: const Text('Repetir Lección'),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: PixelButton(
                      key: _startMissionButtonKey,
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await UserService().startMission(
                            user.uid,
                            widget.missionId,
                          );
                        }
                        if (!context.mounted) return;

                        // Verificar si es una misión de batalla
                        final firstObjective =
                            mission.objectives.isNotEmpty
                                ? mission.objectives.first
                                : null;

                        if (firstObjective?.type == 'batalla' &&
                            firstObjective?.battleConfig != null) {
                          // Navegar directamente a la pantalla de encuentro con enemigo
                          Navigator.push(
                            context,
                            FadePageRoute(
                              builder:
                                  (_) => EnemyEncounterScreen(
                                    battleConfig: firstObjective!.battleConfig!,
                                    isReplay: false,
                                  ),
                            ),
                          );
                        } else {
                          // Navegar a la pantalla de teoría tradicional
                          final result = await Navigator.push(
                            context,
                            FadePageRoute(
                              builder:
                                  (_) => TheoryScreen(
                                    missionId: widget.missionId,
                                    theoryText: mission.theory,
                                    examples: mission.examples,
                                    storyPages: mission.storyPages,
                                    isReplay: false,
                                  ),
                            ),
                          );

                          // Si se completó la teoría, navegar al ejercicio
                          if (result == true && context.mounted) {
                            _navigateToExercise(mission);
                          }
                        }
                      },
                      child: const Text('Iniciar Misión'),
                    ),
                  ),
              ],
            ),
          );
        },
        ),
      ),
      floatingActionButton: TutorialFloatingButton(
        onTutorialStart: () {
          TutorialService.showTutorialDialog(
            context,
            TutorialService.getMissionDetailTutorial(
              descriptionKey: _missionDescriptionKey,
              startButtonKey: _startMissionButtonKey,
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../services/mission_service.dart';
import '../../models/mission_model.dart';
import './theory_screen.dart';
import '../game/enemy_encounter_screen.dart';
import '../../widgets/pixel_widgets.dart';
import '../../utils/custom_page_route.dart'; // Import FadePageRoute

/// Pantalla de detalle de misión y primer paso de aventura
class MissionDetailScreen extends StatelessWidget {
  final String missionId;

  const MissionDetailScreen({super.key, required this.missionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Misión')),
      body: FutureBuilder<MissionModel?>(
        future: MissionService().getMissionById(missionId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar misión: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final mission = snapshot.data;
          if (mission == null) {
            return const Center(child: Text('Misión no encontrada')); 
          }

          final name = mission.name;
          final description = mission.description;
          final theory = mission.theory ?? 'Sin teoría disponible.';
          final examples = mission.examples ?? <String>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(description),
                const SizedBox(height: 24),                Center(
                  child: PixelButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await UserService().startMission(user.uid, missionId);
                      }
                      if (!context.mounted) return;
                      
                      // Verificar si es una misión de batalla
                      final firstObjective = mission.objectives.isNotEmpty ? mission.objectives.first : null;
                      
                      if (firstObjective?.type == 'batalla' && firstObjective?.battleConfig != null) {
                        // Navegar directamente a la pantalla de encuentro con enemigo
                        Navigator.push(
                          context,
                          FadePageRoute(
                            builder: (_) => EnemyEncounterScreen(
                              battleConfig: firstObjective!.battleConfig!,
                            ),
                          ),
                        );
                      } else {
                        // Navegar a la pantalla de teoría tradicional
                        Navigator.push(
                          context,
                          FadePageRoute(
                            builder: (_) => TheoryScreen(
                              missionId: missionId,
                              theoryText: theory,
                              examples: examples,
                            ),
                          ),
                        );
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
    );
  }
}

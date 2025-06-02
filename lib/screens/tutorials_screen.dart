import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';
import '../widgets/pixel_widgets.dart';
import '../utils/error_handler.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  final TutorialService _tutorialService = TutorialService();
  
  // GlobalKeys para los tutoriales (necesarios para algunos tutoriales)
  final GlobalKey _dummyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoriales'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona un tutorial para aprender:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildTutorialCard(
                        title: 'Tutorial de Pantalla Principal',
                        description: 'Aprende a navegar por la pantalla principal y conoce todas sus funciones.',
                        icon: Icons.home,
                        onTap: () => _startHomeScreenTutorial(),
                        tutorialKey: TutorialService.homeScreenTutorial,
                      ),
                      const SizedBox(height: 12),
                      _buildTutorialCard(
                        title: 'Tutorial de Misiones',
                        description: 'Descubre cómo acceder y completar misiones para ganar experiencia.',
                        icon: Icons.assignment,
                        onTap: () => _startMissionsTutorial(),
                        tutorialKey: 'missions_tutorial',
                      ),
                      const SizedBox(height: 12),
                      _buildTutorialCard(
                        title: 'Tutorial de Logros',
                        description: 'Conoce el sistema de logros y cómo desbloquear nuevos achievements.',
                        icon: Icons.emoji_events,
                        onTap: () => _startAchievementsTutorial(),
                        tutorialKey: 'achievements_tutorial',
                      ),
                      const SizedBox(height: 12),
                      _buildTutorialCard(
                        title: 'Tutorial de Ejercicios de Código',
                        description: 'Aprende a resolver ejercicios de programación y mejorar tus habilidades.',
                        icon: Icons.code,
                        onTap: () => _startCodeExercisesTutorial(),
                        tutorialKey: 'code_exercises_tutorial',
                      ),
                      const SizedBox(height: 12),
                      _buildTutorialCard(
                        title: 'Tutorial de Tienda',
                        description: 'Descubre cómo comprar items y mejorar tu equipamiento.',
                        icon: Icons.shopping_cart,
                        onTap: () => _startShopTutorial(),
                        tutorialKey: 'shop_tutorial',
                      ),
                      const SizedBox(height: 12),
                      _buildTutorialCard(
                        title: 'Tutorial de Inventario',
                        description: 'Gestiona tus items y equipamiento de manera eficiente.',
                        icon: Icons.inventory,
                        onTap: () => _startInventoryTutorial(),
                        tutorialKey: 'inventory_tutorial',
                      ),
                      const SizedBox(height: 12),
                      _buildTutorialCard(
                        title: 'Tutorial de Tabla de Posiciones',
                        description: 'Compite con otros jugadores y sube en el ranking.',
                        icon: Icons.leaderboard,
                        onTap: () => _startLeaderboardTutorial(),
                        tutorialKey: 'leaderboard_tutorial',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required String tutorialKey,
  }) {
    return FutureBuilder<bool>(
      future: _tutorialService.isTutorialCompleted(tutorialKey),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        
        return PixelCard(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green.withOpacity(0.2)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted 
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: isCompleted 
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCompleted ? 'Completado' : 'Toca para iniciar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isCompleted 
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startHomeScreenTutorial() {
    try {
      // Navegar de vuelta al home y mostrar el tutorial
      Navigator.pop(context);
      
      // Esperar un momento para que la navegación se complete
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          TutorialService.showTutorialDialog(
            context,
            TutorialService.getHomeScreenTutorial(
              profileKey: _dummyKey,
              missionsKey: _dummyKey,
              achievementsKey: _dummyKey,
              leaderboardKey: _dummyKey,
              adventureButtonKey: _dummyKey,
              shopButtonKey: _dummyKey,
              inventoryButtonKey: _dummyKey,
              codeExercisesButtonKey: _dummyKey,
            ),
            tutorialKey: TutorialService.homeScreenTutorial,
          );
        }
      });
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      _showErrorMessage('Error al iniciar el tutorial de pantalla principal');
    }
  }

  void _startMissionsTutorial() {
    try {
      Navigator.pushNamed(context, '/missions').then((_) {
        // Cuando regrese de misiones, mostrar mensaje
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutorial de misiones disponible en la pantalla de misiones'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      _showErrorMessage('Error al navegar a misiones');
    }
  }

  void _startAchievementsTutorial() {
    try {
      Navigator.pushNamed(context, '/achievements').then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutorial de logros disponible en la pantalla de logros'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      _showErrorMessage('Error al navegar a logros');
    }
  }

  void _startCodeExercisesTutorial() {
    try {
      Navigator.pushNamed(context, '/code-exercises').then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutorial de ejercicios disponible en la pantalla de código'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      _showErrorMessage('Error al navegar a ejercicios de código');
    }
  }

  void _startShopTutorial() {
    try {
      Navigator.pushNamed(context, '/shop').then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutorial de tienda disponible en la pantalla de tienda'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      _showErrorMessage('Error al navegar a la tienda');
    }
  }

  void _startInventoryTutorial() {
    try {
      Navigator.pushNamed(context, '/inventory').then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutorial de inventario disponible en la pantalla de inventario'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      _showErrorMessage('Error al navegar al inventario');
    }
  }

  void _startLeaderboardTutorial() {
    try {
      Navigator.pushNamed(context, '/leaderboard').then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutorial de tabla de posiciones disponible en esa pantalla'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current);
      _showErrorMessage('Error al navegar a la tabla de posiciones');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/interactive_tutorial.dart';

class TutorialService {
  static const String _homeScreenTutorialKey = 'home_screen_tutorial_completed';
  static const String _characterSelectionTutorialKey =
      'character_selection_tutorial_completed';
  static const String _missionsTutorialKey = 'missions_tutorial_completed';
  static const String _achievementsTutorialKey =
      'achievements_tutorial_completed';
  static const String _missionDetailTutorialKey =
      'mission_detail_tutorial_completed';
  static const String _theoryScreenTutorialKey =
      'theory_screen_tutorial_completed';

  // Singleton pattern
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  /// Verifica si un tutorial específico ya fue completado
  Future<bool> isTutorialCompleted(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(tutorialKey) ?? false;
  }

  /// Marca un tutorial como completado
  Future<void> markTutorialCompleted(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(tutorialKey, true);
  }

  /// Resetea todos los tutoriales (para pruebas)
  Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeScreenTutorialKey);
    await prefs.remove(_characterSelectionTutorialKey);
    await prefs.remove(_missionsTutorialKey);
    await prefs.remove(_achievementsTutorialKey);
    await prefs.remove(_missionDetailTutorialKey);
    await prefs.remove(_theoryScreenTutorialKey);
  }

  /// Tutorial para la pantalla principal (HomeScreen)
  static List<InteractiveTutorialStep> getHomeScreenTutorial({
    GlobalKey? profileKey,
    GlobalKey? missionsKey,
    GlobalKey? achievementsKey,
    GlobalKey? leaderboardKey,
    GlobalKey? adventureButtonKey,
    GlobalKey? shopButtonKey,
    GlobalKey? inventoryButtonKey,
    GlobalKey? codeExercisesButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido a CodeQuest! 🎮',
        description:
            'Te guiaremos a través de las funciones principales de la aplicación. ¡Comencemos!',
        icon: Icons.waving_hand,
        showPulse: false,
      ),
      if (profileKey != null)
        InteractiveTutorialStep(
          title: 'Tu Perfil de Aventurero',
          description:
              'Aquí puedes ver tu información personal, nivel, experiencia y estadísticas del juego.',
          icon: Icons.person,
          targetKey: profileKey,
          showPulse: true,
        ),
      if (missionsKey != null)
        InteractiveTutorialStep(
          title: 'Estadísticas',
          description:
              'Revisa tus estadísticas de juego, incluyendo preguntas contestadas, respuestas correctas y batallas ganadas.',
          icon: Icons.bar_chart,
          targetKey: missionsKey,
          showPulse: true,
        ),
      if (adventureButtonKey != null)
        InteractiveTutorialStep(
          title: 'Comenzar Aventura',
          description:
              'Pulsa aquí para acceder a todas las misiones disponibles y comenzar tu aventura de programación.',
          icon: Icons.sports_esports,
          targetKey: adventureButtonKey,
          showPulse: true,
        ),
      if (codeExercisesButtonKey != null)
        InteractiveTutorialStep(
          title: 'Ejercicios de Código',
          description:
              'Practica tus habilidades de programación con ejercicios interactivos y desafíos de código.',
          icon: Icons.code,
          targetKey: codeExercisesButtonKey,
          showPulse: true,
        ),
      if (shopButtonKey != null)
        InteractiveTutorialStep(
          title: 'Tienda',
          description:
              'Visita la tienda para comprar objetos y mejoras con las monedas que ganes.',
          icon: Icons.store,
          targetKey: shopButtonKey,
          showPulse: true,
        ),
      if (inventoryButtonKey != null)
        InteractiveTutorialStep(
          title: 'Inventario',
          description:
              'Accede a tu inventario para ver y usar los objetos que has adquirido.',
          icon: Icons.inventory_2,
          targetKey: inventoryButtonKey,
          showPulse: true,
        ),
      if (leaderboardKey != null)
        InteractiveTutorialStep(
          title: 'Tabla de Clasificación',
          description:
              'Compite con otros jugadores y ve tu posición en la tabla de clasificación global.',
          icon: Icons.leaderboard,
          targetKey: leaderboardKey,
          showPulse: true,
        ),
      if (achievementsKey != null)
        InteractiveTutorialStep(
          title: 'Logros',
          description:
              'Consulta todos los logros que has desbloqueado y los que aún puedes conseguir.',
          icon: Icons.emoji_events,
          targetKey: achievementsKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: '¡Listo para Comenzar!',
        description:
            'Ahora estás listo para comenzar tu aventura de programación. ¡Buena suerte!',
        icon: Icons.play_arrow,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para la pantalla de selección de personaje
  static List<InteractiveTutorialStep> getCharacterSelectionTutorial({
    GlobalKey? characterPreviewKey,
    GlobalKey? customizationKey,
    GlobalKey? saveButtonKey,
    GlobalKey? confirmKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: 'Crea tu Personaje 🧙',
        description:
            'Personaliza tu avatar para comenzar tu aventura en el mundo de la programación.',
        icon: Icons.person_add,
        showPulse: false,
      ),
      if (characterPreviewKey != null)
        InteractiveTutorialStep(
          title: 'Vista Previa',
          description:
              'Aquí puedes ver cómo se verá tu personaje con las opciones seleccionadas.',
          icon: Icons.visibility,
          targetKey: characterPreviewKey,
          showPulse: true,
        ),

      if (customizationKey != null)
        InteractiveTutorialStep(
          title: 'Personalización',
          description:
              'Customiza la apariencia de tu personaje: tono de piel, peinado y vestimenta.',
          icon: Icons.palette,
          targetKey: customizationKey,
          showPulse: true,
        ),
      if (saveButtonKey != null || confirmKey != null)
        InteractiveTutorialStep(
          title: 'Guardar Personaje',
          description:
              'Una vez que estés satisfecho con tu creación, toca aquí para comenzar tu aventura.',
          icon: Icons.check_circle,
          targetKey: saveButtonKey ?? confirmKey,
          showPulse: true,
        ),
    ];
  }

  /// Tutorial para la pantalla de misiones
  static List<InteractiveTutorialStep> getMissionsTutorial({
    GlobalKey? missionListKey,
    GlobalKey? firstMissionKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: 'Centro de Misiones 📜',
        description:
            'Aquí encontrarás todas las misiones disponibles para mejorar tus habilidades de programación.',
        icon: Icons.assignment,
        showPulse: false,
      ),
      if (missionListKey != null)
        InteractiveTutorialStep(
          title: 'Lista de Misiones',
          description:
              'Explora todas las misiones disponibles. Las misiones se desbloquean a medida que subes de nivel.',
          icon: Icons.list,
          targetKey: missionListKey,
          showPulse: true,
        ),
      if (firstMissionKey != null)
        InteractiveTutorialStep(
          title: 'Acepta tu Primera Misión',
          description:
              'Toca cualquier misión para ver los detalles y comenzar a resolverla.',
          icon: Icons.play_arrow,
          targetKey: firstMissionKey,
          showPulse: true,
        ),
    ];
  }

  /// Tutorial para la pantalla de logros
  static List<InteractiveTutorialStep> getAchievementsTutorial({
    GlobalKey? achievementGridKey,
    GlobalKey? progressKey,
    GlobalKey? rewardsKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: 'Galería de Logros 🏆',
        description:
            'Aquí puedes ver todos tus logros conseguidos y los que aún puedes desbloquear.',
        icon: Icons.emoji_events,
        showPulse: false,
      ),
      if (achievementGridKey != null)
        InteractiveTutorialStep(
          title: 'Logros Disponibles',
          description:
              'Estos son todos los logros que puedes conseguir. Los logros desbloqueados aparecen en color, mientras que los bloqueados están en gris.',
          icon: Icons.grid_view,
          targetKey: achievementGridKey,
          showPulse: true,
        ),
      if (progressKey != null)
        InteractiveTutorialStep(
          title: 'Progreso',
          description:
              'Aquí puedes ver tu progreso general en la obtención de logros.',
          icon: Icons.trending_up,
          targetKey: progressKey,
          showPulse: true,
        ),
      if (rewardsKey != null)
        InteractiveTutorialStep(
          title: 'Recompensas',
          description:
              'Algunos logros otorgan experiencia extra, títulos especiales o elementos únicos.',
          icon: Icons.redeem,
          targetKey: rewardsKey,
          showPulse: true,
        ),
    ];
  }

  /// Tutorial para la pantalla de misiones (nueva versión)
  static List<InteractiveTutorialStep> getMissionScreenTutorial({
    GlobalKey? missionListKey,
    GlobalKey? filterButtonKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido a las Misiones! 🏰',
        description:
            'Aquí encontrarás todas las misiones disponibles para aprender programación de forma divertida.',
        icon: Icons.flag,
        showPulse: false,
      ),
      if (missionListKey != null)
        InteractiveTutorialStep(
          title: 'Lista de Misiones',
          description:
              'Estas son todas las misiones disponibles. Las misiones desbloqueadas aparecen en color normal, mientras que las bloqueadas aparecen en gris.',
          icon: Icons.list_alt,
          targetKey: missionListKey,
          showPulse: true,
        ),
      if (filterButtonKey != null)
        InteractiveTutorialStep(
          title: 'Filtrar Misiones',
          description:
              'Puedes filtrar las misiones por categoría o dificultad para encontrar las que más te interesen.',
          icon: Icons.filter_list,
          targetKey: filterButtonKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Navegación',
          description:
              'Usa el botón de retroceso para volver a la pantalla anterior en cualquier momento.',
          icon: Icons.arrow_back,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: '¡Comienza tu Aventura!',
        description:
            'Cada misión completada te dará experiencia, recompensas y nuevos conocimientos. ¡Buena suerte!',
        icon: Icons.star,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para la pantalla de detalle de misión
  static List<InteractiveTutorialStep> getMissionDetailTutorial({
    GlobalKey? missionTitleKey,
    GlobalKey? missionDescriptionKey,
    GlobalKey? startMissionButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: 'Detalle de Misión 📋',
        description:
            'Aquí puedes ver toda la información sobre la misión seleccionada antes de comenzarla.',
        icon: Icons.info,
        showPulse: false,
      ),
      if (missionTitleKey != null)
        InteractiveTutorialStep(
          title: 'Título de la Misión',
          description: 'Este es el nombre de la misión que has seleccionado.',
          icon: Icons.title,
          targetKey: missionTitleKey,
          showPulse: true,
        ),
      if (missionDescriptionKey != null)
        InteractiveTutorialStep(
          title: 'Descripción',
          description:
              'Aquí encontrarás información detallada sobre los objetivos y el contexto de la misión.',
          icon: Icons.description,
          targetKey: missionDescriptionKey,
          showPulse: true,
        ),
      if (startMissionButtonKey != null)
        InteractiveTutorialStep(
          title: 'Iniciar Misión',
          description:
              'Pulsa este botón cuando estés listo para comenzar la misión y acceder al contenido teórico.',
          icon: Icons.play_arrow,
          targetKey: startMissionButtonKey,
          showPulse: true,
        ),
    ];
  }

  /// Tutorial para la pantalla de teoría
  static List<InteractiveTutorialStep> getTheoryScreenTutorial({
    GlobalKey? theoryTitleKey,
    GlobalKey? theoryContentKey,
    GlobalKey? examplesKey,
    GlobalKey? startExercisesButtonKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: 'Teoría de la Misión 📚',
        description:
            'En esta pantalla aprenderás los conceptos necesarios para completar la misión.',
        icon: Icons.school,
        showPulse: false,
      ),
      if (theoryTitleKey != null)
        InteractiveTutorialStep(
          title: 'Título de la Teoría',
          description:
              'Este es el tema principal que se explica en esta sección.',
          icon: Icons.title,
          targetKey: theoryTitleKey,
          showPulse: true,
        ),
      if (theoryContentKey != null)
        InteractiveTutorialStep(
          title: 'Contenido Teórico',
          description:
              'Lee atentamente esta información para entender los conceptos que necesitarás aplicar.',
          icon: Icons.article,
          targetKey: theoryContentKey,
          showPulse: true,
        ),
      if (examplesKey != null)
        InteractiveTutorialStep(
          title: 'Ejemplos Prácticos',
          description:
              'Estos ejemplos te ayudarán a entender cómo aplicar los conceptos teóricos en la práctica.',
          icon: Icons.code,
          targetKey: examplesKey,
          showPulse: true,
        ),
      if (startExercisesButtonKey != null)
        InteractiveTutorialStep(
          title: 'Comenzar Ejercicios',
          description:
              'Cuando te sientas preparado, pulsa este botón para poner a prueba tus conocimientos.',
          icon: Icons.play_arrow,
          targetKey: startExercisesButtonKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Volver',
          description:
              'Si necesitas revisar los detalles de la misión, puedes volver a la pantalla anterior.',
          icon: Icons.arrow_back,
          targetKey: backButtonKey,
          showPulse: true,
        ),
    ];
  }

  /// Verifica si un tutorial está disponible pero NO lo inicia automáticamente
  static Future<void> startTutorialIfNeeded(
    BuildContext context,
    String tutorialKey,
    List<InteractiveTutorialStep> steps,
  ) async {
    try {
      final tutorialService = TutorialService();
      final completed = await tutorialService.isTutorialCompleted(tutorialKey);

      // Verificar si el contexto sigue siendo válido
      if (!context.mounted) return;

      // Solo verificar si el tutorial está disponible, pero NO iniciarlo automáticamente
      // El tutorial solo debe iniciarse cuando se accede específicamente desde el menú
      if (!completed) {
        // Tutorial disponible pero no se inicia automáticamente
        debugPrint(
          'Tutorial $tutorialKey disponible pero no se inicia automáticamente',
        );
      }
    } catch (e) {
      // Capturar cualquier error que pueda ocurrir
      debugPrint('Error al verificar tutorial: $e');
    }
  }

  /// Muestra un diálogo para iniciar un tutorial específico
  static void showTutorialDialog(
    BuildContext context,
    List<InteractiveTutorialStep> steps, {
    String? tutorialKey,
  }) {
    _showTutorialDialog(context, steps, tutorialKey: tutorialKey);
  }

  // Método privado para mostrar el diálogo de tutorial
  static void _showTutorialDialog(
    BuildContext context,
    List<InteractiveTutorialStep> steps, {
    String? tutorialKey,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tutorial'),
            content: const Text(
              '¿Quieres iniciar el tutorial para esta pantalla?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Crear una instancia de TutorialService y llamar al método no estático
                  final tutorialService = TutorialService();
                  tutorialService._startInteractiveTutorial(
                    context,
                    steps,
                    tutorialKey,
                  );
                },
                child: const Text('Sí'),
              ),
            ],
          ),
    );
  }

  // Variable para almacenar la referencia al OverlayEntry actual
  OverlayEntry? _currentOverlayEntry;

  // Método privado para iniciar el tutorial interactivo
  void _startInteractiveTutorial(
    BuildContext context,
    List<InteractiveTutorialStep> steps,
    String? tutorialKey,
  ) {
    try {
      if (context == null || !context.mounted || steps.isEmpty) {
        return;
      }

      // En lugar de usar Navigator.push, usaremos Overlay para mostrar el tutorial como una capa superpuesta
      final overlay = Overlay.of(context);

      // Crear el OverlayEntry y almacenar la referencia
      _currentOverlayEntry = OverlayEntry(
        builder:
            (context) => Stack(
              children: [
                // Capa transparente que permite que los toques pasen a través
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Widget de tutorial
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InteractiveTutorial(
                      steps: steps,
                      autoStart: true,
                      child:
                          const SizedBox.shrink(), // Widget invisible que no ocupa espacio
                      onComplete: () async {
                        // Marcar el tutorial como completado si se proporciona una clave
                        if (tutorialKey != null) {
                          final tutorialService = TutorialService();
                          await tutorialService.markTutorialCompleted(
                            tutorialKey,
                          );
                        }

                        // Eliminar el overlay
                        if (_currentOverlayEntry != null) {
                          _currentOverlayEntry!.remove();
                          _currentOverlayEntry = null;
                        }
                      },
                      onCancel: () {
                        // Eliminar el overlay
                        if (_currentOverlayEntry != null) {
                          _currentOverlayEntry!.remove();
                          _currentOverlayEntry = null;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
      );

      // Insertar el overlay
      overlay.insert(_currentOverlayEntry!);
    } catch (e) {
      // Capturar cualquier error que pueda ocurrir
      debugPrint('Error al iniciar tutorial interactivo: $e');
    }
  }

  // Claves públicas para los tutoriales
  static const String homeScreenTutorial = _homeScreenTutorialKey;
  static const String characterSelectionTutorial =
      _characterSelectionTutorialKey;
  static const String missionScreenTutorial = _missionsTutorialKey;
  static const String achievementScreenTutorial = _achievementsTutorialKey;
  static const String missionDetailTutorial = _missionDetailTutorialKey;
  static const String theoryScreenTutorial = _theoryScreenTutorialKey;
}

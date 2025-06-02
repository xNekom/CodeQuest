import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/interactive_tutorial.dart';

class TutorialService {
  static const String _homeScreenTutorialKey = 'home_screen_tutorial_completed';

  static const String _missionsTutorialKey = 'missions_tutorial_completed';
  static const String _achievementsTutorialKey =
      'achievements_tutorial_completed';
  static const String _missionDetailTutorialKey =
      'mission_detail_tutorial_completed';
  static const String _theoryScreenTutorialKey =
      'theory_screen_tutorial_completed';
  static const String _welcomeTutorialKey = 'welcome_tutorial_completed';

  // Singleton pattern
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  // Set para rastrear tutoriales ya verificados y evitar logs repetitivos
  static final Set<String> _checkedTutorials = <String>{};

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

    await prefs.remove(_missionsTutorialKey);
    await prefs.remove(_achievementsTutorialKey);
    await prefs.remove(_missionDetailTutorialKey);
    await prefs.remove(_theoryScreenTutorialKey);
    await prefs.remove(_welcomeTutorialKey);
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
        title: '¡Bienvenido a CodeQuest! 🚀',
        description:
            '¡Hola, futuro programador! Te guiaremos paso a paso por todas las increíbles funciones de CodeQuest. ¡Prepárate para una aventura épica de aprendizaje!',
        icon: Icons.rocket_launch,
        showPulse: false,
      ),
      if (profileKey != null)
        InteractiveTutorialStep(
          title: 'Tu Avatar de Programador 👤',
          description:
              'Este es tu perfil personal donde puedes ver tu progreso, nivel actual, experiencia ganada y todas tus estadísticas de aventurero. ¡Cada línea de código te hace más fuerte!',
          icon: Icons.account_circle,
          targetKey: profileKey,
          showPulse: true,
        ),
      if (missionsKey != null)
        InteractiveTutorialStep(
          title: 'Panel de Estadísticas 📊',
          description:
              'Aquí puedes monitorear tu progreso: preguntas respondidas, aciertos conseguidos, batallas ganadas y mucho más. ¡Cada número cuenta tu historia de éxito!',
          icon: Icons.analytics,
          targetKey: missionsKey,
          showPulse: true,
        ),
      if (adventureButtonKey != null)
        InteractiveTutorialStep(
          title: 'Portal de Aventuras 🏰',
          description:
              '¡El corazón de CodeQuest! Aquí encontrarás misiones emocionantes que te enseñarán programación de forma divertida. Cada misión es un nuevo desafío esperándote.',
          icon: Icons.castle,
          targetKey: adventureButtonKey,
          showPulse: true,
        ),
      if (codeExercisesButtonKey != null)
        InteractiveTutorialStep(
          title: 'Laboratorio de Código 💻',
          description:
              'Tu espacio de práctica personal. Aquí puedes experimentar con código, resolver ejercicios adicionales y perfeccionar tus habilidades sin presión.',
          icon: Icons.computer,
          targetKey: codeExercisesButtonKey,
          showPulse: true,
        ),
      if (shopButtonKey != null)
        InteractiveTutorialStep(
          title: 'Mercado del Aventurero 🛒',
          description:
              'Gasta sabiamente las monedas que ganes completando misiones. Aquí encontrarás objetos útiles, mejoras para tu personaje y sorpresas especiales.',
          icon: Icons.shopping_bag,
          targetKey: shopButtonKey,
          showPulse: true,
        ),
      if (inventoryButtonKey != null)
        InteractiveTutorialStep(
          title: 'Mochila del Programador 🎒',
          description:
              'Tu colección personal de objetos, herramientas y recompensas. Organiza y usa estratégicamente todo lo que has conseguido en tus aventuras.',
          icon: Icons.backpack,
          targetKey: inventoryButtonKey,
          showPulse: true,
        ),
      if (leaderboardKey != null)
        InteractiveTutorialStep(
          title: 'Ranking de Leyendas 🏆',
          description:
              '¿Tienes lo que se necesita para estar entre los mejores? Compite sanamente con otros programadores y demuestra tus habilidades en la tabla global.',
          icon: Icons.emoji_events,
          targetKey: leaderboardKey,
          showPulse: true,
        ),
      if (achievementsKey != null)
        InteractiveTutorialStep(
          title: 'Galería de Logros 🌟',
          description:
              'Cada logro cuenta una historia de superación. Desde tu primera línea de código hasta desafíos épicos, aquí se celebran todos tus triunfos.',
          icon: Icons.stars,
          targetKey: achievementsKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: '¡Tu Aventura Comienza Ahora! ⚡',
        description:
            'Tienes todas las herramientas para convertirte en un maestro programador. Recuerda: cada error es aprendizaje, cada línea de código es progreso. ¡Adelante, héroe!',
        icon: Icons.flash_on,
        showPulse: false,
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
        title: 'Centro de Comando de Misiones 🎯',
        description:
            '¡Bienvenido al corazón de tu aventura! Aquí encontrarás desafíos emocionantes diseñados para convertirte en un programador experto. Cada misión es una oportunidad de crecimiento.',
        icon: Icons.military_tech,
        showPulse: false,
      ),
      if (missionListKey != null)
        InteractiveTutorialStep(
          title: 'Catálogo de Aventuras 📋',
          description:
              'Explora este universo de posibilidades. Las misiones están organizadas por dificultad y tema. Conforme avances, desbloquearás desafíos más emocionantes y complejos.',
          icon: Icons.explore,
          targetKey: missionListKey,
          showPulse: true,
        ),
      if (firstMissionKey != null)
        InteractiveTutorialStep(
          title: 'Tu Primera Gran Aventura 🌟',
          description:
              '¡Es hora de la acción! Selecciona cualquier misión disponible para ver sus detalles, objetivos y recompensas. Cada paso te acerca más a dominar la programación.',
          icon: Icons.rocket,
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
        title: 'Salón de la Fama del Programador 🏆',
        description:
            '¡Bienvenido a tu museo personal de triunfos! Aquí se exhiben todas tus hazañas como programador. Cada logro representa un hito importante en tu viaje de aprendizaje.',
        icon: Icons.museum,
        showPulse: false,
      ),
      if (achievementGridKey != null)
        InteractiveTutorialStep(
          title: 'Colección de Trofeos 🎖️',
          description:
              'Tu vitrina personal de éxitos. Los logros dorados brillan con orgullo, mientras que los plateados esperan pacientemente tu próximo gran momento. ¡Cada uno tiene su historia!',
          icon: Icons.workspace_premium,
          targetKey: achievementGridKey,
          showPulse: true,
        ),
      if (progressKey != null)
        InteractiveTutorialStep(
          title: 'Medidor de Grandeza 📈',
          description:
              'Tu barra de progreso hacia la maestría. Cada porcentaje representa horas de dedicación, líneas de código escritas y problemas resueltos. ¡El camino hacia la excelencia!',
          icon: Icons.trending_up,
          targetKey: progressKey,
          showPulse: true,
        ),
      if (rewardsKey != null)
        InteractiveTutorialStep(
          title: 'Tesoros del Conocimiento 💎',
          description:
              'Los logros no solo son reconocimientos, ¡son llaves que abren puertas! Experiencia extra, títulos únicos, objetos especiales y sorpresas te esperan.',
          icon: Icons.diamond,
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
        title: '¡Bienvenido al Reino de las Misiones! 🏰',
        description:
            'Has entrado al epicentro de la aventura. Aquí cada desafío es una puerta hacia nuevos conocimientos. ¡Prepárate para una experiencia de aprendizaje única y emocionante!',
        icon: Icons.castle,
        showPulse: false,
      ),
      if (missionListKey != null)
        InteractiveTutorialStep(
          title: 'Mapa del Tesoro del Conocimiento 🗺️',
          description:
              'Tu guía hacia la maestría en programación. Las misiones brillantes están listas para ser conquistadas, mientras que las sombreadas aguardan tu crecimiento. ¡Cada una es un escalón hacia la grandeza!',
          icon: Icons.map,
          targetKey: missionListKey,
          showPulse: true,
        ),
      if (filterButtonKey != null)
        InteractiveTutorialStep(
          title: 'Brújula de Aventuras 🧭',
          description:
              'Tu herramienta de navegación inteligente. Filtra por tema, dificultad o tipo de desafío para encontrar exactamente lo que necesitas para tu próximo gran salto de aprendizaje.',
          icon: Icons.explore,
          targetKey: filterButtonKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Portal de Regreso 🚪',
          description:
              'Tu escape rápido cuando necesites reagruparte. Siempre puedes volver al campamento base para planificar tu próxima estrategia de conquista.',
          icon: Icons.exit_to_app,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: '¡Que Comience la Épica! ⚔️',
        description:
            'Cada misión completada forja tu leyenda como programador. Experiencia, tesoros y sabiduría te esperan. ¡El destino está en tus manos, valiente aventurero!',
        icon: Icons.auto_awesome,
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
        title: 'Briefing de la Misión 📋',
        description:
            '¡Momento de estrategia! Aquí tienes toda la información crucial sobre tu próxima aventura. Conoce a tu enemigo, planifica tu ataque y prepárate para la victoria.',
        icon: Icons.assignment_ind,
        showPulse: false,
      ),
      if (missionTitleKey != null)
        InteractiveTutorialStep(
          title: 'Nombre en Clave de la Operación 🎯',
          description: 'Cada misión tiene su identidad única. Este título no es solo un nombre, es tu destino, tu desafío, tu oportunidad de brillar como programador.',
          icon: Icons.flag,
          targetKey: missionTitleKey,
          showPulse: true,
        ),
      if (missionDescriptionKey != null)
        InteractiveTutorialStep(
          title: 'Dossier de Inteligencia 📖',
          description:
              'Tu manual de supervivencia para esta aventura. Lee cuidadosamente: aquí están los objetivos, el contexto y las claves para triunfar. ¡El conocimiento es poder!',
          icon: Icons.menu_book,
          targetKey: missionDescriptionKey,
          showPulse: true,
        ),
      if (startMissionButtonKey != null)
        InteractiveTutorialStep(
          title: 'Botón de Lanzamiento 🚀',
          description:
              '¡El momento de la verdad! Cuando te sientas preparado y confiado, presiona aquí para iniciar tu aventura de aprendizaje. ¡Tu futuro como programador te espera!',
          icon: Icons.rocket_launch,
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
        title: 'Academia de Conocimiento 🎓',
        description:
            '¡Bienvenido al aula más emocionante del mundo! Aquí transformarás conceptos abstractos en superpoderes de programación. Cada línea que leas te acerca más a la maestría.',
        icon: Icons.school,
        showPulse: false,
      ),
      if (theoryTitleKey != null)
        InteractiveTutorialStep(
          title: 'Lección del Día 📖',
          description:
              'El tema estrella de tu aventura de aprendizaje. Este concepto será tu nueva herramienta secreta para resolver problemas como un verdadero programador ninja.',
          icon: Icons.auto_stories,
          targetKey: theoryTitleKey,
          showPulse: true,
        ),
      if (theoryContentKey != null)
        InteractiveTutorialStep(
          title: 'Grimorio del Programador 📜',
          description:
              'Tu manual de hechizos de programación. Lee cada palabra como si fuera un tesoro: aquí están los secretos que necesitas para dominar este arte milenario.',
          icon: Icons.library_books,
          targetKey: theoryContentKey,
          showPulse: true,
        ),
      if (examplesKey != null)
        InteractiveTutorialStep(
          title: 'Laboratorio de Experimentos 🧪',
          description:
              '¡La magia en acción! Estos ejemplos son como recetas de cocina para programadores. Observa cómo la teoría cobra vida y se convierte en código real y funcional.',
          icon: Icons.science,
          targetKey: examplesKey,
          showPulse: true,
        ),
      if (startExercisesButtonKey != null)
        InteractiveTutorialStep(
          title: 'Arena de Combate 🥊',
          description:
              '¡Hora de demostrar tu valía! Cuando te sientas como un maestro de la teoría, presiona aquí para enfrentar desafíos reales y poner a prueba tus nuevas habilidades.',
          icon: Icons.sports_mma,
          targetKey: startExercisesButtonKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Puerta de Escape Estratégico 🔄',
          description:
              'A veces necesitas reagruparte y revisar el plan maestro. Este botón te lleva de vuelta al briefing para repasar los objetivos de tu misión.',
          icon: Icons.refresh,
          targetKey: backButtonKey,
          showPulse: true,
        ),
    ];
  }

  /// Tutorial de bienvenida después de la primera selección de personaje
  static List<InteractiveTutorialStep> getWelcomeTutorial() {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido a CodeQuest, Héroe! 🎉',
        description:
            '¡Felicidades, valiente aventurero! Has dado el primer paso hacia la grandeza. Tu personaje está listo y tu destino como maestro programador te espera. ¡La leyenda comienza ahora!',
        icon: Icons.celebration,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: 'El Mundo Te Espera 🌍',
        description:
            'Un universo infinito de posibilidades se abre ante ti. Explorarás reinos de código, conquistarás algoritmos misteriosos y desbloquearás poderes de programación que ni imaginas.',
        icon: Icons.public,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: 'Forja Tu Leyenda 💫',
        description:
            'Cada línea de código que escribas, cada problema que resuelvas, cada misión que completes te convertirá en una leyenda. Experiencia, tesoros y reconocimiento serán tus recompensas.',
        icon: Icons.auto_awesome,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: '¡Que Comience la Épica! 🚀',
        description:
            'Tu nave está lista, tu equipo preparado, tu mente afilada. Dirígete al centro de comando y elige tu primera misión. ¡El futuro de la programación está en tus manos, campeón!',
        icon: Icons.rocket_launch,
        showPulse: false,
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
      // Evitar verificaciones repetitivas del mismo tutorial
      if (_checkedTutorials.contains(tutorialKey)) {
        return;
      }

      final tutorialService = TutorialService();
      final completed = await tutorialService.isTutorialCompleted(tutorialKey);

      // Verificar si el contexto sigue siendo válido
      if (!context.mounted) return;

      // Marcar como verificado para evitar llamadas futuras
      _checkedTutorials.add(tutorialKey);

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

  /// Método público para iniciar un tutorial directamente
  static void startTutorial(
    BuildContext context,
    List<InteractiveTutorialStep> steps, {
    String? tutorialKey,
  }) {
    final tutorialService = TutorialService();
    tutorialService._startInteractiveTutorial(context, steps, tutorialKey);
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
      if (!context.mounted || steps.isEmpty) {
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

  static const String missionScreenTutorial = _missionsTutorialKey;
  static const String achievementScreenTutorial = _achievementsTutorialKey;
  static const String missionDetailTutorial = _missionDetailTutorialKey;
  static const String welcomeTutorial = _welcomeTutorialKey;
  static const String theoryScreenTutorial = _theoryScreenTutorialKey;
}

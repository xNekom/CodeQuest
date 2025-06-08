import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/interactive_tutorial.dart';

class TutorialService {
  // Claves para los tutoriales reorganizados
  static const String _homeScreenTutorialKey = 'home_screen_tutorial_completed';
  static const String _missionsScreenTutorialKey =
      'missions_screen_tutorial_completed';
  static const String _codeExercisesTutorialKey =
      'code_exercises_tutorial_completed';
  static const String _shopTutorialKey = 'shop_tutorial_completed';
  static const String _inventoryTutorialKey = 'inventory_tutorial_completed';
  static const String _leaderboardTutorialKey =
      'leaderboard_tutorial_completed';
  static const String _achievementsTutorialKey =
      'achievements_tutorial_completed';

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
    debugPrint('Tutorial marcado como completado: $tutorialKey');
    
    // Verificar que se guardó correctamente
    final verified = await isTutorialCompleted(tutorialKey);
    debugPrint('Verificación post-guardado: $tutorialKey = $verified');
  }

  /// Resetea todos los tutoriales (para pruebas)
  Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeScreenTutorialKey);
    await prefs.remove(_missionsScreenTutorialKey);
    await prefs.remove(_codeExercisesTutorialKey);
    await prefs.remove(_shopTutorialKey);
    await prefs.remove(_inventoryTutorialKey);
    await prefs.remove(_leaderboardTutorialKey);
    await prefs.remove(_achievementsTutorialKey);
  }

  /// Método de depuración para verificar el estado de todos los tutoriales
  Future<Map<String, bool>> debugGetAllTutorialStates() async {
    final states = {
      'homeScreenTutorial': await isTutorialCompleted(homeScreenTutorial),
      'missionsScreenTutorial': await isTutorialCompleted(missionsScreenTutorial),
      'codeExercisesTutorial': await isTutorialCompleted(codeExercisesTutorial),
      'shopTutorial': await isTutorialCompleted(shopTutorial),
      'inventoryTutorial': await isTutorialCompleted(inventoryTutorial),
      'leaderboardTutorial': await isTutorialCompleted(leaderboardTutorial),
      'achievementsTutorial': await isTutorialCompleted(achievementsTutorial),
    };
    
    debugPrint('Estado de tutoriales: $states');
    return states;
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
      InteractiveTutorialStep(
        title: 'Tu Avatar de Programador 👤',
        description:
            'Este es tu perfil personal donde puedes ver tu progreso, nivel actual, experiencia ganada y todas tus estadísticas de aventurero. ¡Cada línea de código te hace más fuerte!',
        icon: Icons.account_circle,
        targetKey: profileKey,
        showPulse: profileKey != null,
      ),
      InteractiveTutorialStep(
        title: 'Panel de Estadísticas 📊',
        description:
            'Aquí puedes monitorear tu progreso: preguntas respondidas, aciertos conseguidos, batallas ganadas y mucho más. ¡Cada número cuenta tu historia de éxito!',
        icon: Icons.analytics,
        targetKey: missionsKey,
        showPulse: missionsKey != null,
      ),
      InteractiveTutorialStep(
        title: 'Portal de Aventuras 🏰',
        description:
            '¡El corazón de CodeQuest! Aquí encontrarás misiones emocionantes que te enseñarán programación de forma divertida. Cada misión es un nuevo desafío esperándote.',
        icon: Icons.castle,
        targetKey: adventureButtonKey,
        showPulse: adventureButtonKey != null,
      ),
      InteractiveTutorialStep(
        title: 'Laboratorio de Código 💻',
        description:
            'Tu espacio de práctica personal. Aquí puedes experimentar con código, resolver ejercicios adicionales y perfeccionar tus habilidades sin presión.',
        icon: Icons.computer,
        targetKey: codeExercisesButtonKey,
        showPulse: codeExercisesButtonKey != null,
      ),
      InteractiveTutorialStep(
        title: 'Mercado del Aventurero 🛒',
        description:
            'Gasta sabiamente las monedas que ganes completando misiones. Aquí encontrarás objetos útiles, mejoras para tu personaje y sorpresas especiales.',
        icon: Icons.shopping_bag,
        targetKey: shopButtonKey,
        showPulse: shopButtonKey != null,
      ),
      InteractiveTutorialStep(
        title: 'Mochila del Programador 🎒',
        description:
            'Tu colección personal de objetos, herramientas y recompensas. Organiza y usa estratégicamente todo lo que has conseguido en tus aventuras.',
        icon: Icons.backpack,
        targetKey: inventoryButtonKey,
        showPulse: inventoryButtonKey != null,
      ),
      InteractiveTutorialStep(
        title: 'Ranking de Leyendas 🏆',
        description:
            '¿Tienes lo que se necesita para estar entre los mejores? Compite sanamente con otros programadores y demuestra tus habilidades en la tabla global.',
        icon: Icons.emoji_events,
        targetKey: leaderboardKey,
        showPulse: leaderboardKey != null,
      ),
      InteractiveTutorialStep(
        title: 'Galería de Logros 🌟',
        description:
            'Cada logro cuenta una historia de superación. Desde tu primera línea de código hasta desafíos épicos, aquí se celebran todos tus triunfos.',
        icon: Icons.stars,
        targetKey: achievementsKey,
        showPulse: achievementsKey != null,
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
  static List<InteractiveTutorialStep> getMissionsScreenTutorial({
    GlobalKey? missionListKey,
    GlobalKey? filterButtonKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido al Centro de Misiones! 🏰',
        description:
            'Este es tu centro de comando para todas las aventuras de programación. Aquí encontrarás desafíos organizados por dificultad y tema, diseñados para llevarte desde principiante hasta experto.',
        icon: Icons.castle,
        showPulse: false,
      ),
      if (filterButtonKey != null)
        InteractiveTutorialStep(
          title: 'Filtro de Misiones 🔍',
          description:
              'Usa este botón para organizar las misiones según tus necesidades. Puedes filtrar por nivel de dificultad (Principiante, Intermedio, Avanzado) o por estado de completado (Todas, Completadas, Disponibles, Bloqueadas) para encontrar exactamente lo que buscas.',
          icon: Icons.filter_list,
          targetKey: filterButtonKey,
          showPulse: true,
        ),
      if (missionListKey != null)
        InteractiveTutorialStep(
          title: 'Lista de Misiones Disponibles 📋',
          description:
              'Aquí se muestran todas tus misiones. Las verdes están completadas, las normales están disponibles, y las grises están bloqueadas hasta que cumplas los requisitos. Cada misión te enseña conceptos específicos de programación.',
          icon: Icons.list_alt,
          targetKey: missionListKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Volver al Inicio 🏠',
          description:
              'Usa este botón para regresar a la pantalla principal cuando hayas terminado de revisar las misiones disponibles.',
          icon: Icons.home,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: 'Consejos para el Éxito 💡',
        description:
            'Completa las misiones en orden para un aprendizaje progresivo. Cada misión desbloqueada te acerca más a dominar la programación. ¡No tengas miedo de repetir misiones para reforzar conceptos!',
        icon: Icons.lightbulb,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para la pantalla de ejercicios de código
  static List<InteractiveTutorialStep> getCodeExercisesTutorial({
    GlobalKey? exerciseListKey,
    GlobalKey? difficultyFilterKey,
    GlobalKey? searchBarKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido al Laboratorio de Código! 💻',
        description:
            'Este es tu espacio personal para practicar y perfeccionar tus habilidades de programación. Aquí encontrarás ejercicios prácticos que te ayudarán a dominar los conceptos que has aprendido en las misiones.',
        icon: Icons.code,
        showPulse: false,
      ),
      if (searchBarKey != null)
        InteractiveTutorialStep(
          title: 'Buscador de Ejercicios 🔍',
          description:
              'Usa esta barra para buscar ejercicios específicos por nombre o concepto. Es útil cuando quieres practicar algo en particular.',
          icon: Icons.search,
          targetKey: searchBarKey,
          showPulse: true,
        ),
      if (difficultyFilterKey != null)
        InteractiveTutorialStep(
          title: 'Filtro de Dificultad ⭐',
          description:
              'Organiza los ejercicios según su nivel de dificultad. Comienza con los más sencillos y ve avanzando gradualmente hacia los desafíos más complejos.',
          icon: Icons.filter_list,
          targetKey: difficultyFilterKey,
          showPulse: true,
        ),
      if (exerciseListKey != null)
        InteractiveTutorialStep(
          title: 'Catálogo de Ejercicios 📚',
          description:
              'Explora todos los ejercicios disponibles. Cada tarjeta muestra el título, descripción, dificultad y conceptos que practicarás. ¡Toca cualquiera para comenzar a programar!',
          icon: Icons.list_alt,
          targetKey: exerciseListKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Volver al Inicio 🏠',
          description:
              'Cuando termines de practicar, usa este botón para regresar a la pantalla principal.',
          icon: Icons.home,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: 'Consejos para Practicar 💡',
        description:
            'La práctica constante es clave para dominar la programación. Intenta resolver ejercicios regularmente, incluso los que ya has completado. Recuerda: cada línea de código que escribes te hace mejor programador.',
        icon: Icons.lightbulb,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para la pantalla de logros
  static List<InteractiveTutorialStep> getAchievementsTutorial({
    GlobalKey? progressKey,
    GlobalKey? achievementGridKey,
    GlobalKey? rewardsKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido a tu Galería de Logros! 🌟',
        description:
            'Este es el lugar donde se celebran todos tus triunfos y conquistas en CodeQuest. Cada logro cuenta una historia de superación y progreso en tu aventura de aprendizaje.',
        icon: Icons.stars,
        showPulse: false,
      ),
      if (progressKey != null)
        InteractiveTutorialStep(
          title: 'Barra de Progreso General 📊',
          description:
              'Aquí puedes ver tu progreso general en el juego. Muestra el porcentaje de logros desbloqueados y te da una idea de cuánto has avanzado en tu aventura.',
          icon: Icons.trending_up,
          targetKey: progressKey,
          showPulse: true,
        ),
      if (achievementGridKey != null)
        InteractiveTutorialStep(
          title: 'Colección de Logros 🏆',
          description:
              'Explora todos los logros disponibles. Los dorados están desbloqueados, los grises aún están por conseguir. Cada logro tiene requisitos específicos y recompensas únicas.',
          icon: Icons.emoji_events,
          targetKey: achievementGridKey,
          showPulse: true,
        ),
      if (rewardsKey != null)
        InteractiveTutorialStep(
          title: 'Sistema de Recompensas 🎁',
          description:
              'Cada logro desbloqueado te otorga recompensas especiales como monedas, objetos únicos o títulos especiales. ¡Algunas recompensas solo se pueden obtener a través de logros!',
          icon: Icons.card_giftcard,
          targetKey: rewardsKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Volver al Inicio 🏠',
          description:
              'Cuando termines de revisar tus logros, usa este botón para regresar a la pantalla principal.',
          icon: Icons.home,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: 'Consejos para Logros 💡',
        description:
            'Los logros se desbloquean automáticamente al cumplir ciertos requisitos. Algunos son fáciles de conseguir, otros requieren dedicación y habilidad. ¡No te desanimes si algunos parecen difíciles, cada paso cuenta!',
        icon: Icons.lightbulb,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para la pantalla de tienda
  static List<InteractiveTutorialStep> getShopTutorial({
    GlobalKey? coinsIndicatorKey,
    GlobalKey? itemListKey,
    GlobalKey? categoryFilterKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido al Mercado del Aventurero! 🛒',
        description:
            'Este es el lugar perfecto para gastar las monedas que has ganado completando misiones y ejercicios. Aquí encontrarás objetos útiles, mejoras para tu personaje y elementos decorativos.',
        icon: Icons.shopping_bag,
        showPulse: false,
      ),
      if (coinsIndicatorKey != null)
        InteractiveTutorialStep(
          title: 'Tu Tesoro 💰',
          description:
              'Aquí puedes ver cuántas monedas tienes disponibles para gastar. Gana más completando misiones, ejercicios y desbloqueando logros.',
          icon: Icons.monetization_on,
          targetKey: coinsIndicatorKey,
          showPulse: true,
        ),
      if (categoryFilterKey != null)
        InteractiveTutorialStep(
          title: 'Categorías de Productos 📑',
          description:
              'Filtra los productos por categoría para encontrar exactamente lo que estás buscando, ya sean armas, armaduras, pociones o elementos decorativos.',
          icon: Icons.category,
          targetKey: categoryFilterKey,
          showPulse: true,
        ),
      if (itemListKey != null)
        InteractiveTutorialStep(
          title: 'Catálogo de Productos 🏪',
          description:
              'Explora todos los productos disponibles. Cada tarjeta muestra el nombre, descripción, precio y estadísticas del objeto. Toca cualquiera para ver más detalles o comprarlo.',
          icon: Icons.shopping_cart,
          targetKey: itemListKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Volver al Inicio 🏠',
          description:
              'Cuando termines tus compras, usa este botón para regresar a la pantalla principal.',
          icon: Icons.home,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: 'Consejos de Compra 💡',
        description:
            'Invierte sabiamente tus monedas. Algunos objetos pueden ayudarte en batallas, mientras que otros desbloquean nuevas funcionalidades o personalizan tu experiencia. ¡Revisa regularmente la tienda para ver nuevos productos!',
        icon: Icons.lightbulb,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para la pantalla de inventario
  static List<InteractiveTutorialStep> getInventoryTutorial({
    GlobalKey? inventoryGridKey,
    GlobalKey? categoryFilterKey,
    GlobalKey? itemDetailKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido a tu Mochila del Programador! 🎒',
        description:
            'Este es tu inventario personal donde se guardan todos los objetos que has adquirido en la tienda o ganado como recompensa. Cada item se muestra en una tarjeta con su información básica.',
        icon: Icons.backpack,
        showPulse: false,
      ),
      if (inventoryGridKey != null)
        InteractiveTutorialStep(
          title: 'Lista de Objetos 📦',
          description:
              'Aquí puedes ver todos los objetos que posees en una lista organizada. Cada tarjeta muestra el icono, nombre, descripción breve, cantidad y rareza del objeto. Las tarjetas se adaptan automáticamente al contenido.',
          icon: Icons.list,
          targetKey: inventoryGridKey,
          showPulse: true,
        ),
      if (categoryFilterKey != null)
        InteractiveTutorialStep(
          title: 'Tarjeta de Objeto 🎴',
          description:
              'Cada tarjeta muestra información esencial: icono del objeto, nombre en negrita, descripción resumida, cantidad (si tienes más de uno) y nivel de rareza con colores distintivos.',
          icon: Icons.card_membership,
          targetKey: categoryFilterKey,
          showPulse: true,
        ),
      if (itemDetailKey != null)
        InteractiveTutorialStep(
          title: 'Detalles Completos 🔍',
          description:
              'Toca cualquier tarjeta para abrir una ventana con información detallada del objeto, incluyendo descripción completa, estadísticas, tipo y opciones de uso disponibles.',
          icon: Icons.info,
          targetKey: itemDetailKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Volver al Inicio 🏠',
          description:
              'Cuando termines de revisar tu inventario, usa este botón para regresar a la pantalla principal.',
          icon: Icons.home,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: 'Gestión Inteligente 💡',
        description:
            'Tu inventario se organiza automáticamente. Los objetos más raros tienen bordes de colores especiales. Revisa regularmente para descubrir nuevos objetos y sus usos estratégicos en tu aventura de programación.',
        icon: Icons.lightbulb,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para la pantalla de clasificación (leaderboard)
  static List<InteractiveTutorialStep> getLeaderboardTutorial({
    GlobalKey? userRankingKey,
    GlobalKey? leaderboardListKey,
    GlobalKey? timeFilterKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido al Ranking de Leyendas! 🏆',
        description:
            'Descubre la tabla de clasificación global donde puedes comparar tu progreso con otros programadores. Aquí verás las posiciones, puntuaciones y estadísticas de los mejores jugadores de CodeQuest.',
        icon: Icons.emoji_events,
        showPulse: false,
      ),
      if (userRankingKey != null)
        InteractiveTutorialStep(
          title: 'Tu Posición Personal 🌟',
          description:
              'Esta tarjeta muestra tu posición actual en el ranking global. El número está coloreado según tu rendimiento: oro para los primeros lugares, plata para posiciones intermedias y bronce para el resto.',
          icon: Icons.account_circle,
          targetKey: userRankingKey,
          showPulse: true,
        ),
      if (timeFilterKey != null)
        InteractiveTutorialStep(
          title: 'Jugador Destacado 👑',
          description:
              'El primer jugador de la lista tiene un diseño especial que lo destaca como el líder actual. Observa sus estadísticas para inspirarte y establecer metas.',
          icon: Icons.star,
          targetKey: timeFilterKey,
          showPulse: true,
        ),
      if (leaderboardListKey != null)
        InteractiveTutorialStep(
          title: 'Lista de Clasificación 📊',
          description:
              'Cada entrada muestra la posición, nombre del jugador, puntuación total y estadísticas clave. Tu propia entrada aparece resaltada con un borde azul para que la encuentres fácilmente.',
          icon: Icons.format_list_numbered,
          targetKey: leaderboardListKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Navegación 🏠',
          description:
              'Usa este botón para regresar al menú principal cuando hayas terminado de revisar las clasificaciones.',
          icon: Icons.arrow_back,
          targetKey: backButtonKey,
          showPulse: true,
        ),
      InteractiveTutorialStep(
        title: 'Estrategias para Subir de Rango 💡',
        description:
            'Tu puntuación se calcula basándose en misiones completadas, precisión en las respuestas, velocidad de resolución y logros desbloqueados. Enfócate en la calidad y consistencia, no solo en la velocidad.',
        icon: Icons.trending_up,
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
        // debugPrint(
        //   'Tutorial $tutorialKey disponible pero no se inicia automáticamente',
      }
    } catch (e) {
      // Capturar cualquier error que pueda ocurrir
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

  // Flag síncrono para evitar race conditions al insertar el overlay
  bool _isStarting = false;

  // Método privado para iniciar el tutorial interactivo
  void _startInteractiveTutorial(
    BuildContext context,
    List<InteractiveTutorialStep> steps,
    String? tutorialKey,
  ) {
    // Protección síncrona contra doble inicio (race condition + overlay ya activo)
    if (_isStarting || _currentOverlayEntry != null) {
      debugPrint('TutorialService: Bloqueando inicio duplicado (_isStarting=$_isStarting, overlay=${_currentOverlayEntry != null})');
      return;
    }
    _isStarting = true;

    debugPrint('TutorialService: Iniciando tutorial con ${steps.length} pasos');
    debugPrint('TutorialService: Tutorial key: $tutorialKey');
    debugPrint('TutorialService: Pasos: ${steps.map((s) => s.title).toList()}');

    _currentOverlayEntry = OverlayEntry(
      builder: (context) {
        debugPrint('TutorialService: Construyendo OverlayEntry');
        return Positioned.fill(
          child: InteractiveTutorial(
            steps: steps,
            autoStart: true,
            onComplete: () {
              debugPrint('TutorialService: Tutorial completado');
              _currentOverlayEntry?.remove();
              _currentOverlayEntry = null;
              _isStarting = false;
              if (tutorialKey != null) {
                markTutorialCompleted(tutorialKey);
              }
            },
            onCancel: () {
              debugPrint('TutorialService: Tutorial cancelado');
              _currentOverlayEntry?.remove();
              _currentOverlayEntry = null;
              _isStarting = false;
            },
            child: Container(color: Colors.transparent),
          ),
        );
      },
    );

    debugPrint('TutorialService: Insertando OverlayEntry');
    try {
      Overlay.of(context).insert(_currentOverlayEntry!);
      debugPrint('TutorialService: OverlayEntry insertado exitosamente');
    } catch (e) {
      debugPrint('TutorialService: Error al insertar overlay: $e');
      _currentOverlayEntry = null;
    } finally {
      _isStarting = false;
    }
  }

  /// Tutorial para la pantalla de misiones (alias para compatibilidad)
  static List<InteractiveTutorialStep> getMissionScreenTutorial({
    GlobalKey? missionListKey,
    GlobalKey? filterButtonKey,
    GlobalKey? backButtonKey,
  }) {
    return getMissionsScreenTutorial(
      missionListKey: missionListKey,
      filterButtonKey: filterButtonKey,
      backButtonKey: backButtonKey,
    );
  }

  /// Tutorial para detalles de misión
  static List<InteractiveTutorialStep> getMissionDetailTutorial({
    GlobalKey? startButtonKey,
    GlobalKey? descriptionKey,
    GlobalKey? requirementsKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: '¡Detalles de la Misión! 📖',
        description:
            'Aquí puedes ver toda la información sobre esta misión específica, incluyendo objetivos, requisitos y recompensas.',
        icon: Icons.info,
        showPulse: false,
      ),
      if (descriptionKey != null)
        InteractiveTutorialStep(
          title: 'Descripción de la Misión 📝',
          description:
              'Lee cuidadosamente la descripción para entender qué conceptos aprenderás y qué se espera de ti.',
          icon: Icons.description,
          targetKey: descriptionKey,
          showPulse: true,
        ),
      if (requirementsKey != null)
        InteractiveTutorialStep(
          title: 'Requisitos 📋',
          description:
              'Aquí se muestran los requisitos previos que necesitas cumplir antes de comenzar esta misión.',
          icon: Icons.checklist,
          targetKey: requirementsKey,
          showPulse: true,
        ),
      if (startButtonKey != null)
        InteractiveTutorialStep(
          title: 'Comenzar Misión 🚀',
          description:
              'Cuando estés listo, presiona este botón para comenzar tu aventura de programación.',
          icon: Icons.play_arrow,
          targetKey: startButtonKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Regresar 🔙',
          description:
              'Usa este botón para volver a la lista de misiones cuando hayas terminado de revisar los detalles.',
          icon: Icons.arrow_back,
          targetKey: backButtonKey,
          showPulse: true,
        ),
    ];
  }

  /// Tutorial de bienvenida
  static List<InteractiveTutorialStep> getWelcomeTutorial() {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido a CodeQuest! 🎮',
        description:
            'Embárcate en una aventura épica donde aprenderás programación mientras juegas. ¡Prepárate para convertirte en un maestro del código!',
        icon: Icons.celebration,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: 'Tu Aventura Comienza 🌟',
        description:
            'Completa misiones, gana recompensas, y desbloquea nuevos desafíos. Cada línea de código te acerca más a la maestría.',
        icon: Icons.star,
        showPulse: false,
      ),
    ];
  }

  /// Tutorial para pantalla de teoría
  static List<InteractiveTutorialStep> getTheoryScreenTutorial({
    GlobalKey? contentKey,
    GlobalKey? examplesKey,
    GlobalKey? nextButtonKey,
    GlobalKey? backButtonKey,
  }) {
    return [
      InteractiveTutorialStep(
        title: 'Sección de Teoría 📚',
        description:
            'Aquí aprenderás los conceptos fundamentales antes de ponerlos en práctica. La teoría es la base de todo buen programador.',
        icon: Icons.school,
        showPulse: false,
      ),
      if (contentKey != null)
        InteractiveTutorialStep(
          title: 'Contenido Teórico 📖',
          description:
              'Lee cuidadosamente el contenido. Cada concepto está explicado de manera clara y con ejemplos prácticos.',
          icon: Icons.menu_book,
          targetKey: contentKey,
          showPulse: true,
        ),
      if (examplesKey != null)
        InteractiveTutorialStep(
          title: 'Ejemplos Prácticos 💡',
          description:
              'Los ejemplos te ayudan a entender cómo aplicar la teoría en código real. Estudia cada ejemplo detenidamente.',
          icon: Icons.lightbulb,
          targetKey: examplesKey,
          showPulse: true,
        ),
      if (nextButtonKey != null)
        InteractiveTutorialStep(
          title: 'Continuar ➡️',
          description:
              'Cuando hayas entendido el concepto, presiona aquí para continuar con la práctica.',
          icon: Icons.arrow_forward,
          targetKey: nextButtonKey,
          showPulse: true,
        ),
      if (backButtonKey != null)
        InteractiveTutorialStep(
          title: 'Regresar 🔙',
          description:
              'Si necesitas revisar algo anterior, usa este botón para navegar hacia atrás.',
          icon: Icons.arrow_back,
          targetKey: backButtonKey,
          showPulse: true,
        ),
    ];
  }

  /// Tutorial básico para la pantalla principal sin GlobalKeys
  static List<InteractiveTutorialStep> getBasicHomeScreenTutorial() {
    return [
      InteractiveTutorialStep(
        title: '¡Bienvenido a CodeQuest! 🎮',
        description:
            'Esta es tu pantalla principal, el centro de tu aventura de programación.',
        icon: Icons.home,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: 'Tu Avatar de Programador 👤',
        description:
            'En la parte superior verás tu perfil personal donde puedes ver tu progreso, nivel actual y experiencia ganada.',
        icon: Icons.account_circle,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: 'Panel de Misiones 📊',
        description:
            'Accede a las misiones disponibles y completa desafíos para ganar experiencia y monedas.',
        icon: Icons.assignment,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: 'Portal de Aventuras 🏰',
        description:
            '¡El corazón de CodeQuest! Aquí encontrarás misiones emocionantes que te enseñarán programación.',
        icon: Icons.castle,
        showPulse: false,
      ),
      InteractiveTutorialStep(
        title: '¡Listo para comenzar! 🚀',
        description:
            '¡Felicidades! Ahora conoces todos los elementos básicos. ¡Comienza tu aventura!',
        icon: Icons.flag,
        showPulse: false,
      ),
    ];
  }

  // Claves públicas para los tutoriales
  static const String homeScreenTutorial = _homeScreenTutorialKey;
  static const String missionsScreenTutorial = _missionsScreenTutorialKey;
  static const String missionScreenTutorial =
      _missionsScreenTutorialKey; // Alias para compatibilidad
  static const String codeExercisesTutorial = _codeExercisesTutorialKey;
  static const String shopTutorial = _shopTutorialKey;
  static const String inventoryTutorial = _inventoryTutorialKey;
  static const String leaderboardTutorial = _leaderboardTutorialKey;
  static const String achievementsTutorial = _achievementsTutorialKey;
  static const String achievementScreenTutorial =
      _achievementsTutorialKey; // Alias para compatibilidad

  // Constantes adicionales para tutoriales específicos
  static const String missionDetailTutorial =
      'mission_detail_tutorial_completed';
  static const String welcomeTutorial = 'welcome_tutorial_completed';
  static const String theoryScreenTutorial = 'theory_screen_tutorial_completed';
}


// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/tutorial_service.dart';
import '../services/audio_service.dart';
import '../widgets/pixel_widgets.dart';
import '../widgets/character_asset.dart';
import '../widgets/tutorial_floating_button.dart';
import '../utils/error_handler.dart';
import '../utils/overflow_utils.dart';
import '../widgets/test_error_widget.dart';
import '../theme/pixel_theme.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _hasInitialized =
      false; // Bandera para evitar inicializaciones múltiples
  bool _tutorialStarted =
      false; // Bandera para evitar que el tutorial se inicie dos veces
  bool _showCompletedMissions =
      false; // Estado para mostrar/ocultar misiones completadas

  // Variables para el sistema de doble tap para salir
  DateTime? _lastBackPressed;
  static const Duration _doubleTapThreshold = Duration(seconds: 2);

  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _missionsKey = GlobalKey();
  final GlobalKey _achievementsKey = GlobalKey();
  final GlobalKey _leaderboardKey = GlobalKey();

  final GlobalKey _adventureButtonKey =
      GlobalKey(); // Nueva key para el botón de aventura
  final GlobalKey _shopButtonKey =
      GlobalKey(); // Nueva key para el botón de tienda
  final GlobalKey _inventoryButtonKey =
      GlobalKey(); // Nueva key para el botón de inventario
  final GlobalKey _codeExercisesButtonKey =
      GlobalKey(); // Nueva key para el botón de ejercicios de código

  @override
  void initState() {
    super.initState();
    // NO llamar _loadUserData() aquí: didChangeDependencies lo invocará
    // justo después y evita la doble carga que causaba el tutorial doble.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Solo recargar datos si no se ha inicializado y la ruta está activa
    if (!_hasInitialized &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true) {
      _hasInitialized = true;
      // Usar Future.microtask en lugar de addPostFrameCallback para evitar bucles infinitos
      Future.microtask(() {
        if (mounted) {
          _loadUserData();
        }
      });
    }
  }

  /// Método para verificar y iniciar tutoriales automáticamente
  Future<void> _checkAndStartTutorial() async {
    // Evitar que se ejecute más de una vez por ciclo de vida de la pantalla
    if (_tutorialStarted) return;
    _tutorialStarted = true;

    // Esperar a que la UI se construya completamente y los datos estén cargados
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      final tutorialService = TutorialService();
      
      // Verificar estado actual
      final completed = await tutorialService.isTutorialCompleted(
        'homeScreenTutorial',
      );
      
      // Obtener todos los estados para debug
      final allStates = await tutorialService.debugGetAllTutorialStates();

      debugPrint('🔍 Tutorial Debug: Estado del tutorial home: $completed');
      debugPrint('🔍 Tutorial Debug: Clave usada: homeScreenTutorial');
      debugPrint('🔍 Tutorial Debug: Todos los estados: $allStates');

      if (!mounted) return;

      if (!completed) {
        debugPrint('🔍 Tutorial Debug: Iniciando tutorial porque no está completado');
        // Reproducir música después de interacción del usuario
        AudioService().playBackgroundMusicWithUserInteraction();

        // Iniciar el tutorial con exactamente los mismos pasos que el botón flotante
        TutorialService.startTutorial(
          context,
          TutorialService.getHomeScreenTutorial(
            profileKey: _profileKey,
            missionsKey: _missionsKey,
            achievementsKey: _achievementsKey,
            leaderboardKey: _leaderboardKey,
            adventureButtonKey: _adventureButtonKey,
            shopButtonKey: _shopButtonKey,
            inventoryButtonKey: _inventoryButtonKey,
            codeExercisesButtonKey: _codeExercisesButtonKey,
          ),
          tutorialKey: 'homeScreenTutorial',
        );
      } else {
        debugPrint('🔍 Tutorial Debug: Tutorial ya completado, no se iniciará');
      }
    } catch (e) {
      // Registrar el error pero no interrumpir la experiencia del usuario
      debugPrint('🔍 Tutorial Debug: Error al verificar tutorial: $e');
      ErrorHandler.logError(e, StackTrace.current);
    }
  }

  Future<void> _loadUserData() async {
    // No es necesario llamar a setState aquí si _isLoading ya es true por defecto o se maneja al inicio.
    // Si es necesario, asegurarse de que esté montado:
    // if (mounted) {
    //   setState(() {
    //     _isLoading = true;
    //   });
    // }
    try {
      User? user = _authService.currentUser;
      if (user != null) {
        final userData = await _userService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _userData = userData;
            _isLoading = false;
          });
          
          // Verificar el tutorial después de que los datos estén cargados
          await _checkAndStartTutorial();
        }
      } else {
        // No hay usuario autenticado, redirigir a la pantalla de inicio de sesión
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      }
    } catch (e) {
      // Registrar el error de manera global
      ErrorHandler.logError(e, StackTrace.current);

      // Mostrar mensaje de error al usuario
      if (mounted) {
        ErrorHandler.showError(
          context,
          'No se pudieron cargar los datos del usuario. Inténtalo nuevamente.',
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Maneja el botón de atrás de Android con doble tap para salir
  Future<bool> _handleBackButton() async {
    // Solo aplicar en Android
    if (!Platform.isAndroid) return false;

    final now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > _doubleTapThreshold) {
      // Primera vez presionando o pasó mucho tiempo desde la última vez
      _lastBackPressed = now;

      // Mostrar mensaje indicando que presione de nuevo para salir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presiona de nuevo para salir'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return true; // No cerrar la aplicación
    } else {
      // Segunda vez presionando dentro del tiempo límite
      SystemNavigator.pop(); // Cerrar la aplicación
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Evita que se cierre automáticamente
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleBackButton();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgrounds/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _userData == null
                    ? const Center(
                      child: Text('No se encontraron datos del usuario'),
                    )
                    : _buildUserDataContent(),
          ),
        ),
        floatingActionButton: TutorialFloatingButton(
          tutorialKey: TutorialService.homeScreenTutorial,
          tutorialSteps: TutorialService.getHomeScreenTutorial(
            profileKey: _profileKey,
            missionsKey: _missionsKey,
            achievementsKey: _achievementsKey,
            leaderboardKey: _leaderboardKey,
            adventureButtonKey: _adventureButtonKey,
            shopButtonKey: _shopButtonKey,
            inventoryButtonKey: _inventoryButtonKey,
            codeExercisesButtonKey: _codeExercisesButtonKey,
          ),
        ),
      ),
    );
  }

  Widget _buildUserDataContent() {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildAdventureButton(),
                  const SizedBox(height: 16),
                  _buildCodeExercisesButton(),
                  const SizedBox(height: 16),
                  _buildShopButton(),
                  const SizedBox(height: 16),
                  _buildInventoryButton(),
                  const SizedBox(height: 16),
                  _buildLeaderboardButton(),
                  const SizedBox(height: 24),
                  _buildAchievementsSection(),
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    // Determinar si el usuario es admin
    final bool isAdmin = _userData != null && _userData!['role'] == 'admin';

    return Padding(
      padding: const EdgeInsets.all(PixelTheme.spacingMedium),
      child: PixelCard(
        padding: const EdgeInsets.symmetric(
          horizontal: PixelTheme.spacingMedium,
          vertical: PixelTheme.spacingSmall,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo/logo_no_background.png',
                    height: 32,
                    width: 32,
                  ),
                  const SizedBox(width: PixelTheme.spacingSmall),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CODEQUEST',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin) ...[
                  // Mostrar botones de admin solo si el usuario es admin
                  // Widget para probar errores (solo visible para administradores)
                  const Flexible(child: TestErrorWidget()),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings, size: 20),
                    tooltip: 'Panel de Administrador',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/admin',
                      );
                      // Si regresa true, significa que hubo cambios en el admin
                      if (result == true) {
                        await _loadUserData();
                      }
                    },
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.logout, size: 20),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () async {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/auth');
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Editar Personaje',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () async {
                    // Navegar a selección/edición de personaje
                    await Navigator.pushNamed(context, '/character');
                    // Recargar datos del usuario para reflejar cambios
                    await _loadUserData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report, size: 20),
                  tooltip: 'Debug Tutorial',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () async {
                    final tutorialService = TutorialService();
                    final states = await tutorialService.debugGetAllTutorialStates();
                    final homeCompleted = await tutorialService.isTutorialCompleted(TutorialService.homeScreenTutorial);
                    
                    if (!mounted) return;
                    
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Debug Tutorial'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Home Tutorial: $homeCompleted'),
                            Text('Key: ${TutorialService.homeScreenTutorial}'),
                            const SizedBox(height: 8),
                            Text('All States: ${states.toString()}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await tutorialService.markTutorialCompleted(TutorialService.homeScreenTutorial);
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            child: const Text('Marcar Completado'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await tutorialService.resetAllTutorials();
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            child: const Text('Resetear Todos'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Column(
      key: _profileKey, // Asignar la key al perfil
      children: [
        // Icono del personaje y información del usuario en fila
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono del personaje más grande y sin recuadro
            Flexible(
              flex: 2,
              child: Hero(
                tag: 'avatar_${_userData!['username']}',
                child: CharacterAsset(
                  assetIndex: _userData!['characterAssetIndex'] as int? ?? 0,
                  size:
                      200, // Aumentado para igualar el tamaño del widget de información
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Información del usuario en un recuadro
            Flexible(flex: 3, child: PixelCard(child: _buildUserInfo())),
          ],
        ),
        const SizedBox(height: 16),
        // Barra de experiencia en un recuadro separado
        PixelCard(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _calculateExpProgress()),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Column(
                children: [
                  const Text('Experiencia'),
                  const SizedBox(height: 4),
                  PixelProgressBar(
                    value: value,
                    label:
                        '${(_userData!['experience'] ?? 0)} / ${_getCurrentLevelMaxExp()} XP',
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return OverflowUtils.safeUserInfo(
      username: '${_userData!['username']}',
      level: '${_userData!['level'] ?? 1}',
      coins: '${_userData!['coins'] ?? 0}',
      usernameStyle: Theme.of(context).textTheme.titleLarge,
      onChangePassword: _showChangePasswordDialog,
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar un botón para cerrar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña Actual',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Contraseña',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una nueva contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Nueva Contraseña',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirma tu nueva contraseña';
                      }
                      if (value != newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cambiar'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Reautenticar al usuario es necesario para cambiar la contraseña
                    bool reauthenticated = await _authService
                        .reauthenticateUser(currentPasswordController.text);

                    if (reauthenticated) {
                      await _authService.changePassword(
                        newPasswordController.text,
                      );
                      if (mounted) {
                        Navigator.of(dialogContext).pop(); // Cerrar el diálogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contraseña cambiada con éxito.'),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        // No cerrar el diálogo, mostrar error dentro del diálogo o con SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Error: La contraseña actual es incorrecta.',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al cambiar la contraseña: $e'),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return PixelCard(
      key: _missionsKey, // Asignar la key a las estadísticas
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTADÍSTICAS', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _buildStatItem(
            Icons.help_outline,
            'Preguntas contestadas',
            '${_userData!['stats']?['questionsAnswered'] ?? 0}',
          ),
          _buildStatItem(
            Icons.check_circle,
            'Respuestas correctas',
            '${_userData!['stats']?['correctAnswers'] ?? 0}',
          ),
          _buildStatItem(
            Icons.emoji_events,
            'Batallas ganadas',
            '${_userData!['stats']?['battlesWon'] ?? 0}',
          ),
          _buildStatItem(
            Icons.mood_bad,
            'Batallas perdidas',
            '${_userData!['stats']?['battlesLost'] ?? 0}',
          ),

          const SizedBox(height: 16),
          Text(
            'Misiones completadas: ${_userData!['completedMissions']?.length ?? 0}',
          ),

          if (_userData!['completedMissions']?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCompletedMissions = !_showCompletedMissions;
                      });
                    },
                    child: Text(
                      _showCompletedMissions
                          ? 'Ocultar misiones completadas'
                          : 'Ver misiones completadas',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  if (_showCompletedMissions)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          _userData!['completedMissions'].length,
                          (index) => ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              disabledBackgroundColor: Colors.green.withAlpha(
                                179,
                              ),
                              disabledForegroundColor: Colors.white,
                            ),
                            child: Text('Misión ${index + 1}'),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          OverflowUtils.expandedText(label, maxLines: 1),
          const SizedBox(width: 8),
          OverflowUtils.safeText(value, maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildAdventureButton() {
    return Center(
      child: PixelButton(
        key:
            _adventureButtonKey, // Usar la key correcta para el botón de aventura
        onPressed: () {
          Navigator.pushNamed(context, '/missions');
        },
        color: Theme.of(context).colorScheme.secondary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, size: 20),
            SizedBox(width: 8),
            OverflowUtils.flexibleText('COMENZAR AVENTURA', maxLines: 1),
          ],
        ),
      ),
    );
  }

  // Botón para entrar a la Tienda
  Widget _buildShopButton() {
    return Center(
      child: PixelButton(
        key: _shopButtonKey, // Asignar la key al botón de tienda
        onPressed: () {
          Navigator.pushNamed(context, '/shop');
        },
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 20),
            SizedBox(width: 8),
            OverflowUtils.flexibleText('TIENDA', maxLines: 1),
          ],
        ),
      ),
    );
  }

  // Botón para acceder al Inventario
  Widget _buildInventoryButton() {
    return Center(
      child: PixelButton(
        key: _inventoryButtonKey, // Asignar la key al botón de inventario
        onPressed: () {
          Navigator.pushNamed(context, '/inventory');
        },
        color: Theme.of(context).colorScheme.secondary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 20),
            SizedBox(width: 8),
            OverflowUtils.flexibleText('INVENTARIO', maxLines: 1),
          ],
        ),
      ),
    );
  }

  // Botón para acceder a los Ejercicios de Código
  Widget _buildCodeExercisesButton() {
    return Center(
      child: PixelButton(
        key: _codeExercisesButtonKey, // Asignar la key al botón de ejercicios
        onPressed: () {
          Navigator.pushNamed(context, '/code-exercises');
        },
        color: Colors.purple[600] ?? Colors.purple,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: 20),
            SizedBox(width: 8),
            OverflowUtils.flexibleText('EJERCICIOS DE CÓDIGO', maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return PixelCard(
      key: _achievementsKey, // Asignar la key a la sección de logros
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'LOGROS',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            // Usar Center para posicionar el botón
            child: PixelButton(
              onPressed: () {
                Navigator.pushNamed(context, '/achievements');
              },
              color: Theme.of(context).colorScheme.tertiary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ), // Mantener un padding adecuado
                child: Row(
                  mainAxisSize:
                      MainAxisSize
                          .min, // Clave para que el botón se ajuste al contenido
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, size: 20),
                    const SizedBox(width: PixelTheme.spacingSmall),
                    OverflowUtils.flexibleText(
                      'VER MIS LOGROS',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botón para acceder a la Tabla de Clasificación
  Widget _buildLeaderboardButton() {
    return Center(
      child: PixelButton(
        key: _leaderboardKey, // Asignar la key al botón de leaderboard
        onPressed: () {
          Navigator.pushNamed(context, '/leaderboard');
        },
        color: Theme.of(context).colorScheme.tertiary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 20),
            SizedBox(width: 8),
            OverflowUtils.flexibleText('CLASIFICACIÓN', maxLines: 1),
          ],
        ),
      ),
    );
  }

  double _calculateExpProgress() {
    int currentExp = _userData!['experience'] ?? 0;
    int maxExp = _getCurrentLevelMaxExp();
    return currentExp / maxExp;
  }

  int _getCurrentLevelMaxExp() {
    return 400; // Cada nivel requiere 400 XP
  }
}

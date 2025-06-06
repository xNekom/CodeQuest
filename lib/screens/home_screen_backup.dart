// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/tutorial_service.dart';
import '../widgets/pixel_widgets.dart';
import '../widgets/character_asset.dart';
import '../widgets/tutorial_floating_button.dart';
import '../utils/error_handler.dart';
import '../widgets/test_error_widget.dart';


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
    _loadUserData();
    _checkAndStartTutorial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      // Usar Future.microtask en lugar de addPostFrameCallback para evitar bucles infinitos
      Future.microtask(() {
        if (mounted) {
          _loadUserData();
        }
      });
    }
  }

  /// Inicia el tutorial si es necesario
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente, pero con un tiempo menor
    await Future.delayed(const Duration(milliseconds: 500));

    // Verificar si el widget sigue montado antes de continuar
    if (!mounted) return;

    try {
      TutorialService.startTutorialIfNeeded(
        context,
        TutorialService.homeScreenTutorial,
        TutorialService.getHomeScreenTutorial(
          profileKey: _profileKey,
          missionsKey: _missionsKey,
          achievementsKey: _achievementsKey,
          leaderboardKey: _leaderboardKey,
          adventureButtonKey: _adventureButtonKey,
          shopButtonKey: _shopButtonKey,
          inventoryButtonKey: _inventoryButtonKey,
        ),
      );
    } catch (e) {
      // Capturar cualquier error que pueda ocurrir durante la inicialización del tutorial
      ErrorHandler.logError(e, StackTrace.current);
      // No mostrar error al usuario para no interrumpir la experiencia
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
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
        ),
      ),
    );
  }

  Widget _buildUserDataContent() {
    return SafeArea(
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
    );
  }

  Widget _buildAppBar() {
    // Determinar si el usuario es admin
    final bool isAdmin = _userData != null && _userData!['role'] == 'admin';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: Theme.of(
          context,
        ).colorScheme.surface.withAlpha(230), // 0.9 * 255 ≈ 230
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(
            'CODEQUEST',
            style: GoogleFonts.pressStart2p(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin) ...[
                  // Mostrar botones de admin solo si el usuario es admin
                  // Widget para probar errores (solo visible para administradores)
                  const TestErrorWidget(),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Panel de Administrador',
                    onPressed: () {
                      Navigator.pushNamed(context, '/admin');
                    },
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/auth');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar Personaje',
                  onPressed: () async {
                    // Navegar a selección/edición de personaje
                    await Navigator.pushNamed(context, '/character');
                    // Recargar datos del usuario para reflejar cambios
                    await _loadUserData();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return PixelCard(
      key: _profileKey, // Asignar la key al perfil
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 400;
          return Column(
            children: [
              isWide
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'avatar_${_userData!['username']}',
                        child: CharacterAsset(
                          assetIndex:
                              _userData!['characterAssetIndex'] as int? ?? 0,
                          size: 80,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildUserInfo()),
                    ],
                  )
                  : Column(
                    children: [
                      Hero(
                        tag: 'avatar_${_userData!['username']}',
                        child: CharacterAsset(
                          assetIndex:
                              _userData!['characterAssetIndex'] as int? ?? 0,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildUserInfo(),
                    ],
                  ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_userData!['username']}',
          style: Theme.of(context).textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Nivel: ${_userData!['level'] ?? 1}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.monetization_on, size: 18, color: Colors.amber),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${_userData!['coins'] ?? 0} monedas',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.lock_reset),
          label: const Text('Cambiar Contraseña'),
          onPressed: _showChangePasswordDialog,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
        ),
      ],
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
                      ), // Reemplazado .withOpacity(0.7)
                      disabledForegroundColor: Colors.white,
                    ),
                    child: Text('Misión ${index + 1}'),
                  ),
                ),
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
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
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
            Flexible(
              child: Text('COMENZAR AVENTURA', overflow: TextOverflow.ellipsis),
            ),
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
            Flexible(child: Text('TIENDA', overflow: TextOverflow.ellipsis)),
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
            Flexible(
              child: Text('INVENTARIO', overflow: TextOverflow.ellipsis),
            ),
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
            Flexible(
              child: Text(
                'EJERCICIOS DE CÓDIGO',
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'VER MIS LOGROS',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
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
            Flexible(
              child: Text('CLASIFICACIÓN', overflow: TextOverflow.ellipsis),
            ),
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

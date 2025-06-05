import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme/pixel_theme.dart';
import 'screens/admin/admin_screen.dart';
import 'services/user_service.dart';
import 'screens/game/character_selection_screen.dart';
import 'widgets/reward_notification_manager.dart';
import 'package:codequest/screens/auth/password_recovery_screen.dart';
import 'screens/achievements_screen.dart'; // Importar AchievementsScreen
import 'screens/missions/missions_screen.dart'; // Importar MissionsScreen
import 'screens/shop_screen.dart'; // Importar ShopScreen
import 'screens/inventory_screen.dart'; // Importar InventoryScreen
import 'screens/leaderboard_screen.dart'; // Importar LeaderboardScreen
import 'screens/error_log_screen.dart'; // Importar ErrorLogScreen
// import 'screens/debug_firebase_screen.dart'; // Importar DebugFirebaseScreen - REMOVIDO PARA PRODUCCIÓN
import 'screens/tutorials_screen.dart'; // Importar TutorialsScreen
import 'screens/code_exercises_screen.dart'; // Importar CodeExercisesScreen
import 'utils/error_handler.dart'; // Importar ErrorHandler
import 'utils/navigator_error_observer.dart'; // Importar ErrorHandlingNavigatorObserver
import 'utils/platform_utils.dart'; // Importar PlatformUtils
import 'utils/overflow_utils.dart'; // Importar OverflowUtils y NavigationService

// Clave global para ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Clave global para Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ejecutar la app dentro de una zona que captura errores
  runZonedGuarded(
    () async {
      // Asegura que Flutter esté inicializado
      WidgetsFlutterBinding.ensureInitialized();
      
      // Configurar el NavigationService con la clave global
      NavigationService.navigatorKey = navigatorKey;

      try {
        // Configurar el manejador global de errores
        await ErrorHandler.setupGlobalErrorHandling();
        // Configurar timeouts más largos para operaciones de red en modo de desarrollo
        // Solo en plataformas que soportan HttpClient (no web)
        if (PlatformUtils.supportsHttpClient) {
          // Los timeouts de HTTP se configuran por cliente específico según sea necesario
          // No se necesita configuración global aquí
        }

        // Configurar ajustes específicos de plataforma
        PlatformUtils.configurePlatform();

        // Inicializar Firebase
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        runApp(const MyApp());
      } catch (e, stack) {
        // Manejar errores durante la inicialización
        // debugPrint('Error crítico durante la inicialización: $e'); // REMOVIDO PARA PRODUCCIÓN
    // debugPrint(stack.toString()); // REMOVIDO PARA PRODUCCIÓN

        // Intenta ejecutar una versión mínima de la app que permite reintentar
        runApp(_buildEmergencyApp(e, stack));
      }
    },
    (error, stackTrace) {
      ErrorHandler.logError(error, stackTrace);
    },
  );
}

Widget _buildEmergencyApp(dynamic error, StackTrace stack) {
  return MaterialApp(
    title: 'CodeQuest - Modo de emergencia',
    navigatorKey: navigatorKey,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    ),
    home: Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51), // 0.2 * 255 ≈ 51
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error crítico de inicialización',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'No se pudo iniciar la aplicación: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => main(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Capturar errores durante la construcción de widgets
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      // Registrar el error de forma segura sin usar contexto
      try {
        ErrorHandler.logError(errorDetails.exception, errorDetails.stack);
      } catch (e) {
        // Si falla el logging, al menos imprimir en consola
        // debugPrint('Error logging failed: $e'); // REMOVIDO PARA PRODUCCIÓN
      // debugPrint('Original error: ${errorDetails.exception}'); // REMOVIDO PARA PRODUCCIÓN
      }
      
      // Crear un widget de error simple sin usar Theme.of(context) para evitar bucles infinitos
      return Material(
        child: Container(
          color: const Color(0xFF8B0000), // Colors.red[900] hardcodeado
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Algo salió mal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${errorDetails.exception}',
                  style: const TextStyle(color: Color(0xFFB3B3B3)), // Colors.white70 hardcodeado
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Usar el navigatorKey global para navegar desde el contexto de error
                    try {
                      navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
                    } catch (e) {
                      // debugPrint('Error en navegación desde ErrorWidget: $e'); // REMOVIDO PARA PRODUCCIÓN
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B0000),
                  ),
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    };

    return MaterialApp(
      title: 'CodeQuest',
      debugShowCheckedModeBanner: false,
      theme: PixelTheme.lightTheme,
      darkTheme: PixelTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute:
          '/', // Configurar el manejador de errores a nivel de navegación
      navigatorObservers: [ErrorHandlingNavigatorObserver()],
      // Configurar Navigator global
      navigatorKey: navigatorKey,
      // Configurar ScaffoldMessenger global para snackbars
      scaffoldMessengerKey: scaffoldMessengerKey,
      // Página que se muestra cuando se navega a una ruta que no existe
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Ruta no encontrada')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Ruta no encontrada',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('No pudimos encontrar: ${settings.name}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/home', (route) => false);
                        },
                        child: const Text('Volver al inicio'),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
      routes: {
        '/':
            (context) =>
                const RewardNotificationManager(child: AuthCheckScreen()),
        '/auth':
            (context) => const RewardNotificationManager(child: AuthWrapper()),
        '/character':
            (context) => const RewardNotificationManager(
              child: CharacterSelectionScreen(),
            ),
        '/character-selection':
            (context) => const RewardNotificationManager(
              child: CharacterSelectionScreen(),
            ),
        '/home':
            (context) => const RewardNotificationManager(child: HomeScreen()),
        '/admin':
            (context) => const RewardNotificationManager(child: AdminScreen()),
        '/password-recovery':
            (context) => const RewardNotificationManager(
              child: PasswordRecoveryScreen(),
            ),
        '/achievements':
            (context) =>
                const RewardNotificationManager(child: AchievementsScreen()),
        '/missions':
            (context) =>
                const RewardNotificationManager(child: MissionsScreen()),
        '/shop':
            (context) => const RewardNotificationManager(child: ShopScreen()),
        '/inventory':
            (context) =>
                const RewardNotificationManager(child: InventoryScreen()),
        '/leaderboard':
            (context) =>
                const RewardNotificationManager(child: LeaderboardScreen()),
        '/tutorials':
            (context) =>
                const RewardNotificationManager(child: TutorialsScreen()),
        '/code-exercises':
            (context) =>
                const RewardNotificationManager(child: CodeExercisesScreen()),
        '/error-logs':
            (context) => const ErrorLogScreen(), // Nueva ruta para ver los logs
        // '/debug-firebase': (context) => const DebugFirebaseScreen(), // REMOVIDO PARA PRODUCCIÓN
      },
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Limitar la animación a 3 repeticiones para evitar bucles infinitos
    _startLimitedAnimation();
  }

  void _startLimitedAnimation() {
    int repeatCount = 0;
    const maxRepeats = 3;
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        repeatCount++;
        if (repeatCount < maxRepeats * 2) { // *2 porque cada ciclo tiene completed y dismissed
          if (status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
        }
      }
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(
                          51,
                        ), // Reemplazado .withOpacity(0.2)
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.code,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'CodeQuest',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Aventura de programación en Java'),
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildSplashScreen(); // Muestra splash mientras espera el estado de auth
        }

        final User? user = authSnapshot.data;

        if (user != null) {
          // Usuario autenticado, verificar characterSelected
          return FutureBuilder<Map<String, dynamic>?>(
            future: _userService.getUserData(
              user.uid,
            ), // Obtener datos del usuario
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildSplashScreen(); // Muestra splash mientras carga datos del usuario
              }

              String routeToGo = '/auth'; // Ruta por defecto si algo falla

              if (userSnapshot.hasError) {
                // Error al cargar datos del usuario (ej. problemas de red)
                // Podrías ir a una pantalla de error o reintentar. Por ahora, a /auth.
                // print("Error al cargar datos del usuario: ${userSnapshot.error}"); // Comentado: avoid_print
                routeToGo = '/auth';
              } else {
                // No hay error en FutureBuilder, procesar userData
                final userData =
                    userSnapshot
                        .data; // Puede ser null si el documento no existe
                final role = userData?['role'] as String? ?? 'user';
                // Si userData es null (doc no existe) o characterSelected no está, se asume false.
                final characterSelected =
                    userData?['characterSelected'] as bool? ?? false;

                if (role == 'admin') {
                  // Los administradores siempre van a /home después del login.
                  // Accederán a /admin a través del botón en HomeScreen.
                  routeToGo = '/home';
                } else if (!characterSelected) {
                  // Si no es admin y el personaje no está seleccionado, va a /character
                  routeToGo = '/character';
                } else {
                  // Si no es admin y el personaje SÍ está seleccionado, va a /home
                  routeToGo = '/home';
                }
              }

              // Navegar usando Future.microtask para evitar infinite rebuilds
              final navigator = Navigator.of(context);
              Future.microtask(() {
                if (mounted) {
                  // Asegurarse que el widget sigue montado antes de navegar
                  navigator.pushReplacementNamed(routeToGo);
                }
              });
              // Muestra el splash screen mientras la navegación ocurre
              return _buildSplashScreen();
            },
          );
        } else {
          // Usuario no autenticado
          final navigator = Navigator.of(context);
          Future.microtask(() {
            if (mounted) {
              navigator.pushReplacementNamed('/auth');
            }
          });
          return _buildSplashScreen(); // Muestra splash mientras navega a /auth
        }
      },
    );
  }
}

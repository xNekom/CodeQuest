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
import 'screens/game/character_creation_screen.dart';
import 'widgets/reward_notification_manager.dart';
import 'package:codequest/screens/auth/password_recovery_screen.dart';
import 'screens/achievements_screen.dart'; // Importar AchievementsScreen
import 'screens/missions/missions_screen.dart'; // Importar MissionsScreen
import 'screens/shop_screen.dart'; // Importar ShopScreen
import 'screens/inventory_screen.dart'; // Importar InventoryScreen
import 'screens/leaderboard_screen.dart'; // Importar LeaderboardScreen
import 'screens/error_log_screen.dart'; // Importar ErrorLogScreen
import 'utils/error_handler.dart'; // Importar ErrorHandler
import 'utils/navigator_error_observer.dart'; // Importar ErrorHandlingNavigatorObserver
import 'utils/platform_utils.dart'; // Importar PlatformUtils

void main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  try {    // Configurar el manejador global de errores
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
    
    // Ejecutar la app dentro de una zona que captura errores
    runZonedGuarded(
      () {
        runApp(const MyApp());
      },
      (error, stackTrace) {
        ErrorHandler.logError(error, stackTrace);
      },
    );
  } catch (e, stack) {
    // Manejar errores durante la inicialización
    debugPrint('Error crítico durante la inicialización: $e');
    debugPrint(stack.toString());
    
    // Intenta ejecutar una versión mínima de la app que permite reintentar
    runApp(
      MaterialApp(
        title: 'CodeQuest - Modo de emergencia',
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
                    color: Colors.black.withValues(alpha: 0.2),
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
                    'No se pudo iniciar la aplicación: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => main(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Capturar errores durante la construcción de widgets
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      ErrorHandler.logError(errorDetails.exception, errorDetails.stack);
      return Material(
        child: Container(
          color: Colors.red[900],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops! Algo salió mal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${errorDetails.exception}',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[900],
                  ),
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    };
    
    return MaterialApp(      title: 'CodeQuest',
      debugShowCheckedModeBanner: false,
      theme: PixelTheme.lightTheme,
      darkTheme: PixelTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',      // Configurar el manejador de errores a nivel de navegación
      navigatorObservers: [
        ErrorHandlingNavigatorObserver(),
      ],
      // Página que se muestra cuando se navega a una ruta que no existe
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Ruta no encontrada')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
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
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    child: const Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        );
      },      routes: {
        '/': (context) => const RewardNotificationManager(child: AuthCheckScreen()),
        '/auth': (context) => const RewardNotificationManager(child: AuthWrapper()),
        '/character': (context) => const RewardNotificationManager(child: CharacterCreationScreen()),
        '/home': (context) => const RewardNotificationManager(child: HomeScreen()),
        '/admin': (context) => const RewardNotificationManager(child: AdminScreen()),
        '/password-recovery': (context) => const RewardNotificationManager(child: PasswordRecoveryScreen()),
        '/achievements': (context) => const RewardNotificationManager(child: AchievementsScreen()),
        '/missions': (context) => const RewardNotificationManager(child: MissionsScreen()),
        '/shop': (context) => const RewardNotificationManager(child: ShopScreen()),
        '/inventory': (context) => const RewardNotificationManager(child: InventoryScreen()),
        '/leaderboard': (context) => const RewardNotificationManager(child: LeaderboardScreen()),
        '/error-logs': (context) => const ErrorLogScreen(), // Nueva ruta para ver los logs
      },
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> with SingleTickerProviderStateMixin {
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
    _animationController.repeat(reverse: true);
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
                        color: Colors.black.withAlpha(51), // Reemplazado .withOpacity(0.2)
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
              const Text(
                'Aventura de programación en Java',
              ),
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
          // Usuario autenticado, verificar characterCreated
          return FutureBuilder<Map<String, dynamic>?>(
            future: _userService.getUserData(user.uid), // Obtener datos del usuario
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
                final userData = userSnapshot.data; // Puede ser null si el documento no existe
                final role = userData?['role'] as String? ?? 'user';
                // Si userData es null (doc no existe) o characterCreated no está, se asume false.
                final characterCreated = userData?['characterCreated'] as bool? ?? false;

                if (role == 'admin') {
                  // Los administradores siempre van a /home después del login.
                  // Accederán a /admin a través del botón en HomeScreen.
                  routeToGo = '/home';
                } else if (!characterCreated) {
                  // Si no es admin y el personaje no está creado, va a /character
                  routeToGo = '/character';
                } else {
                  // Si no es admin y el personaje SÍ está creado, va a /home
                  routeToGo = '/home';
                }
              }
              
              // Navegar después de que el frame actual se construya
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) { // Asegurarse que el widget sigue montado antes de navegar
                  Navigator.pushReplacementNamed(context, routeToGo);
                }
              });
              // Muestra el splash screen mientras la navegación ocurre en el siguiente frame.
              // Esto evita parpadeos o construir la UI de la pantalla anterior brevemente.
              return _buildSplashScreen(); 
            },
          );
        } else {
          // Usuario no autenticado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/auth');
            }
          });
          return _buildSplashScreen(); // Muestra splash mientras navega a /auth
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RewardNotificationManager(
      child: MaterialApp(
        title: 'CodeQuest',
        debugShowCheckedModeBanner: false,
        theme: PixelTheme.lightTheme,
        darkTheme: PixelTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthCheckScreen(),
          '/auth': (context) => const AuthWrapper(),
          '/character': (context) => const CharacterCreationScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminScreen(),
          '/password-recovery': (context) => const PasswordRecoveryScreen(), // Nueva ruta
        },
      ),
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
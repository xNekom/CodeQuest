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
import 'screens/missions/mission_list_screen.dart';
import 'screens/game/character_creation_screen.dart';

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
    return MaterialApp(
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
        '/missions': (context) => const MissionListScreen(),
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
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animación
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _controller.repeat(reverse: true);
    _checkAuthentication();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    User? user = _authService.currentUser;

    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      if (user != null) {
        final userData = await _userService.getUserData(user.uid);
        if (!mounted) return;
        final role = userData?['role'] as String? ?? 'user';
        if (role != 'admin') {
          final created = userData?['characterCreated'] as bool? ?? false;
          if (!mounted) return;
          if (!created) {
            Navigator.pushReplacementNamed(context, '/character');
            return;
          }
        }
        if (!mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
}
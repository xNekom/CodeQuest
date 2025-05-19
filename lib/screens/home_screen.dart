import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/pixel_widgets.dart';
import '../widgets/character_pixelart.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      User? user = _authService.currentUser;
      if (user != null) {
        final userData = await _userService.getUserData(user.uid);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        // No hay usuario autenticado, redirigir a la pantalla de inicio de sesión
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      }
    } catch (e) {
      // Usar logger en lugar de print en producción
      debugPrint('Error al cargar datos del usuario: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _userData == null
                ? const Center(
                    child: Text('No se encontraron datos del usuario'),
                  )
                : _buildUserDataContent(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2,2))],
      ),
      child: Row(
        children: [
          const Text(
            'CODEQUEST',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(),
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
              // Navegar a creación/edición de personaje
              await Navigator.pushNamed(context, '/character');
              // Recargar datos del usuario para reflejar cambios
              await _loadUserData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return PixelCard(
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        return Column(
          children: [
            isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(tag: 'avatar_${_userData!['username']}', child: CharacterPixelArt(
                      skinTone: _userData!['skinTone'] as String,
                      hairStyle: _userData!['hairStyle'] as String,
                      outfit: _userData!['outfit'] as String,
                      size: 80,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildUserInfo()),
                  ],
                )
              : Column(
                  children: [
                    Hero(tag: 'avatar_${_userData!['username']}', child: CharacterPixelArt(
                      skinTone: _userData!['skinTone'] as String,
                      hairStyle: _userData!['hairStyle'] as String,
                      outfit: _userData!['outfit'] as String,
                      size: 80,
                    )),
                    const SizedBox(height: 8),
                    _buildUserInfo(),
                  ],
                ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _calculateExpProgress()),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Column(children: [
                  const Text('Experiencia'),
                  const SizedBox(height: 4),
                  PixelProgressBar(value: value, label: '${(_userData!['experience'] ?? 0)} / ${_getCurrentLevelMaxExp()} XP'),
                ]);
              },
            ),
          ],
        );
      }),
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
        Row(children: [Icon(Icons.star, size: 18), const SizedBox(width: 8), Text('Nivel: ${_userData!['level'] ?? 1}')]),
        const SizedBox(height: 4),
        Row(children: [Icon(Icons.monetization_on, size: 18, color: Colors.amber), const SizedBox(width: 8), Text('${_userData!['coins'] ?? 0} monedas')]),
      ],
    );
  }

  Widget _buildStatsSection() {
    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTADÍSTICAS',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildStatItem(Icons.help_outline, 'Preguntas contestadas', '${_userData!['stats']?['questionsAnswered'] ?? 0}'),
          _buildStatItem(Icons.check_circle, 'Respuestas correctas', '${_userData!['stats']?['correctAnswers'] ?? 0}'),
          _buildStatItem(Icons.emoji_events, 'Batallas ganadas', '${_userData!['stats']?['battlesWon'] ?? 0}'),
          _buildStatItem(Icons.mood_bad, 'Batallas perdidas', '${_userData!['stats']?['battlesLost'] ?? 0}'),
          
          const SizedBox(height: 16),
          Text('Misiones completadas: ${_userData!['completedMissions']?.length ?? 0}'),
          
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
                      disabledBackgroundColor: Colors.green.withAlpha(179), // Reemplazado .withOpacity(0.7)
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
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAdventureButton() {
    return Center(
      child: PixelButton(
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
            Text('COMENZAR AVENTURA'),
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
    int currentLevel = _userData!['level'] ?? 1;
    return currentLevel * 100; // Nivel actual * 100 es la experiencia requerida
  }
}
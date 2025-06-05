import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../widgets/pixel_widgets.dart';
import '../../models/enemy_model.dart';
import '../../models/battle_config_model.dart';
import '../../services/enemy_service.dart';
import '../../services/audio_service.dart';
import './battle_screen.dart';

class EnemyEncounterScreen extends StatefulWidget {
  final BattleConfigModel battleConfig;
  final bool isReplay;

  const EnemyEncounterScreen({
    super.key,
    required this.battleConfig,
    this.isReplay = false,
  });

  @override
  State<EnemyEncounterScreen> createState() => _EnemyEncounterScreenState();
}

class _EnemyEncounterScreenState extends State<EnemyEncounterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnim;
  late Animation<double> _slideInAnim;

  final EnemyService _enemyService = EnemyService();
  final AudioService _audioService = AudioService();
  EnemyModel? _enemy;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideInAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    );

    _loadEnemyData();
    // Reproducir música de batalla al entrar en el encuentro
    _audioService.playBattleTheme();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Solo cargar datos si no se han cargado previamente
    if (mounted && _enemy == null && _errorMessage.isEmpty && !_isLoading) {
      _loadEnemyData();
    }
  }

  Future<void> _loadEnemyData() async {
    try {
      _enemy = await _enemyService.getEnemyById(widget.battleConfig.enemyId);
      if (_enemy != null) {
        _controller.forward();
      } else {
        setState(() {
          _errorMessage = 'No se pudo encontrar el enemigo';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el enemigo: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startBattle() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => BattleScreen(
              battleConfig: widget.battleConfig,
              isReplay: widget.isReplay,
            ),
      ),
    );
  }

  Widget _buildEnemyImage() {
    return _buildEnemyPlaceholder();
  }

  Widget _buildEnemyPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.shade600,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bug_report,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            'ENEMIGO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Volver a la música principal al salir del encuentro
    _audioService.playMainTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Preparando encuentro...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PixelButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/background_enemy.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Título dramático
                AnimatedBuilder(
                  animation: _fadeInAnim,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeInAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, -20 * (1 - _fadeInAnim.value)),
                        child: Text(
                          '¡UN ENEMIGO SALVAJE APARECE!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                              Shadow(
                                color: Colors.red.shade700,
                                blurRadius: 15,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),

                // Imagen del enemigo
                AnimatedBuilder(
                  animation: _slideInAnim,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _slideInAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(-50 * (1 - _slideInAnim.value), 0),
                        child: _buildEnemyImage(),
                      ),
                    );
                  },
                ),

                // Información del enemigo
                AnimatedBuilder(
                  animation: _slideInAnim,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _slideInAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(50 * (1 - _slideInAnim.value), 0),
                        child: Column(
                          children: [
                            Text(
                              _enemy?.name ?? 'Enemigo Desconocido',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _enemy?.description ??
                                  'Un enemigo peligroso aparece',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Diálogo del enemigo
                AnimatedBuilder(
                  animation: _slideInAnim,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _slideInAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - _slideInAnim.value)),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.shade400,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.format_quote,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _enemy?.dialogue?['encounter'] ??
                                      'El enemigo te mira amenazadoramente...',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.format_quote,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Botones de acción
                AnimatedBuilder(
                  animation: _slideInAnim,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _slideInAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - _slideInAnim.value)),
                        child: Column(
                          children: [
                            PixelButton(
                              onPressed: _startBattle,
                              color: Colors.red.shade600,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flash_on, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '¡ENTRAR EN BATALLA!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            PixelButton(
                              onPressed: () => Navigator.pop(context),
                              isSecondary: true,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PixelIcon(Pixel.chevronleft),
                                  const SizedBox(width: 8),
                                  const Text('Huir'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

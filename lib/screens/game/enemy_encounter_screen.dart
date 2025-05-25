import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../widgets/pixel_widgets.dart';
import '../../models/enemy_model.dart';
import '../../models/battle_config_model.dart';
import '../../services/enemy_service.dart';
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _loadEnemyData();
      }
    });
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
    if (_enemy?.assetPath != null && _enemy!.assetPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          _enemy!.assetPath!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildEnemyPlaceholder();
          },
        ),
      );
    } else {
      return _buildEnemyPlaceholder();
    }
  }

  Widget _buildEnemyPlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade300,
            Colors.red.shade600,
            Colors.red.shade900,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bug_report,
            size: 80,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ENEMIGO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
      body: FadeTransition(
        opacity: _fadeInAnim,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.red.shade900.withOpacity(0.3),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        48,
                  ),
                  child: Column(
                    children: [
                      // Título dramático
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_slideInAnim),
                        child: Text(
                          '¡UN ENEMIGO SALVAJE APARECE!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade300,
                            shadows: [
                              Shadow(
                                color: Colors.red.shade700,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Imagen del enemigo
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.5, 0),
                          end: Offset.zero,
                        ).animate(_slideInAnim),
                        child: _buildEnemyImage(),
                      ),

                      const SizedBox(height: 24),

                      // Información del enemigo
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.5, 0),
                          end: Offset.zero,
                        ).animate(_slideInAnim),
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
                                    color: Colors.black.withOpacity(0.7),
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
                                color: Colors.red.shade300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Diálogo del enemigo
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_slideInAnim),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.shade400,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.format_quote,
                                    color: Colors.red.shade300,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Diálogo de Encuentro',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red.shade300,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.format_quote,
                                    color: Colors.red.shade300,
                                    size: 20,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              Text(
                                _enemy?.dialogue?['encounter'] ??
                                    'El enemigo te mira amenazadoramente...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botones de acción
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(_slideInAnim),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

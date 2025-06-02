import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';
import '../utils/overflow_utils.dart';
import 'interactive_tutorial.dart';

/// Widget del botón flotante para tutoriales
class TutorialFloatingButton extends StatefulWidget {
  /// Lista de pasos del tutorial para esta pantalla
  final List<InteractiveTutorialStep>? tutorialSteps;

  /// Clave única del tutorial para esta pantalla
  final String? tutorialKey;

  /// Callback adicional cuando se inicia un tutorial
  final VoidCallback? onTutorialStart;

  const TutorialFloatingButton({
    super.key,
    this.tutorialSteps,
    this.tutorialKey,
    this.onTutorialStart,
  });

  @override
  State<TutorialFloatingButton> createState() => _TutorialFloatingButtonState();
}

class _TutorialFloatingButtonState extends State<TutorialFloatingButton>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _startTutorial() {
    if (widget.tutorialSteps != null && widget.tutorialKey != null) {
      widget.onTutorialStart?.call();
      TutorialService.showTutorialDialog(
        context,
        widget.tutorialSteps!,
        tutorialKey: widget.tutorialKey,
      );
      _toggleMenu(); // Cerrar menú después de iniciar tutorial
    }
  }

  void _showAllTutorials() {
    _showTutorialSelectionDialog();
    _toggleMenu();
  }

  void _showTutorialSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: OverflowUtils.safeRow(
              children: [
                const Icon(Icons.school, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: OverflowUtils.safeText('Selecciona un Tutorial'),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TutorialOption(
                    title: 'Centro de Comando 🚀',
                    description:
                        'Domina tu nave espacial y explora todas las funciones épicas',
                    icon: Icons.rocket_launch,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                  ),

                  const SizedBox(height: 8),
                  _TutorialOption(
                    title: 'Reino de Aventuras 🏰',
                    description: 'Conquista misiones épicas y desafíos legendarios',
                    icon: Icons.castle,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/missions');
                    },
                  ),
                  const SizedBox(height: 8),
                  _TutorialOption(
                    title: 'Salón de la Fama 🏆',
                    description: 'Descubre cómo forjar tu leyenda como programador',
                    icon: Icons.museum,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/achievements');
                    },
                  ),
                  const SizedBox(height: 8),
                  _TutorialOption(
                    title: 'Briefing de Misión 📋',
                    description:
                        'Aprende a planificar tu estrategia de conquista',
                    icon: Icons.assignment_ind,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/missions');
                    },
                  ),
                  const SizedBox(height: 8),
                  _TutorialOption(
                    title: 'Academia de Conocimiento 🎓',
                    description: 'Transforma teoría en superpoderes de programación',
                    icon: Icons.school,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/missions');
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Solo mostrar el FAB si hay tutoriales disponibles
    final hasTutorials =
        widget.tutorialSteps != null && widget.tutorialSteps!.isNotEmpty;

    if (!hasTutorials) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Botón principal con estilo pixel art
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleMenu,
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 3.14159,
                        child: Icon(
                          _isMenuOpen ? Icons.close : Icons.help,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        // Menú de opciones con mejor espaciado
        if (_isMenuOpen) ...[
          // Tutorial de esta pantalla
          Positioned(
            right: 16,
            bottom: 88, // Reducido el espaciado
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _startTutorial,
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Todos los tutoriales
          Positioned(
            right: 72, // Movido a la izquierda para evitar solapamiento
            bottom: 88,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showAllTutorials,
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.list,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget para una opción de tutorial en el diálogo de selección
class _TutorialOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _TutorialOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withAlpha((0.3 * 255).round())),
          borderRadius: BorderRadius.circular(8),
        ),
        child: OverflowUtils.safeRow(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverflowUtils.safeText(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 2),
                  OverflowUtils.safeText(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

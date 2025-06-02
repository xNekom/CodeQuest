import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';
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

class _TutorialFloatingButtonState extends State<TutorialFloatingButton> {
  bool _isPressed = false;

  void _startTutorial() {
    if (widget.tutorialSteps != null && widget.tutorialSteps!.isNotEmpty) {
      TutorialService.startTutorial(
        context,
        widget.tutorialSteps!,
        tutorialKey: widget.tutorialKey,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    // Solo mostrar el FAB si hay tutoriales disponibles
    final hasTutorials =
        widget.tutorialSteps != null && widget.tutorialSteps!.isNotEmpty;

    if (!hasTutorials) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: _isPressed ? Colors.green.shade700 : Colors.green,
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
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 90,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  'Tutorial',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';
import 'interactive_tutorial.dart';

/// Widget para gestionar el estado de los tutoriales en una pantalla
class TutorialManager extends StatefulWidget {
  /// Widget hijo que se renderiza
  final Widget child;
  
  /// Clave del tutorial para esta pantalla
  final String tutorialKey;
  
  /// Pasos del tutorial
  final List<InteractiveTutorialStep> tutorialSteps;
  
  /// Si debe mostrar el tutorial automáticamente al cargar la pantalla
  final bool autoStart;
  
  /// Callback cuando se completa el tutorial
  final VoidCallback? onTutorialCompleted;
  
  /// Callback cuando se cancela el tutorial
  final VoidCallback? onTutorialCancelled;

  const TutorialManager({
    super.key,
    required this.child,
    required this.tutorialKey,
    required this.tutorialSteps,
    this.autoStart = true,
    this.onTutorialCompleted,
    this.onTutorialCancelled,
  });

  @override
  State<TutorialManager> createState() => _TutorialManagerState();
}

class _TutorialManagerState extends State<TutorialManager> {
  bool _isTutorialActive = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _checkAndStartTutorial();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  /// Verifica si el tutorial debe iniciarse automáticamente
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final tutorialService = TutorialService();
    final isCompleted = await tutorialService.isTutorialCompleted(widget.tutorialKey);
    
    if (!isCompleted && mounted) {
      TutorialService.startTutorialIfNeeded(
        context,
        widget.tutorialKey,
        widget.tutorialSteps,
      );
    }
  }

  /// Inicia el tutorial manualmente
  void startTutorial() {
    if (_isTutorialActive || !mounted) return;
    
    setState(() {
      _isTutorialActive = true;
    });
    
    _showTutorialOverlay();
  }

  /// Muestra el overlay del tutorial
  void _showTutorialOverlay() {
    if (!mounted) return;
    
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => InteractiveTutorial(
        steps: widget.tutorialSteps,
        autoStart: true,
        onComplete: _onTutorialCompleted,
        onCancel: _onTutorialCancelled,
        child: const SizedBox.shrink(),
      ),
    );
    
    overlay.insert(_overlayEntry!);
  }

  /// Maneja la finalización del tutorial
  void _onTutorialCompleted() {
    _removeTutorialState();
    TutorialService().markTutorialCompleted(widget.tutorialKey);
    widget.onTutorialCompleted?.call();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ¡Tutorial completado!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Maneja la cancelación del tutorial
  void _onTutorialCancelled() {
    _removeTutorialState();
    widget.onTutorialCancelled?.call();
  }

  /// Remueve el estado del tutorial
  void _removeTutorialState() {
    _removeOverlay();
    if (mounted) {
      setState(() {
        _isTutorialActive = false;
      });
    }
  }

  /// Remueve el overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Verifica si el tutorial está activo
  bool get isTutorialActive => _isTutorialActive;

  /// Reinicia el tutorial (útil para testing)
  Future<void> resetTutorial() async {
    await TutorialService().resetAllTutorials();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutorial reiniciado'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension para facilitar el uso del TutorialManager en widgets
extension TutorialManagerExtension on State {
  /// Busca el TutorialManager más cercano en el árbol de widgets
  TutorialManager? findTutorialManager() {
    final state = context.findAncestorStateOfType<_TutorialManagerState>();
    return state?.widget;
  }

  /// Inicia el tutorial de la pantalla actual
  void startCurrentTutorial() {
    final manager = context.findAncestorStateOfType<_TutorialManagerState>();
    manager?.startTutorial();
  }

  /// Verifica si hay un tutorial activo
  bool isTutorialActive() {
    final manager = context.findAncestorStateOfType<_TutorialManagerState>();
    return manager?.isTutorialActive ?? false;
  }
}

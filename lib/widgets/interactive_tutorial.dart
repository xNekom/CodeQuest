import 'package:flutter/material.dart';

/// Representa un paso individual en un tutorial interactivo
class InteractiveTutorialStep {
  /// Título del paso del tutorial
  final String title;
  
  /// Descripción detallada del paso
  final String description;
  
  /// Icono para representar visualmente el paso
  final IconData icon;
  
  /// Clave global del widget objetivo (opcional)
  final GlobalKey? targetKey;
  
  /// Si debe mostrar un efecto de pulsación en el elemento objetivo
  final bool showPulse;
  
  /// Posición personalizada para el tooltip (opcional)
  final Offset? customPosition;
  
  /// Duración de la animación para este paso (en milisegundos)
  final int animationDuration;

  const InteractiveTutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
    this.showPulse = false,
    this.customPosition,
    this.animationDuration = 500,
  });
}

/// Widget principal del tutorial interactivo
class InteractiveTutorial extends StatefulWidget {
  /// Lista de pasos del tutorial
  final List<InteractiveTutorialStep> steps;
  
  /// Si el tutorial debe iniciar automáticamente
  final bool autoStart;
  
  /// Callback cuando se completa el tutorial
  final VoidCallback? onComplete;
  
  /// Callback cuando se cancela el tutorial
  final VoidCallback? onCancel;
  
  /// Widget hijo (normalmente vacío para overlays)
  final Widget child;
  
  /// Duración de las animaciones entre pasos
  final Duration stepTransitionDuration;

  const InteractiveTutorial({
    super.key,
    required this.steps,
    this.autoStart = false,
    this.onComplete,
    this.onCancel,
    required this.child,
    this.stepTransitionDuration = const Duration(milliseconds: 300),
  });

  @override
  State<InteractiveTutorial> createState() => _InteractiveTutorialState();
}

class _InteractiveTutorialState extends State<InteractiveTutorial>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isVisible = false;
  bool _isScrolling = false;
  Rect? _targetRect;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: widget.stepTransitionDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.autoStart && widget.steps.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTutorial();
      });
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _startTutorial() {
    if (widget.steps.isEmpty) return;
    
    setState(() {
      _currentStep = 0;
      _isVisible = true;
    });
    
    _ensureTargetVisible();
    _fadeController.forward();
  }
  
  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentStep++;
        });
        _ensureTargetVisible();
        _fadeController.forward();
      });
    } else {
      _completeTutorial();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentStep--;
        });
        _ensureTargetVisible();
        _fadeController.forward();
      });
    }
  }
  
  void _completeTutorial() {
    _fadeController.reverse().then((_) {
      setState(() {
        _isVisible = false;
        _targetRect = null;
      });
      widget.onComplete?.call();
    });
  }
  
  void _cancelTutorial() {
    _fadeController.reverse().then((_) {
      setState(() {
        _isVisible = false;
        _targetRect = null;
      });
      widget.onCancel?.call();
    });
  }
  
  void _ensureTargetVisible() {
    final currentStepData = widget.steps[_currentStep];
    final targetKey = currentStepData.targetKey;
    
    if (targetKey?.currentContext != null) {
      setState(() {
        _isScrolling = true;
        _targetRect = null; // Limpiar el rect antes del scroll
      });
      
      // Hacer scroll automático al elemento objetivo
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5, // Centrar el elemento en la pantalla
      ).then((_) {
        // Esperar un poco más después del scroll para asegurar que se complete
        Future.delayed(const Duration(milliseconds: 300), () {
          _updateTargetRect();
        });
      }).catchError((error) {
        // Si el scroll falla, actualizar el rect de todos modos
        print('DEBUG: Error en scroll automático: $error');
        Future.delayed(const Duration(milliseconds: 200), () {
          _updateTargetRect();
        });
      });
    } else {
      _updateTargetRect();
    }
  }
  
  void _updateTargetRect() {
    final currentStepData = widget.steps[_currentStep];
    final targetKey = currentStepData.targetKey;
    
    if (targetKey?.currentContext != null) {
      final RenderBox renderBox = targetKey!.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      
      setState(() {
        _targetRect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
        _isScrolling = false;
      });
    } else {
      setState(() {
        _targetRect = null;
        _isScrolling = false;
      });
    }
  }
  
  Widget _buildTooltipWithFade() {
    final currentStepData = widget.steps[_currentStep];
    final screenSize = MediaQuery.of(context).size;
    
    // Calcular la posición del tooltip basada en la posición del elemento resaltado
    double? top, bottom, left, right;
    
    print('DEBUG: _targetRect = $_targetRect');
    print('DEBUG: screenSize = $screenSize');
    print('DEBUG: targetKey context = ${currentStepData.targetKey?.currentContext}');
    
    if (_targetRect != null && currentStepData.targetKey?.currentContext != null) {
      print('DEBUG: Entrando en lógica de posicionamiento inteligente');
      // Verificar dimensiones de la pantalla y el tooltip
      final screenHeight = screenSize.height;
      final screenWidth = screenSize.width;
      final tooltipHeight = 250.0;
      final tooltipWidth = 300.0;
      final padding = 20.0;
      
      // Función para verificar si una posición causa solapamiento
      bool wouldOverlap(double testLeft, double testTop) {
        final testRect = Rect.fromLTWH(testLeft, testTop, tooltipWidth, tooltipHeight);
        return testRect.overlaps(_targetRect!);
      }
      
      // Función para verificar si una posición está dentro de los límites de la pantalla
      bool isWithinBounds(double testLeft, double testTop) {
        return testLeft >= padding && 
               testTop >= padding && 
               testLeft + tooltipWidth <= screenWidth - padding && 
               testTop + tooltipHeight <= screenHeight - padding;
      }
      
      // Lista de posiciones candidatas en orden de preferencia
      List<Map<String, double?>> candidatePositions = [];
      
      // Posición 1: A la derecha del elemento
      double rightLeft = _targetRect!.right + padding;
      double rightTop = _targetRect!.center.dy - tooltipHeight / 2;
      print('DEBUG: Calculando posición derecha: left=$rightLeft, top=$rightTop');
      if (isWithinBounds(rightLeft, rightTop) && !wouldOverlap(rightLeft, rightTop)) {
        print('DEBUG: Posición derecha es válida');
        candidatePositions.add({'left': rightLeft, 'top': rightTop, 'right': null, 'bottom': null});
      }
      
      // Posición 2: A la izquierda del elemento
      double leftLeft = _targetRect!.left - tooltipWidth - padding;
      double leftTop = _targetRect!.center.dy - tooltipHeight / 2;
      print('DEBUG: Calculando posición izquierda: left=$leftLeft, top=$leftTop');
      if (isWithinBounds(leftLeft, leftTop) && !wouldOverlap(leftLeft, leftTop)) {
        print('DEBUG: Posición izquierda es válida');
        candidatePositions.add({'left': leftLeft, 'top': leftTop, 'right': null, 'bottom': null});
      }
      
      // Posición 3: Arriba del elemento
      double topLeft = _targetRect!.center.dx - tooltipWidth / 2;
      double topTop = _targetRect!.top - tooltipHeight - padding;
      print('DEBUG: Calculando posición arriba: left=$topLeft, top=$topTop');
      if (isWithinBounds(topLeft, topTop) && !wouldOverlap(topLeft, topTop)) {
        print('DEBUG: Posición arriba es válida');
        candidatePositions.add({'left': topLeft, 'top': topTop, 'right': null, 'bottom': null});
      }
      
      // Posición 4: Abajo del elemento
      double bottomLeft = _targetRect!.center.dx - tooltipWidth / 2;
      double bottomTop = _targetRect!.bottom + padding;
      print('DEBUG: Calculando posición abajo: left=$bottomLeft, top=$bottomTop');
      if (isWithinBounds(bottomLeft, bottomTop) && !wouldOverlap(bottomLeft, bottomTop)) {
        print('DEBUG: Posición abajo es válida');
        candidatePositions.add({'left': bottomLeft, 'top': bottomTop, 'right': null, 'bottom': null});
      }
      
      print('DEBUG: candidatePositions.length = ${candidatePositions.length}');
      
      if (candidatePositions.isNotEmpty) {
        final selectedPosition = candidatePositions.first;
        left = selectedPosition['left'];
        top = selectedPosition['top'];
        right = selectedPosition['right'];
        bottom = selectedPosition['bottom'];
        print('DEBUG: Posición seleccionada: left=$left, top=$top, right=$right, bottom=$bottom');
        
        // Usar posicionamiento específico
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Positioned(
            top: top,
            bottom: bottom,
            left: left,
            right: right,
            child: _buildTooltip(),
          ),
        );
      } else {
        // Si no hay posiciones válidas, centrar en la pantalla
        print('DEBUG: No hay posiciones válidas - centrando tooltip');
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Positioned.fill(
            child: Center(
              child: _buildTooltip(),
            ),
          ),
        );
      }
    } else {
      // Sin elemento objetivo - siempre centrar en la pantalla
      print('DEBUG: Sin elemento objetivo válido - centrando en pantalla');
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Positioned.fill(
          child: Center(
            child: _buildTooltip(),
          ),
        ),
      );
    }
  }

  Widget _buildTooltip() {
    final currentStepData = widget.steps[_currentStep];
    final screenSize = MediaQuery.of(context).size;
    
    return Material(
        elevation: 0,
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300,
            maxHeight: screenSize.height * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icono y título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          currentStepData.icon,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentStepData.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _cancelTutorial,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Descripción
                  Text(
                    currentStepData.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Indicador de progreso
                  Row(
                    children: [
                      Text(
                        'Paso ${_currentStep + 1} de ${widget.steps.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / widget.steps.length,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botones de navegación
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        if (_currentStep > 0)
                          ElevatedButton.icon(
                            onPressed: _previousStep,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Anterior'),
                          ),
                        
                        ElevatedButton.icon(
                          onPressed: _nextStep,
                          icon: Icon(_currentStep == widget.steps.length - 1
                              ? Icons.check
                              : Icons.arrow_forward),
                          label: Text(_currentStep == widget.steps.length - 1
                              ? 'Finalizar'
                              : 'Siguiente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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
      );
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay pasos o no es visible, solo mostrar el widget hijo
    if (widget.steps.isEmpty || !_isVisible) {
      return widget.child;
    }

    final currentStepData = widget.steps[_currentStep];
    final targetKey = currentStepData.targetKey;

    return Stack(
      children: [
        // Widget hijo original
        widget.child,
        
        // Overlay semi-transparente
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
            ),
          ),
        ),
        
        // Agujero para resaltar el elemento objetivo
        if (_targetRect != null)
          Positioned.fill(
            child: CustomPaint(
              painter: HolePainter(_targetRect!),
            ),
          ),

        // Tooltip con información del paso actual
        _buildTooltipWithFade(),
      ],
    );
  }
}

/// Painter personalizado para crear un agujero en el overlay
class HolePainter extends CustomPainter {
  final Rect holeRect;
  
  HolePainter(this.holeRect);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0)
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        holeRect.inflate(8),
        const Radius.circular(8),
      ))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);
    
    // Dibujar borde alrededor del agujero
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        holeRect.inflate(8),
        const Radius.circular(8),
      ),
      borderPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is HolePainter && oldDelegate.holeRect != holeRect;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' show min, max, sqrt;

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
  int _currentStepIndex = 0;
  bool _isVisible = false;
  Rect? _targetRect;
  // Eliminado: _fadeController y _fadeAnimation ya que no se necesitan para transiciones instantáneas

  @override
  void initState() {
    super.initState();
    debugPrint('InteractiveTutorial: initState llamado');
    debugPrint('InteractiveTutorial: autoStart = ${widget.autoStart}');
    debugPrint('InteractiveTutorial: steps count = ${widget.steps.length}');
    


    if (widget.autoStart && widget.steps.isNotEmpty) {
      Future.microtask(() {
        if (mounted) {
          _startTutorial();
        }
      });
    }
  }



  void _startTutorial() {
    debugPrint('InteractiveTutorial: _startTutorial llamado');
    if (widget.steps.isEmpty) {
      debugPrint('InteractiveTutorial: No hay pasos para mostrar');
      return;
    }
    
    debugPrint('InteractiveTutorial: Iniciando con step 0');
    setState(() {
      _isVisible = true;
      _currentStepIndex = 0;
      _ensureTargetVisible();
    });
  }

  void _nextStep() {
    if (_currentStepIndex < widget.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _ensureTargetVisible();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _ensureTargetVisible();
    }
  }

  void _completeTutorial() {
    debugPrint('InteractiveTutorial: Tutorial completado');
    setState(() {
      _isVisible = false;
      _targetRect = null;
    });
    widget.onComplete?.call();
  }

  void _cancelTutorial() {
    debugPrint('InteractiveTutorial: Tutorial cancelado');
    setState(() {
      _isVisible = false;
      _targetRect = null;
    });
    widget.onCancel?.call();
  }

  void _ensureTargetVisible() {
    final currentStepData = widget.steps[_currentStepIndex];
    final targetKey = currentStepData.targetKey;

    if (targetKey?.currentContext != null) {
      setState(() {
        _targetRect = null; // Limpiar el rect antes del scroll
      });

      // Hacer scroll automático al elemento objetivo - INSTANTÁNEO
      Scrollable.ensureVisible(
            targetKey!.currentContext!,
            duration: Duration.zero, // INSTANTÁNEO
            curve: Curves.linear,
            alignment: 0.5, // Centrar el elemento en la pantalla
          )
          .then((_) {
            // Actualizar inmediatamente sin espera adicional
            _updateTargetRect();
          })
          .catchError((error) {
            if (kDebugMode) {
              debugPrint('Error al hacer scroll al objetivo: $error');
            }
            // Si falla el scroll, actualizar el rect de todos modos
            _updateTargetRect();
          });
    } else {
      // Si no hay contexto válido, actualizar el rect directamente
      _updateTargetRect();
    }
  }

  void _updateTargetRect() {
    final currentStepData = widget.steps[_currentStepIndex];
    final targetKey = currentStepData.targetKey;

    if (targetKey?.currentContext != null) {
      try {
        // Usar un cast seguro: si el RenderObject no es un RenderBox
        // (p.ej. un RenderSliver) se evita el TypeError
        final renderObject = targetKey!.currentContext!.findRenderObject();
        if (renderObject is! RenderBox || !renderObject.attached) {
          debugPrint('Target no es un RenderBox válido o no está adjunto');
          setState(() { _targetRect = null; });
          return;
        }
        final RenderBox renderBox = renderObject;
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        // Usar el rectángulo exacto del elemento sin margen extra
        // El margen se manejará en el cálculo del tooltip
        final targetRect = Rect.fromLTWH(
          position.dx,
          position.dy,
          size.width,
          size.height,
        );

        setState(() {
          _targetRect = targetRect;
        });
        
        debugPrint('Target rect actualizado: $_targetRect');
      } catch (e) {
        debugPrint('Error calculando rectángulo objetivo: $e');
        setState(() {
          _targetRect = null;
        });
      }
    } else {
      // Si no hay targetKey, intentar usar customPosition
      if (currentStepData.customPosition != null) {
        final customPos = currentStepData.customPosition!;
        setState(() {
          _targetRect = Rect.fromLTWH(
            customPos.dx - 20.0,
            customPos.dy - 20.0, 
            40.0, 
            40.0
          );
        });
      } else {
        setState(() {
          _targetRect = null;
        });
      }
    }
  }

  Widget _buildTooltipWithFade() {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Calcular la mejor posición para el tooltip considerando SafeArea
    Offset tooltipPosition = _calculateTooltipPosition(screenSize);

    // Ajustar para SafeArea con límites más restrictivos para evitar desbordamiento
    final adjustedPosition = Offset(
      tooltipPosition.dx.clamp(
        padding.left + 20.0, 
        screenSize.width - padding.right - 20.0
      ),
      tooltipPosition.dy.clamp(
        padding.top + 20.0,
        screenSize.height - padding.bottom - 20.0
      ),
    );

    return Positioned(
      left: adjustedPosition.dx,
      top: adjustedPosition.dy,
      child: _buildTooltip(),
    );
  }

  Offset _calculateTooltipPosition(Size screenSize) {
    final currentStep = widget.steps[_currentStepIndex];
    final targetRect = _targetRect;
    
    // Calcular dimensiones basadas en el espacio disponible
    final bool isSmallScreen = screenSize.width < 600;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    
    final double maxAvailableWidth = screenSize.width - padding.horizontal - 40.0;
    final double maxAvailableHeight = screenSize.height - padding.vertical - 40.0;
    
    // Calcular dimensiones del tooltip
    final int textLength = currentStep.title.length + currentStep.description.length;
    final double baseWidth = isSmallScreen ? 280.0 : 360.0;
    final double tooltipWidth = (baseWidth + min(textLength * 2.0, 100.0)).clamp(
      isSmallScreen ? 240.0 : 300.0,
      maxAvailableWidth * 0.9
    );
    
    final double baseHeight = 120.0;
    final double lineHeight = 22.0;
    final int estimatedLines = (textLength / 40).ceil();
    final double tooltipHeight = (baseHeight + estimatedLines * lineHeight).clamp(
      100.0,
      maxAvailableHeight * 0.8
    );

    const double safeMargin = 20.0;
    const double highlightMargin = 8.0; // Margen reducido para el área iluminada
    const double separationMargin = 40.0; // Aumentar espacio entre tooltip y área iluminada
    
    // Si no hay target, centrar en la pantalla
    if (targetRect == null) {
      return Offset(
        padding.left + (maxAvailableWidth - tooltipWidth) / 2,
        padding.top + (maxAvailableHeight - tooltipHeight) / 2
      );
    }

    // Calcular el área iluminada completa (elemento + margen de resaltado)
    // Usar un margen más pequeño para evitar áreas iluminadas demasiado grandes
    final Rect highlightRect = targetRect.inflate(highlightMargin * 0.5);
    
    // Generar posiciones prioritarias alrededor del área iluminada
    final List<Offset> positions = [];
    
    // 1. Posición ABAJO del área iluminada (preferida)
    positions.add(Offset(
      highlightRect.center.dx - tooltipWidth / 2,
      highlightRect.bottom + separationMargin
    ));
    
    // 2. Posición ARRIBA del área iluminada
    positions.add(Offset(
      highlightRect.center.dx - tooltipWidth / 2,
      highlightRect.top - tooltipHeight - separationMargin
    ));
    
    // 3. Posición DERECHA del área iluminada
    positions.add(Offset(
      highlightRect.right + separationMargin,
      highlightRect.center.dy - tooltipHeight / 2
    ));
    
    // 4. Posición IZQUIERDA del área iluminada
    positions.add(Offset(
      highlightRect.left - tooltipWidth - separationMargin,
      highlightRect.center.dy - tooltipHeight / 2
    ));
    
    // Función para verificar límites y ajustar posiciones
    Offset adjustPosition(Offset pos) {
      double x = pos.dx.clamp(
        padding.left + safeMargin,
        screenSize.width - tooltipWidth - padding.right - safeMargin
      );
      
      double y = pos.dy.clamp(
        padding.top + safeMargin,
        screenSize.height - tooltipHeight - padding.bottom - safeMargin
      );
      
      return Offset(x, y);
    }
    
    // Función para verificar si la posición evita superponer el área iluminada
    bool avoidsHighlight(Offset pos) {
      final tooltipRect = Rect.fromLTWH(pos.dx, pos.dy, tooltipWidth, tooltipHeight);
      return !tooltipRect.overlaps(highlightRect);
    }
    
    // Función para calcular la distancia desde el tooltip al área iluminada
    double distanceToHighlight(Offset pos) {
      final tooltipRect = Rect.fromLTWH(pos.dx, pos.dy, tooltipWidth, tooltipHeight);
      
      // Calcular la distancia más corta entre los rectángulos
      final dx = max(0.0, max(highlightRect.left - tooltipRect.right, tooltipRect.left - highlightRect.right));
      final dy = max(0.0, max(highlightRect.top - tooltipRect.bottom, tooltipRect.top - highlightRect.bottom));
      
      return sqrt(dx * dx + dy * dy);
    }
    
    // Probar posiciones en orden de preferencia
    for (final position in positions) {
      final adjusted = adjustPosition(position);
      if (avoidsHighlight(adjusted)) {
        return adjusted;
      }
    }
    
    // Fallback: encontrar la mejor posición disponible
    // Crear posiciones alternativas más alejadas
    final List<Offset> fallbackPositions = [];
    
    // Posiciones más alejadas con mayor separación
    const double fallbackSeparation = 70.0;
    
    fallbackPositions.add(Offset(
      highlightRect.center.dx - tooltipWidth / 2,
      highlightRect.bottom + fallbackSeparation
    ));
    
    fallbackPositions.add(Offset(
      highlightRect.center.dx - tooltipWidth / 2,
      highlightRect.top - tooltipHeight - fallbackSeparation
    ));
    
    fallbackPositions.add(Offset(
      highlightRect.right + fallbackSeparation,
      highlightRect.center.dy - tooltipHeight / 2
    ));
    
    fallbackPositions.add(Offset(
      highlightRect.left - tooltipWidth - fallbackSeparation,
      highlightRect.center.dy - tooltipHeight / 2
    ));
    
    // Buscar la posición que maximice la distancia al área iluminada
    Offset bestPosition = adjustPosition(fallbackPositions.first);
    double maxDistance = distanceToHighlight(bestPosition);
    
    for (final position in fallbackPositions.skip(1)) {
      final adjusted = adjustPosition(position);
      final distance = distanceToHighlight(adjusted);
      if (distance > maxDistance) {
        maxDistance = distance;
        bestPosition = adjusted;
      }
    }
    
    // Si aún hay superposición, usar posición opuesta al centro de la pantalla
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final targetDirection = highlightRect.center - screenCenter;
    
    Offset finalFallback;
    const double finalSeparation = 90.0;
    
    if (targetDirection.dx.abs() > targetDirection.dy.abs()) {
      // Más horizontal - posicionar verticalmente
      if (highlightRect.center.dy < screenSize.height / 2) {
        // Parte superior - posicionar abajo
        finalFallback = Offset(
          highlightRect.center.dx - tooltipWidth / 2,
          highlightRect.bottom + finalSeparation
        );
      } else {
        // Parte inferior - posicionar arriba
        finalFallback = Offset(
          highlightRect.center.dx - tooltipWidth / 2,
          highlightRect.top - tooltipHeight - finalSeparation
        );
      }
    } else {
      // Más vertical - posicionar horizontalmente
      if (highlightRect.center.dx < screenSize.width / 2) {
        // Lado izquierdo - posicionar derecha
        finalFallback = Offset(
          highlightRect.right + finalSeparation,
          highlightRect.center.dy - tooltipHeight / 2
        );
      } else {
        // Lado derecho - posicionar izquierda
        finalFallback = Offset(
          highlightRect.left - tooltipWidth - finalSeparation,
          highlightRect.center.dy - tooltipHeight / 2
        );
      }
    }
    
    // Asegurar límites finales
    return adjustPosition(finalFallback);
  }

  // Funciones auxiliares eliminadas - el posicionamiento ahora es más inteligente

  Widget _buildTooltip() {
    final currentStep = widget.steps[_currentStepIndex];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final tooltipPosition = _calculateTooltipPosition(screenSize);
        
        // Calcular dimensiones dinámicamente
        final bool isSmallScreen = screenSize.width < 600;
        final EdgeInsets padding = MediaQuery.of(context).padding;
        
        final double maxAvailableWidth = screenSize.width - padding.horizontal - 40.0;
        final double maxAvailableHeight = screenSize.height - padding.vertical - 40.0;
        
        final int textLength = currentStep.title.length + currentStep.description.length;
        final double baseWidth = isSmallScreen ? 280.0 : 360.0;
        final double tooltipWidth = (baseWidth + min(textLength * 2.0, 100.0)).clamp(
          isSmallScreen ? 240.0 : 300.0,
          maxAvailableWidth * 0.9
        );
        
        final double baseHeight = 120.0;
        final double lineHeight = 22.0;
        final int estimatedLines = (textLength / 40).ceil();
        final double tooltipHeight = (baseHeight + estimatedLines * lineHeight).clamp(
          100.0,
          maxAvailableHeight * 0.8
        );

        return Positioned(
          left: tooltipPosition.dx,
          top: tooltipPosition.dy,
          child: Container(
            width: tooltipWidth,
            constraints: BoxConstraints(
              maxHeight: tooltipHeight,
              minHeight: 100.0,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        currentStep.title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16.0 : 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20.0),
                      onPressed: _cancelTutorial,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(24, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Description
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      currentStep.description,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _currentStepIndex > 0 ? _previousStep : null,
                      child: Text(
                        'Anterior',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          color: _currentStepIndex > 0 ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      '${_currentStepIndex + 1} / ${widget.steps.length}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: _currentStepIndex < widget.steps.length - 1 ? _nextStep : widget.onComplete,
                      child: Text(
                        _currentStepIndex < widget.steps.length - 1 ? 'Siguiente' : 'Finalizar',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('InteractiveTutorial: build llamado - isVisible: $_isVisible, steps: ${widget.steps.length}');
    
    if (!_isVisible || widget.steps.isEmpty) {
      debugPrint('InteractiveTutorial: Retornando solo child - invisible o sin pasos');
      return widget.child;
    }

    debugPrint('InteractiveTutorial: Mostrando overlay completo');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _cancelTutorial();
        }
      },
      child: Stack(
        children: [
          // Widget hijo original
          widget.child,
          
          // Overlay oscuro con agujero para el elemento objetivo - CORREGIDO
          if (_isVisible)
            Positioned.fill(
              child: CustomPaint(
                painter: HolePainter(
                  targetRect: _targetRect,
                  backgroundColor: Colors.black.withValues(alpha: 0.75), // Fondo oscuro transparente restaurado
                  holeRadius: 16.0, // Bordes suaves
                  glowColor: Colors.blue.withValues(alpha: 0.8), // Brillo azul sutil
                  glowRadius: 30.0, // Brillo moderado
                  borderWidth: 2.0, // Borde delgado
                ),
              ),
            ),
          
          // Tooltip - POSICIONADO PARA EVITAR SUPERPOSICIÓN
          if (_isVisible) _buildTooltipWithFade(),
        ],
      ),
    );
  }
}

/// Pintor personalizado para crear un overlay con un agujero
class HolePainter extends CustomPainter {
  final Rect? targetRect;
  final Color backgroundColor;
  final double holeRadius;
  final Color glowColor;
  final double glowRadius;
  final double borderWidth;

  HolePainter({
    required this.targetRect,
    required this.backgroundColor,
    this.holeRadius = 16.0, // Radio aumentado para bordes más suaves
    this.glowColor = Colors.blue,
    this.glowRadius = 40.0, // Brillo más amplio y suave
    this.borderWidth = 4.0, // Borde más prominente
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo oscuro transparente - RESTAURADO
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    if (targetRect != null) {
      // Área de iluminación con márgenes ajustados
      final illuminationRect = Rect.fromLTRB(
        targetRect!.left - 8.0,
        targetRect!.top - 8.0,
        targetRect!.right + 8.0,
        targetRect!.bottom + 8.0,
      );

      // Crear el path para el área iluminada
      final Path highlightPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          illuminationRect,
          Radius.circular(holeRadius),
        ));

      // Crear el path para toda la pantalla excepto el área iluminada
      final Path inversePath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addPath(highlightPath, Offset.zero)
        ..fillType = PathFillType.evenOdd;

      // Dibujar el fondo oscuro con el "agujero" transparente
      final Paint darkPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(inversePath, darkPaint);

      // Efectos visuales sutiles alrededor del área iluminada
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          illuminationRect.inflate(4.0),
          Radius.circular(holeRadius + 2.0),
        ),
        glowPaint,
      );

      // Borde definido
      final borderPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          illuminationRect,
          Radius.circular(holeRadius),
        ),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(HolePainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.holeRadius != holeRadius ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.glowRadius != glowRadius ||
        oldDelegate.borderWidth != borderWidth;
  }
}

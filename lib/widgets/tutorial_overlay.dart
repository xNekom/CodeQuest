import 'package:flutter/material.dart';
import 'pixel_widgets.dart';

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final bool showSkipButton;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    this.showSkipButton = true,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startStepAnimation();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startStepAnimation() {
    _fadeController.reset();
    _slideController.reset();

    _fadeController.forward();
    _slideController.forward();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _startStepAnimation();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _startStepAnimation();
    }
  }

  void _completeTutorial() {
    if (mounted) {
      _fadeController.reverse().then((_) {
        if (mounted) {
          widget.onComplete();
        }
      });
    }
  }

  void _skipTutorial() {
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[_currentStep];
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Stack(
            children: [
              // Fondo oscuro con área iluminada
              if (currentStep.targetRect != null)
                _buildSpotlight(currentStep.targetRect!),

              // Tutorial content - posicionamiento inteligente
              _buildResponsiveTutorialContent(
                currentStep,
                screenSize,
                isSmallScreen,
              ),

              // Skip button - posicionamiento seguro
              if (widget.showSkipButton)
                _buildResponsiveSkipButton(screenSize, isSmallScreen),

              // Pulse indicator on target
              if (currentStep.targetRect != null && currentStep.showPulse)
                _buildPulseIndicator(currentStep.targetRect!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveTutorialContent(
    TutorialStep step,
    Size screenSize,
    bool isSmallScreen,
  ) {
    // Calcular límites seguros con márgenes responsivos
    final safePadding = isSmallScreen ? 16.0 : 32.0;
    final maxCardWidth = screenSize.width - (safePadding * 2);
    final maxCardHeight =
        screenSize.height - (safePadding * 2) - (isSmallScreen ? 80 : 100);

    // Posicionamiento inteligente basado en el target
    Offset? cardPosition;
    if (step.targetRect != null) {
      cardPosition = _calculateOptimalPosition(
        step.targetRect!,
        screenSize,
        maxCardWidth,
        maxCardHeight,
      );
    }

    return Positioned(
      left: cardPosition?.dx ?? safePadding,
      top: cardPosition?.dy ?? safePadding,
      right: cardPosition != null ? null : safePadding,
      bottom: cardPosition != null ? null : safePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxCardWidth,
            maxHeight: maxCardHeight,
            minWidth: isSmallScreen ? screenSize.width * 0.85 : 300,
          ),
          child: _buildTutorialCard(step, isSmallScreen),
        ),
      ),
    );
  }

  Offset _calculateOptimalPosition(
    Rect targetRect,
    Size screenSize,
    double cardWidth,
    double cardHeight,
  ) {
    const double margin = 24.0; // Aumentado para mejor separación
    const double highlightMargin =
        32.0; // Margen adicional alrededor del área iluminada
    double left, top;

    // Calcular el área iluminada con margen extra
    final highlightArea = targetRect.inflate(highlightMargin);

    // Espacio disponible considerando el área iluminada
    final spaceAbove = highlightArea.top - margin;
    final spaceBelow = screenSize.height - highlightArea.bottom - margin;
    final spaceRight = screenSize.width - highlightArea.right - margin;
    final spaceLeft = highlightArea.left - margin;
    const double minSpace = 20.0; // Espacio mínimo requerido

    // Lista de opciones ordenadas por preferencia
    final options = [];

    // Opción 1: Debajo del target (preferida)
    if (spaceBelow >= cardHeight + minSpace) {
      options.add({
        'left': highlightArea.center.dx - cardWidth / 2,
        'top': highlightArea.bottom + margin,
        'priority': spaceBelow,
        'type': 'below',
      });
    }

    // Opción 2: Encima del target
    if (spaceAbove >= cardHeight + minSpace) {
      options.add({
        'left': highlightArea.center.dx - cardWidth / 2,
        'top': highlightArea.top - cardHeight - margin,
        'priority': spaceAbove,
        'type': 'above',
      });
    }

    // Opción 3: A la derecha del target
    if (spaceRight >= cardWidth + minSpace) {
      options.add({
        'left': highlightArea.right + margin,
        'top': highlightArea.center.dy - cardHeight / 2,
        'priority': spaceRight,
        'type': 'right',
      });
    }

    // Opción 4: A la izquierda del target
    if (spaceLeft >= cardWidth + minSpace) {
      options.add({
        'left': highlightArea.left - cardWidth - margin,
        'top': highlightArea.center.dy - cardHeight / 2,
        'priority': spaceLeft,
        'type': 'left',
      });
    }

    // Si hay opciones válidas, elegir la mejor
    if (options.isNotEmpty) {
      options.sort(
        (a, b) => (b['priority'] as double).compareTo(a['priority'] as double),
      );
      final bestOption = options.first;
      left = bestOption['left'] as double;
      top = bestOption['top'] as double;
    } else {
      // Fallback: posicionar estratégicamente según la ubicación del target
      if (targetRect.center.dy < screenSize.height / 2) {
        // Target en la parte superior - poner debajo
        left = targetRect.center.dx - cardWidth / 2;
        top = targetRect.bottom + margin;
      } else {
        // Target en la parte inferior - poner encima
        left = targetRect.center.dx - cardWidth / 2;
        top = targetRect.top - cardHeight - margin;
      }
    }

    // Asegurar que esté dentro de los límites de la pantalla con padding
    const double screenMargin = 16.0;
    left = left.clamp(
      screenMargin,
      screenSize.width - cardWidth - screenMargin,
    );
    top = top.clamp(
      screenMargin,
      screenSize.height - cardHeight - screenMargin,
    );

    return Offset(left, top);
  }

  Widget _buildResponsiveSkipButton(Size screenSize, bool isSmallScreen) {
    final safePadding = isSmallScreen ? 8.0 : 20.0;

    return Positioned(
      top: safePadding + MediaQuery.of(context).padding.top,
      right: safePadding,
      child: SafeArea(
        child: PixelButton(
          onPressed: _skipTutorial,
          isSecondary: true,
          width: isSmallScreen ? 36 : 48,
          height: isSmallScreen ? 28 : 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, size: isSmallScreen ? 14 : 16),
              if (!isSmallScreen) ...[
                const SizedBox(width: 4),
                const Text('Saltar', style: TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpotlight(Rect targetRect) {
    // Aumentar el área iluminada para mejor visibilidad
    final enlargedRect = targetRect.inflate(4.0);

    return Positioned.fill(
      child: CustomPaint(painter: SpotlightPainter(enlargedRect)),
    );
  }

  Widget _buildTutorialCard(TutorialStep step, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Tamaños responsivos
    final horizontalPadding = isSmallScreen ? 12.0 : 20.0;
    final verticalPadding = isSmallScreen ? 12.0 : 20.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final descriptionFontSize = isSmallScreen ? 12.0 : 14.0;
    final buttonSpacing = isSmallScreen ? 4.0 : 8.0;
    final buttonFontSize = isSmallScreen ? 11.0 : 13.0;

    return PixelCard(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth * (isSmallScreen ? 0.9 : 0.8),
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title - responsivo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step.icon != null) ...[
                  Icon(
                    step.icon,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: spacing),
                ],
                Expanded(
                  child: Text(
                    step.title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),

            // Description con scroll si es necesario
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: SingleChildScrollView(
                child: Text(
                  step.description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(204),
                  ),
                  softWrap: true,
                ),
              ),
            ),

            // Additional content con scroll
            if (step.content != null) ...[
              SizedBox(height: spacing),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.25,
                ),
                child: SingleChildScrollView(child: step.content!),
              ),
            ],

            SizedBox(height: spacing * 2),

            // Navigation buttons responsivos
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = constraints.maxWidth;
                final canFitSideBySide = buttonWidth > 280;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canFitSideBySide)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _buildNavigationButtons(
                          buttonFontSize,
                          buttonSpacing,
                          isSmallScreen,
                        ),
                      )
                    else
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentStep > 0) ...[
                            SizedBox(
                              width: double.infinity,
                              child: _buildPreviousButton(
                                buttonFontSize,
                                buttonSpacing,
                                isSmallScreen,
                              ),
                            ),
                            SizedBox(height: spacing),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_currentStep + 1} / ${widget.steps.length}',
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(153),
                                ),
                              ),
                              _buildNextButton(
                                buttonFontSize,
                                buttonSpacing,
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavigationButtons(
    double fontSize,
    double spacing,
    bool isSmallScreen,
  ) {
    return [
      // Previous button
      _currentStep > 0
          ? _buildPreviousButton(fontSize, spacing, isSmallScreen)
          : const SizedBox.shrink(),

      // Step indicator
      Text(
        '${_currentStep + 1} / ${widget.steps.length}',
        style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
        ),
      ),

      // Next/Finish button
      _buildNextButton(fontSize, spacing, isSmallScreen),
    ];
  }

  Widget _buildPreviousButton(
    double fontSize,
    double spacing,
    bool isSmallScreen,
  ) {
    return PixelButton(
      onPressed: _previousStep,
      isSecondary: true,
      width: isSmallScreen ? 60 : 80,
      height: isSmallScreen ? 28 : 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back, size: fontSize + 2),
          SizedBox(width: spacing / 2),
          Text('Ant', style: TextStyle(fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _buildNextButton(double fontSize, double spacing, bool isSmallScreen) {
    return PixelButton(
      onPressed: _nextStep,
      width: isSmallScreen ? 60 : 80,
      height: isSmallScreen ? 28 : 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentStep == widget.steps.length - 1 ? 'Fin' : 'Sig',
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(width: spacing / 2),
          Icon(
            _currentStep == widget.steps.length - 1
                ? Icons.check
                : Icons.arrow_forward,
            size: fontSize + 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator(Rect targetRect) {
    return Positioned(
      left: targetRect.center.dx - 35,
      top: targetRect.center.dy - 35,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Círculo exterior con brillo
              Transform.scale(
                scale: _pulseAnimation.value * 1.3,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueAccent.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    color: Colors.blueAccent.withValues(alpha: 0.2),
                  ),
                ),
              ),
              // Círculo interior principal
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 3,
                    ),
                    color: Colors.blueAccent.withValues(alpha: 0.4),
                  ),
                ),
              ),
              // Centro brillante
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SpotlightPainter extends CustomPainter {
  final Rect targetRect;

  SpotlightPainter(this.targetRect);

  @override
  void paint(Canvas canvas, Size size) {
    // Crear un rectángulo más grande para el área iluminada
    final illuminationRect = targetRect.inflate(24);

    // Crear el área con esquinas redondeadas
    final RRect highlightRRect = RRect.fromRectAndRadius(
      illuminationRect,
      const Radius.circular(16),
    );

    // Crear el path para el área iluminada
    final Path highlightPath = Path()..addRRect(highlightRRect);

    // Crear el path para toda la pantalla excepto el área iluminada
    final Path inversePath =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addPath(highlightPath, Offset.zero)
          ..fillType = PathFillType.evenOdd;

    // Dibujar el fondo oscuro con el "agujero" transparente
    final Paint backgroundPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;

    canvas.drawPath(inversePath, backgroundPaint);

    // Dibujar los efectos visuales alrededor del área iluminada

    // 1. Brillo exterior azul intenso
    final Paint glowPaint =
        Paint()
          ..color = Colors.blueAccent.withValues(alpha: 0.9)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

    // 2. Borde brillante tipo neón
    final Paint borderPaint =
        Paint()
          ..color = Colors.blueAccent.withValues(alpha: 1.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    // 3. Borde blanco brillante interior
    final Paint innerBorderPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 1.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // Áreas para los bordes
    final RRect glowRRect = RRect.fromRectAndRadius(
      illuminationRect.inflate(8),
      const Radius.circular(20),
    );

    final RRect borderRRect = RRect.fromRectAndRadius(
      illuminationRect.inflate(4),
      const Radius.circular(18),
    );

    // Dibujar los efectos de iluminación
    canvas.drawRRect(glowRRect, glowPaint);
    canvas.drawRRect(borderRRect, borderPaint);
    canvas.drawRRect(highlightRRect, innerBorderPaint);

    // Efecto de esquinas brillantes
    final cornerPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 1.0)
          ..style = PaintingStyle.fill;

    // Dibujar puntos brillantes en las esquinas
    final cornerRadius = 16.0;
    final cornerPositions = [
      Offset(
        illuminationRect.left + cornerRadius,
        illuminationRect.top + cornerRadius,
      ),
      Offset(
        illuminationRect.right - cornerRadius,
        illuminationRect.top + cornerRadius,
      ),
      Offset(
        illuminationRect.right - cornerRadius,
        illuminationRect.bottom - cornerRadius,
      ),
      Offset(
        illuminationRect.left + cornerRadius,
        illuminationRect.bottom - cornerRadius,
      ),
    ];

    for (final corner in cornerPositions) {
      canvas.drawCircle(corner, 3.0, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect;
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData? icon;
  final Rect? targetRect;
  final Offset? position;
  final Widget? content;
  final bool showPulse;

  TutorialStep({
    required this.title,
    required this.description,
    this.icon,
    this.targetRect,
    this.position,
    this.content,
    this.showPulse = true,
  });
}

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

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: Colors.black.withAlpha(179), // Reemplazado .withOpacity(0.7)
            child: Stack(
              children: [
                // Spotlight effect
                if (currentStep.targetRect != null)
                  _buildSpotlight(currentStep.targetRect!), // Tutorial content
                Positioned.fill(
                  child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 100,
                          maxHeight: MediaQuery.of(context).size.height - 100,
                        ),
                        child: _buildTutorialCard(currentStep),
                      ),
                    ),
                  ),
                ),

                // Skip button
                if (widget.showSkipButton)
                  Positioned(top: 50, right: 20, child: _buildSkipButton()),

                // Pulse indicator on target
                if (currentStep.targetRect != null && currentStep.showPulse)
                  _buildPulseIndicator(currentStep.targetRect!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpotlight(Rect targetRect) {
    return CustomPaint(
      painter: SpotlightPainter(targetRect),
      size: Size.infinite,
    );
  }

  Widget _buildTutorialCard(TutorialStep step) {
    return PixelCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                if (step.icon != null) ...[
                  Icon(
                    step.icon,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              step.description,
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),

            // Additional content
            if (step.content != null) ...[
              const SizedBox(height: 16),
              step.content!,
            ],

            const SizedBox(height: 20),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                _currentStep > 0
                    ? PixelButton(
                      onPressed: _previousStep,
                      isSecondary: true,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 16),
                          SizedBox(width: 8),
                          Text('Anterior'),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),

                // Step indicator
                Text(
                  '${_currentStep + 1} / ${widget.steps.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // Next/Finish button
                PixelButton(
                  onPressed: _nextStep,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentStep == widget.steps.length - 1
                            ? 'Finalizar'
                            : 'Siguiente',
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == widget.steps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return PixelButton(
      onPressed: _skipTutorial,
      isSecondary: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.close, size: 16),
          const SizedBox(width: 8),
          const Text('Saltar'),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator(Rect targetRect) {
    return Positioned(
      left: targetRect.center.dx - 30,
      top: targetRect.center.dy - 30,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                color: Theme.of(context).colorScheme.primary.withAlpha(
                  51,
                ), // Reemplazado .withOpacity(0.2)
              ),
            ),
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
    final Paint backgroundPaint =
        Paint()
          ..color = Colors.black.withAlpha(
            204,
          ); // Reemplazado .withOpacity(0.8)

    final Paint spotlightPaint = Paint()..blendMode = BlendMode.clear;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Create rounded spotlight
    final RRect spotlightRRect = RRect.fromRectAndRadius(
      targetRect.inflate(10),
      const Radius.circular(12),
    );

    canvas.drawRRect(spotlightRRect, spotlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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

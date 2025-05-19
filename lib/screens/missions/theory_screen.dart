import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../widgets/pixel_widgets.dart';
import './question_screen.dart';

class TheoryScreen extends StatefulWidget {
  final String missionId;
  final String theoryText;
  final List<String> examples;

  const TheoryScreen({
    super.key,
    required this.missionId,
    required this.theoryText,
    required this.examples,
  });

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Teoría de la Misión'),
        actions: [
          IconButton(
            icon: PixelIcon(Pixel.list),
            onPressed: () {},
            tooltip: 'Teoría',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnim,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PixelIcon(Pixel.list, size: 32),
                  const SizedBox(width: 8),
                  Text('Teoría', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              PixelCard(
                child: Text(widget.theoryText, style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  PixelIcon(Pixel.code, size: 32),
                  const SizedBox(width: 8),
                  Text('Ejemplos', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              ...widget.examples.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: PixelCard(
                  child: Text(ex, style: const TextStyle(fontFamily: 'monospace')),
                ),
              )),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    PixelButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestionScreen(missionId: widget.missionId),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PixelIcon(Pixel.code),
                          const SizedBox(width: 8),
                          const Text('Comenzar ejercicios'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PixelButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      isSecondary: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PixelIcon(Pixel.chevronleft),
                          const SizedBox(width: 8),
                          const Text('Volver'),
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
    );
  }
}

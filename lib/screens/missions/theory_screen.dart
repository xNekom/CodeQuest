import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../widgets/pixel_widgets.dart';
import './question_screen.dart';
import '../game/battle_screen.dart';
import '../../models/mission_model.dart';
import '../../services/mission_service.dart';

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
  final MissionService _missionService = MissionService();
  MissionModel? _mission;
  bool _isLoadingMission = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _loadMissionData();
  }

  Future<void> _loadMissionData() async {
    setState(() {
      _isLoadingMission = true;
    });
    
    try {
      _mission = await _missionService.getMissionById(widget.missionId);
    } catch (e) {
      print('Error loading mission: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMission = false;
        });
      }
    }
  }

  void _navigateToNextScreen() {
    if (_mission == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo cargar la información de la misión')),
      );
      return;
    }

    // Buscar el primer objetivo para determinar el tipo
    if (_mission!.objectives.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: La misión no tiene objetivos definidos')),
      );
      return;
    }

    final firstObjective = _mission!.objectives.first;

    if (firstObjective.type == 'batalla') {
      // Verificar que tenga battleConfig
      if (firstObjective.battleConfig != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BattleScreen(battleConfig: firstObjective.battleConfig!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Esta misión de batalla no tiene configuración válida')),
        );
      }
    } else if (firstObjective.type == 'questions') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionScreen(missionId: widget.missionId),
        ),
      );
    } else {
      // Para otros tipos de misiones, por defecto intentar QuestionScreen
      // pero mostrar un warning
      print('Warning: Tipo de objetivo no reconocido: ${firstObjective.type}. Navegando a QuestionScreen por defecto.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionScreen(missionId: widget.missionId),
        ),
      );
    }
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
                  children: [                    PixelButton(
                      onPressed: _isLoadingMission ? null : _navigateToNextScreen,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PixelIcon(Pixel.code),
                          const SizedBox(width: 8),
                          Text(_isLoadingMission ? 'Cargando...' : 'Comenzar ejercicios'),
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

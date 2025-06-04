import 'package:flutter/material.dart';
import 'mission_list_screen.dart';
import '../../services/tutorial_service.dart';
import '../../widgets/tutorial_floating_button.dart';
import '../../widgets/pixel_app_bar.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _missionListKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _backButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkAndStartTutorial();
  }

  /// Inicia el tutorial si es necesario
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      TutorialService.startTutorialIfNeeded(
        context,
        TutorialService.missionsScreenTutorial,
        TutorialService.getMissionsScreenTutorial(
          missionListKey: _missionListKey,
          filterButtonKey: _filterButtonKey,
          backButtonKey: _backButtonKey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PixelAppBar(
        key: _backButtonKey,
        title: 'MISIÓN',
        // Leading por defecto para volver atrás
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: MissionListScreen(
            missionListKey: _missionListKey,
            filterButtonKey: _filterButtonKey,
          ),
        ),
      ),
      floatingActionButton: TutorialFloatingButton(
        tutorialKey: TutorialService.missionsScreenTutorial,
        tutorialSteps: TutorialService.getMissionsScreenTutorial(
          missionListKey: _missionListKey,
          filterButtonKey: _filterButtonKey,
          backButtonKey: _backButtonKey,
        ),
      ),
    );
  }
}

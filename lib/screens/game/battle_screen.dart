import 'package:flutter/material.dart';
import '../../models/battle_config_model.dart';
import '../../models/enemy_model.dart'; // Will be needed to fetch/display enemy
import '../../models/question_model.dart'; // Will be needed for questions
// Assuming PixelButton is in pixel_widgets.dart
import '../../widgets/pixel_widgets.dart'; 
// Placeholder for EnemyService if you create one
// import '../../services/enemy_service.dart'; 

class BattleScreen extends StatefulWidget {
  final BattleConfigModel battleConfig;
  final String missionId; 

  const BattleScreen({
    super.key,
    required this.battleConfig,
    required this.missionId,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  // EnemyModel? _enemy; // To hold fetched enemy data
  // QuestionModel? _currentQuestion; // To hold current question
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  // bool _isLoadingEnemy = true;

  @override
  void initState() {
    super.initState();
    // _loadEnemyData();
    // _loadQuestion();
    print("BattleScreen initialized for mission: ${widget.missionId}, enemy: ${widget.battleConfig.enemyId}");
    print("Battle questions: ${widget.battleConfig.questionIds}");
  }

  /*
  Future<void> _loadEnemyData() async {
    // TODO: Fetch enemy data using widget.battleConfig.enemyId
    // Example:
    // final enemyService = EnemyService();
    // final enemy = await enemyService.getEnemyById(widget.battleConfig.enemyId);
    // if (mounted) {
    //   setState(() {
    //     _enemy = enemy;
    //     _isLoadingEnemy = false;
    //   });
    // }
    setState(() { _isLoadingEnemy = false; }); // Placeholder
  }

  void _loadQuestion() {
    // TODO: Fetch question using widget.battleConfig.questionIds[_currentQuestionIndex]
    // Example:
    // final questionService = QuestionService(); // Assuming you have one
    // _currentQuestion = await questionService.getQuestionById(widget.battleConfig.questionIds[_currentQuestionIndex]);
    // setState(() {});
    print("Loading question index: $_currentQuestionIndex");
  }
  */

  void _submitAnswer(int selectedOptionIndex) {
    // TODO: Implement answer checking logic
    // bool isCorrect = _currentQuestion.correctAnswerIndex == selectedOptionIndex;
    bool isCorrect = true; // Placeholder

    if (isCorrect) {
      _correctAnswers++;
      if (_correctAnswers >= 3) {
        // Battle Won
        print('Battle Won! Mission: ${widget.missionId}');
        // TODO: Award achievement, navigate to victory screen or back to mission detail
        if (Navigator.canPop(context)) Navigator.pop(context);
      } else {
        _currentQuestionIndex++;
        // _loadQuestion();
        print('Correct answer! Moving to next question. Correct answers: $_correctAnswers');
        setState(() {}); // To rebuild and show next question or updated state
      }
    } else {
      // Incorrect answer
      print('Incorrect answer!');
      // TODO: Handle incorrect answer (e.g., penalty, lose condition)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    /*
    if (_isLoadingEnemy) {
      return Scaffold(
        appBar: AppBar(title: const Text('Batalla')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    */

    return Scaffold(
      appBar: AppBar(
        title: Text('Batalla: Misión ${widget.missionId}'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Enemy Display Area (Placeholder) ---
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (_enemy != null && _enemy!.assetPath.isNotEmpty)
                    //   Image.asset(_enemy!.assetPath, height: 100, errorBuilder: (c,e,s) => Icon(Icons.error))
                    // else
                    Icon(Icons.shield, size: 100, color: theme.primaryColor), // Placeholder icon
                    const SizedBox(height: 8),
                    // Text(_enemy?.name ?? 'Cargando Enemigo...', style: theme.textTheme.headlineSmall),
                    Text('Enemigo Placeholder (ID: ${widget.battleConfig.enemyId})', style: theme.textTheme.headlineSmall),
                    if (widget.battleConfig.environment != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Entorno: ${widget.battleConfig.environment}', style: theme.textTheme.bodySmall),
                        )
                  ],
                ),
              ),
            ),
            
            // --- Battle Progress/Indicators (Placeholder) ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < _correctAnswers ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: index < _correctAnswers ? Colors.green : Colors.grey,
                    size: 30,
                  );
                }),
              ),
            ),

            // --- Question Display Area (Placeholder) ---
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text(
                    // _currentQuestion?.text ?? 'Cargando pregunta...',
                    'Pregunta ${_currentQuestionIndex + 1} de ${widget.battleConfig.questionIds.length} (Placeholder)',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Placeholder for answer options
                  // ..._currentQuestion.options.map((option, index) => PixelButton(...)).toList()
                  PixelButton(onPressed: () => _submitAnswer(0), child: const Text('Opción A (Placeholder)')),
                  const SizedBox(height: 8),
                  PixelButton(onPressed: () => _submitAnswer(1), child: const Text('Opción B (Placeholder)')),
                  const SizedBox(height: 8),
                  PixelButton(onPressed: () => _submitAnswer(2), child: const Text('Opción C (Placeholder)')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/enemy_model.dart';
import '../../models/question_model.dart';
import '../../models/battle_config_model.dart';
import '../../widgets/pixel_widgets.dart';

class BattleScreen extends StatefulWidget {
  final BattleConfigModel battleConfig;

  const BattleScreen({super.key, required this.battleConfig});

  @override
  // ignore: library_private_types_in_public_api
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  EnemyModel? _currentEnemy;
  QuestionModel? _currentQuestion;
  int _currentQuestionIndex = 0;
  List<String> _questionIds = [];

  @override
  void initState() {
    super.initState();
    _questionIds = widget.battleConfig.questionIds;
    _loadData();
  }

  void _loadData() async {
    // TODO: Fetch enemy data using widget.battleConfig.enemyId
    // _currentEnemy = await EnemyService().getEnemyById(widget.battleConfig.enemyId);

    if (_questionIds.isNotEmpty && _currentQuestionIndex < _questionIds.length) {
      // TODO: Fetch question using _questionIds[_currentQuestionIndex]
      // _currentQuestion = await QuestionService().getQuestionById(_questionIds[_currentQuestionIndex]);
      if (mounted) {
        setState(() {
          _currentQuestion = QuestionModel(
            questionId: _questionIds[_currentQuestionIndex],
            text: "Pregunta de prueba: ${_questionIds[_currentQuestionIndex]}",
            options: ["Opción 1", "Opción 2", "Opción 3", "Opción 4"],
            correctAnswerIndex: 0,
            explanation: "Explicación de la pregunta de prueba."
          );
        });
      }
    }
  }

  void _submitAnswer(int selectedOptionIndex) {
    if (_currentQuestion == null) return;

    bool isCorrect = selectedOptionIndex == _currentQuestion!.correctAnswerIndex;

    if (isCorrect) {
      if (_currentQuestionIndex < _questionIds.length - 1) {
        _currentQuestionIndex++;
        _loadData();
      } else {
        // Batalla ganada
        // TODO: Award achievement, navigate to victory screen or back to mission detail
      }
    } else {
      // Respuesta incorrecta
      // TODO: Handle incorrect answer (e.g., penalty, lose condition)
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('Batalla'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );

    if (_currentQuestion == null) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentEnemy != null) Text("Enemigo: ${_currentEnemy!.name}"),
            Text(_currentQuestion!.text, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            ..._currentQuestion!.options.asMap().entries.map((entry) {
              int idx = entry.key;
              String optionText = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: PixelButton(
                  onPressed: () => _submitAnswer(idx),
                  child: Text(optionText),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

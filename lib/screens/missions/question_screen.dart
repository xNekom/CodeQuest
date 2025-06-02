import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // No se usa directamente aquí
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/mission_service.dart';
import '../../services/question_service.dart'; // Importar QuestionService
import '../../models/mission_model.dart'; // Incluye Objective
import '../../models/question_model.dart'; // Importar QuestionModel
import '../../widgets/pixel_widgets.dart'; // Asegúrate de que esta importación esté presente y sea correcta
import 'package:codequest/widgets/formatted_text_widget.dart';
import '../mission_completed_screen.dart'; // Importar MissionCompletedScreen

/// Pantalla de preguntas de una misión
class QuestionScreen extends StatefulWidget {
  final String missionId;
  final bool isReplay;

  const QuestionScreen({
    super.key,
    required this.missionId,
    this.isReplay = false,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final MissionService _missionService = MissionService();
  final QuestionService _questionService = QuestionService();

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String _missionName = "";
  String _errorMessage = "";
  final int _experiencePoints = 25;

  int? _selectedOptionIndex; // Para rastrear la opción seleccionada
  bool _answerSubmitted =
      false; // Para saber si el usuario ya respondió la pregunta actual
  bool?
  _isCurrentAnswerCorrect; // Para saber si la respuesta seleccionada fue correcta
  int _totalCorrectAnswers = 0; // Contador para respuestas correctas
  int _totalIncorrectAnswers = 0; // Contador para respuestas incorrectas

  @override
  void initState() {
    super.initState();
    _loadMissionStructure();
  }

  Future<void> _loadMissionStructure() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _questions = [];
    });
    try {
      print('[QS] Loading mission structure for ID: ${widget.missionId}');
      final MissionModel? mission = await _missionService.getMissionById(
        widget.missionId,
      );

      if (mission != null) {
        _missionName = mission.name;
        print(
          '[QS] Mission loaded: ${mission.name}. Objectives count: ${mission.objectives.length}',
        );
        mission.objectives.asMap().forEach((idx, obj) {
          print(
            '[QS] Objective $idx: type=${obj.type}, description=${obj.description}, questionIds=${obj.questionIds}',
          );
        });

        Objective? questionObjective;
        try {
          // Simplificado: Objective.fromJson ahora asegura que questionIds no sea null.
          questionObjective = mission.objectives.firstWhere(
            (obj) => obj.type == 'questions' && obj.questionIds.isNotEmpty,
          );
          print(
            '[QS] Found question objective: ${questionObjective.description}, questionIds: ${questionObjective.questionIds}',
          );
        } catch (e) {
          questionObjective =
              null; // No se encontró un objetivo de tipo 'questions' con questionIds no vacíos
          print(
            '[QS] No question objective with non-empty questionIds found for mission ${mission.name}. Error: $e',
          );
        }

        // questionObjective.questionIds != null ya no es necesario debido al cambio en Objective.fromJson
        if (questionObjective != null &&
            questionObjective.questionIds.isNotEmpty) {
          print(
            '[QS] Objective has questionIds: ${questionObjective.questionIds}',
          );
          final List<QuestionModel> loadedQuestions = await _questionService
              .getQuestionsByIds(questionObjective.questionIds);
          print(
            '[QS] Loaded ${loadedQuestions.length} questions from QuestionService.',
          );

          if (loadedQuestions.isNotEmpty) {
            setState(() {
              _questions = loadedQuestions; // Asignar las preguntas cargadas
              _isLoading = false;
            });
          } else {
            print(
              "[QS] Warning: QuestionService returned no questions for IDs: ${questionObjective.questionIds}. Mission: ${widget.missionId}.",
            );
            setState(() {
              _isLoading = false;
              _errorMessage =
                  "No se pudieron cargar los detalles de las preguntas.";
            });
          }
        } else {
          print(
            "[QS] Mission ${mission.name} (ID: ${widget.missionId}) has no valid questionIds in its objectives or no objectives of type 'questions' with IDs.",
          );
          setState(() {
            _isLoading = false;
            _errorMessage = "No se encontraron preguntas para esta misión.";
          });
        }
      } else {
        print(
          "[QS] Error: Mission with ID ${widget.missionId} not found by MissionService.",
        );
        setState(() {
          _isLoading = false;
          _errorMessage = "Misión no encontrada.";
        });
      }
    } catch (e) {
      print(
        "[QS] CRITICAL Error loading mission structure for ${widget.missionId}: $e",
      );
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Error al cargar la estructura de la misión: ${e.toString()}";
      });
    }
  }

  void _resetAnswerState() {
    _selectedOptionIndex = null;
    _answerSubmitted = false;
    _isCurrentAnswerCorrect = null;
  }

  void _submitAnswer(int selectedIndex) async {
    if (_answerSubmitted) return; // No hacer nada si ya se respondió

    final QuestionModel currentQuestion = _questions[_currentIndex];
    final bool isCorrect = currentQuestion.correctAnswerIndex == selectedIndex;

    setState(() {
      _selectedOptionIndex = selectedIndex;
      _answerSubmitted = true;
      _isCurrentAnswerCorrect = isCorrect;
      if (_isCurrentAnswerCorrect == true) {
        _totalCorrectAnswers++; // Incrementar si la respuesta es correcta
      } else {
        _totalIncorrectAnswers++; // Incrementar si la respuesta es incorrecta
      }
    });

    // Actualizar estadísticas de preguntas
    final String? userId = _authService.currentUser?.uid;
    if (userId != null) {
      try {
        await _userService.updateStatsAfterQuestion(userId, isCorrect);
      } catch (e) {
        debugPrint('Error al actualizar estadísticas de pregunta: $e');
      }
    }
  }

  void _moveToNextQuestionOrComplete() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _resetAnswerState(); // Resetear estado para la nueva pregunta
      });
    } else {
      // Es la última pregunta, verificar si todas fueron correctas
      if (_totalCorrectAnswers == _questions.length) {
        _completeMission();
      } else {
        // No todas las respuestas fueron correctas
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Misión fallida. No todas las respuestas fueron correctas.",
              ),
              backgroundColor: Colors.red,
            ),
          );
          // Volver a la pantalla anterior (lista de misiones, por ejemplo)
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _completeMission() async {
    final String? userId = _authService.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario no autenticado.")),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      // Solo otorgar recompensas si no es una repetición
      if (!widget.isReplay) {
        await _userService.addExperience(
          userId,
          _experiencePoints,
          missionId: widget.missionId,
        );
        await _userService.completeMission(
          userId,
          widget.missionId,
          isBattleMission: false,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (widget.isReplay) {
          // Si es repetición, mostrar mensaje y volver al home
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Lección completada. No se otorgaron recompensas por repetición.",
              ),
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          // Si no es repetición, mostrar pantalla de misión completada
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => MissionCompletedScreen(
                    missionId: widget.missionId,
                    missionName: _missionName,
                    experiencePoints: _experiencePoints,
                    coinsEarned: 10, // Monedas por misión de teoría
                    isBattleMission: false,
                    onContinue: () {
                      // Navegar directamente al home con reemplazo completo
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    // unlockedAchievement: ..., // Opcional
                    // earnedReward: ..., // Opcional
                  ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al completar la misión: ${e.toString()}"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Reemplazado PixelAppBar con AppBar estándar por ahora
        title: Text(
          _isLoading
              ? "Cargando Misión..."
              : (_missionName.isNotEmpty ? _missionName : "Misión"),
        ),
        // Si tienes una fuente pixelada, aplícala aquí:
        // style: TextStyle(fontFamily: 'PixelFont'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    final total = _questions.length;
    final current = _currentIndex + 1;
    final incorrect = _totalIncorrectAnswers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de progreso similar a BattleScreen
          LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pregunta $current/$total',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontFamily: 'PixelFont'),
          ),
          const SizedBox(height: 16),
          // Pregunta
          Card(
            color: Colors.yellow[100],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FormattedTextWidget(
                text: _questions[_currentIndex].text,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Opciones con PixelButton
          ..._questions[_currentIndex].options.asMap().entries.map((entry) {
            final idx = entry.key;
            final text = entry.value;
            Color? btnColor;
            final isSelected = _selectedOptionIndex == idx;
            final isCorrectOpt =
                _questions[_currentIndex].correctAnswerIndex == idx;
            if (_answerSubmitted) {
              if (isSelected) {
                btnColor = _isCurrentAnswerCorrect! ? Colors.green : Colors.red;
              } else if (isCorrectOpt)
                btnColor = Colors.green;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: PixelButton(
                onPressed: _answerSubmitted ? null : () => _submitAnswer(idx),
                color: btnColor,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    color: btnColor != null ? Colors.white : null,
                  ),
                ),
              ),
            );
          }),
          if (_answerSubmitted &&
              _questions[_currentIndex].explanation.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              color:
                  _isCurrentAnswerCorrect! ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCurrentAnswerCorrect! ? '¡Correcto!' : '¡Incorrecto!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            _isCurrentAnswerCorrect!
                                ? Colors.green[800]
                                : Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormattedTextWidget(
                      text: _questions[_currentIndex].explanation,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Estadísticas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_totalCorrectAnswers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Correctas'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$incorrect',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Incorrectas'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_answerSubmitted)
            PixelButton(
              onPressed: _moveToNextQuestionOrComplete,
              child: Text(
                _currentIndex < _questions.length - 1
                    ? 'Siguiente Pregunta'
                    : 'Finalizar',
              ),
            ),
        ],
      ),
    );
  }
}

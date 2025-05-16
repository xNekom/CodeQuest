import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // No se usa directamente aquí
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/mission_service.dart';
import '../../services/question_service.dart'; // Importar QuestionService
import '../../models/mission_model.dart'; // Incluye Objective
import '../../models/question_model.dart'; // Importar QuestionModel
import '../../widgets/pixel_widgets.dart'; // Asegúrate de que esta importación esté presente y sea correcta
import '../mission_completed_screen.dart'; // Importar MissionCompletedScreen

/// Pantalla de preguntas de una misión
class QuestionScreen extends StatefulWidget {
  final String missionId;

  const QuestionScreen({super.key, required this.missionId});

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
  final int _experiencePoints = 50;

  int? _selectedOptionIndex; // Para rastrear la opción seleccionada
  bool _answerSubmitted = false; // Para saber si el usuario ya respondió la pregunta actual
  bool? _isCurrentAnswerCorrect; // Para saber si la respuesta seleccionada fue correcta
  int _totalCorrectAnswers = 0; // Contador para respuestas correctas

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
      final MissionModel? mission = await _missionService.getMissionById(widget.missionId);
      
      if (mission != null) {
        _missionName = mission.name;
        print('[QS] Mission loaded: ${mission.name}. Objectives count: ${mission.objectives.length}');
        mission.objectives.asMap().forEach((idx, obj) {
          print('[QS] Objective $idx: type=${obj.type}, description=${obj.description}, questionIds=${obj.questionIds}');
        });

        Objective? questionObjective;
        try {
          // Simplificado: Objective.fromJson ahora asegura que questionIds no sea null.
          questionObjective = mission.objectives.firstWhere(
            (obj) => obj.type == 'questions' && obj.questionIds.isNotEmpty, 
          );
          print('[QS] Found question objective: ${questionObjective.description}, questionIds: ${questionObjective.questionIds}');
        } catch (e) {
          questionObjective = null; // No se encontró un objetivo de tipo 'questions' con questionIds no vacíos
          print('[QS] No question objective with non-empty questionIds found for mission ${mission.name}. Error: $e');
        }

        // questionObjective.questionIds != null ya no es necesario debido al cambio en Objective.fromJson
        if (questionObjective != null && questionObjective.questionIds.isNotEmpty) { 
          print('[QS] Objective has questionIds: ${questionObjective.questionIds}');
          final List<QuestionModel> loadedQuestions = await _questionService.getQuestionsByIds(questionObjective.questionIds);
          print('[QS] Loaded ${loadedQuestions.length} questions from QuestionService.');
          
          if (loadedQuestions.isNotEmpty) {
            setState(() {
              _questions = loadedQuestions; // Asignar las preguntas cargadas
              _isLoading = false;
            });
          } else {
            print("[QS] Warning: QuestionService returned no questions for IDs: ${questionObjective.questionIds}. Mission: ${widget.missionId}.");
            setState(() {
              _isLoading = false;
              _errorMessage = "No se pudieron cargar los detalles de las preguntas.";
            });
          }
        } else {
          print("[QS] Mission ${mission.name} (ID: ${widget.missionId}) has no valid questionIds in its objectives or no objectives of type 'questions' with IDs.");
          setState(() {
            _isLoading = false;
            _errorMessage = "No se encontraron preguntas para esta misión.";
          });
        }
      } else {
        print("[QS] Error: Mission with ID ${widget.missionId} not found by MissionService.");
        setState(() {
          _isLoading = false;
          _errorMessage = "Misión no encontrada.";
        });
      }
    } catch (e) {
      print("[QS] CRITICAL Error loading mission structure for ${widget.missionId}: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar la estructura de la misión: ${e.toString()}";
      });
    }
  }

  void _resetAnswerState() {
    _selectedOptionIndex = null;
    _answerSubmitted = false;
    _isCurrentAnswerCorrect = null;
  }

  void _submitAnswer(int selectedIndex) {
    if (_answerSubmitted) return; // No hacer nada si ya se respondió

    final QuestionModel currentQuestion = _questions[_currentIndex];
    setState(() {
      _selectedOptionIndex = selectedIndex;
      _answerSubmitted = true;
      _isCurrentAnswerCorrect = currentQuestion.correctAnswerIndex == selectedIndex;
      if (_isCurrentAnswerCorrect == true) {
        _totalCorrectAnswers++; // Incrementar si la respuesta es correcta
      }
      // Aquí podrías, por ejemplo, sumar puntos si la respuesta es correcta
      // if (_isCurrentAnswerCorrect == true) {
      //   _userService.addScore(userId, scoreForCorrectAnswer);
      // }
    });
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
              content: Text("Misión fallida. No todas las respuestas fueron correctas."),
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

    setState(() { _isLoading = true; });
    try {
      await _userService.addExperience(userId, _experiencePoints);
      await _userService.completeMission(userId, widget.missionId);

      setState(() { _isLoading = false; });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MissionCompletedScreen(
              missionId: widget.missionId,
              missionName: _missionName,
              experiencePoints: _experiencePoints,
              onContinue: () {
                // Navegar de vuelta a la lista de misiones o a la pantalla principal
                // Esto asume que MissionListScreen es la ruta raíz o una ruta principal a la que quieres volver
                Navigator.of(context).popUntil((route) => route.isFirst); 
              },
              // unlockedAchievement: ..., // Opcional
              // earnedReward: ..., // Opcional
            ),
          ),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al completar la misión: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Reemplazado PixelAppBar con AppBar estándar por ahora
        title: Text(_isLoading ? "Cargando Misión..." : (_missionName.isNotEmpty ? _missionName : "Misión")),
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
      // Reemplazado PixelProgressIndicator con CircularProgressIndicator estándar
      return const Center(child: CircularProgressIndicator()); 
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(fontSize: 18, color: Colors.red, fontFamily: 'PixelFont')), // Usando Text
      );
    }

    if (_questions.isEmpty) { // Comprobar _questions en lugar de _questionIds
      return const Center(
        child: Text("No hay preguntas disponibles para esta misión.", style: TextStyle(fontSize: 18, fontFamily: 'PixelFont')), // Usando Text
      );
    }

    final QuestionModel currentQuestion = _questions[_currentIndex]; // Obtener la pregunta actual

    return SingleChildScrollView( // Envuelto en SingleChildScrollView para evitar overflow
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Pregunta ${_currentIndex + 1}/${_questions.length}",
            style: const TextStyle(fontSize: 20, fontFamily: 'PixelFont'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentQuestion.text,
              style: const TextStyle(fontSize: 18, fontFamily: 'PixelFont'),
            ),
          ),
          const SizedBox(height: 20),
          // Mostrar opciones de respuesta
          ...currentQuestion.options.asMap().entries.map((entry) {
            int idx = entry.key;
            String optionText = entry.value;
            
            Color buttonColor = Colors.blue; // Color por defecto
            bool isSelected = _selectedOptionIndex == idx;
            bool isCorrect = currentQuestion.correctAnswerIndex == idx;

            if (_answerSubmitted) {
              if (isSelected) {
                buttonColor = _isCurrentAnswerCorrect == true ? Colors.green : Colors.red;
              } else if (isCorrect) {
                buttonColor = Colors.green.withOpacity(0.7); // Resaltar la correcta si no fue la seleccionada
              } else {
                buttonColor = Colors.grey; // Opción no seleccionada e incorrecta
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              // Usando ElevatedButton para facilitar el cambio de color y deshabilitación
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: buttonColor.withOpacity(0.5), // Color cuando está deshabilitado
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontFamily: 'PixelFont', fontSize: 16, color: Colors.white),
                ).copyWith(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.white.withOpacity(0.8);
                      }
                      return Colors.white; // Color del texto
                    },
                  ),
                ),
                onPressed: _answerSubmitted ? null : () => _submitAnswer(idx),
                child: Text(optionText),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          if (_answerSubmitted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCurrentAnswerCorrect == true ? Colors.green.shade100 : Colors.red.shade100,
                border: Border.all(color: _isCurrentAnswerCorrect == true ? Colors.green : Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isCurrentAnswerCorrect == true ? "¡Correcto!" : "Incorrecto",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PixelFont',
                      color: _isCurrentAnswerCorrect == true ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion.explanation,
                    style: TextStyle(fontSize: 16, fontFamily: 'PixelFont', color: Colors.black87),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 30),
          if (_answerSubmitted)
            PixelButton( // O ElevatedButton si PixelButton no está disponible/configurado
              onPressed: _moveToNextQuestionOrComplete,
              child: Text(
                _currentIndex < _questions.length - 1 ? "Siguiente Pregunta" : "Finalizar Misión",
                style: const TextStyle(fontFamily: 'PixelFont', color: Colors.white)
              ),
            ),
          // ... El botón de retroceder se omite por simplicidad, pero podría añadirse aquí
        ],
      ),
    );
  }
}

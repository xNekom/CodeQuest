import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/enemy_model.dart';
import '../../models/question_model.dart';
import '../../models/battle_config_model.dart';
import '../../services/question_service.dart';
import '../../services/enemy_service.dart';
import '../../services/user_service.dart';
import '../../services/reward_service.dart';
import '../../widgets/pixel_widgets.dart';

class BattleScreen extends StatefulWidget {
  final BattleConfigModel battleConfig;

  const BattleScreen({super.key, required this.battleConfig});

  @override
  // ignore: library_private_types_in_public_api
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {  EnemyModel? _currentEnemy;
  QuestionModel? _currentQuestion;
  int _currentQuestionIndex = 0;
  List<String> _questionIds = [];
  final QuestionService _questionService = QuestionService();
  final EnemyService _enemyService = EnemyService();
  final UserService _userService = UserService();
  final RewardService _rewardService = RewardService();
  bool _isLoading = true;
  int? _selectedOptionIndex;
  bool _answerSubmitted = false;
  bool? _isCurrentAnswerCorrect;
  int _totalCorrectAnswers = 0;
  int _totalIncorrectAnswers = 0;
  @override
  void initState() {
    super.initState();
    _questionIds = widget.battleConfig.questionIds;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Cargar información del enemigo una sola vez al inicio
    try {
      print('[BattleScreen] Loading enemy data for ID: ${widget.battleConfig.enemyId}');
      final enemy = await _enemyService.getEnemyById(widget.battleConfig.enemyId);
      if (mounted) {
        setState(() {
          _currentEnemy = enemy;
        });
      }
      if (enemy != null) {
        print('[BattleScreen] Enemy loaded successfully: ${enemy.name}');
      } else {
        print('[BattleScreen] Warning: Enemy not found for ID: ${widget.battleConfig.enemyId}');
      }
    } catch (e) {
      print('[BattleScreen] Error loading enemy: $e');
    }
    
    // Cargar la primera pregunta
    _loadData();
  }
  void _loadData() async {
    setState(() {
      _isLoading = true;
      _selectedOptionIndex = null;
      _answerSubmitted = false;
      _isCurrentAnswerCorrect = null;
    });

    try {
      if (_questionIds.isNotEmpty && _currentQuestionIndex < _questionIds.length) {
        final questionId = _questionIds[_currentQuestionIndex];
        print('[BattleScreen] Loading question: $questionId');
        
        // Cargar la pregunta real desde el servicio
        final questions = await _questionService.getQuestionsByIds([questionId]);
        
        if (questions.isNotEmpty) {
          if (mounted) {
            setState(() {
              _currentQuestion = questions.first;
              _isLoading = false;
            });
          }
        } else {
          print('[BattleScreen] No question found for ID: $questionId');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: No se pudo cargar la pregunta $questionId')),
            );
          }
        }
      } else {
        print('[BattleScreen] No more questions to load or invalid question index');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('[BattleScreen] Error loading question: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la pregunta: $e')),
        );
      }
    }
  }

  void _submitAnswer(int selectedOptionIndex) {
    if (_answerSubmitted || _currentQuestion == null) return;

    setState(() {
      _selectedOptionIndex = selectedOptionIndex;
      _answerSubmitted = true;
      _isCurrentAnswerCorrect = selectedOptionIndex == _currentQuestion!.correctAnswerIndex;
      
      if (_isCurrentAnswerCorrect!) {
        _totalCorrectAnswers++;
      } else {
        _totalIncorrectAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questionIds.length - 1) {
      _currentQuestionIndex++;
      _loadData();
    } else {
      _finishBattle();
    }
  }
  void _finishBattle() async {
    bool victory = _totalCorrectAnswers >= (_questionIds.length * 0.6);

    if (victory) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          // Actualizar estadísticas de batalla
          await _userService.updateStatsAfterBattle(userId, true);
          
          // Si hay enemigo, actualizar estadísticas de enemigo derrotado
          if (_currentEnemy != null) {
            await _userService.updateEnemyDefeatedStats(userId, _currentEnemy!.enemyId);
            await _rewardService.checkAndUnlockEnemyAchievements(userId, _currentEnemy!.enemyId);
          }
          
          // Completar misión si está en progreso
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
          final currentMissionId = userDoc.data()?['currentMissionId'] as String?;
          if (currentMissionId != null && currentMissionId.isNotEmpty) {
            await _userService.completeMission(userId, currentMissionId);
          }
        } catch (e) {
          debugPrint('[BattleScreen] Error al completar misión: $e');
        }
      }
    } else {
      // En caso de derrota, solo actualizar estadísticas de batalla
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await _userService.updateStatsAfterBattle(userId, false);
        } catch (e) {
          debugPrint('[BattleScreen] Error al actualizar estadísticas: $e');
        }
      }
    }    
    if (!mounted) return; // Evitar usar contexto si el widget ya fue desmontado

    // Batalla completada
    String resultMessage;
    String? enemyDialogue;
    
    if (victory) {
      resultMessage = '¡Victoria! Respondiste correctamente $_totalCorrectAnswers de ${_questionIds.length} preguntas.';
      enemyDialogue = _currentEnemy?.dialogue?['defeat'];
    } else {
      resultMessage = 'Derrota. Solo respondiste correctamente $_totalCorrectAnswers de ${_questionIds.length} preguntas.';
      enemyDialogue = _currentEnemy?.dialogue?['victory'];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(victory ? '¡Victoria!' : 'Derrota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(resultMessage),
            if (enemyDialogue != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: victory ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: victory ? Colors.green[200]! : Colors.red[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: victory ? Colors.green[600] : Colors.red[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        enemyDialogue,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: victory ? Colors.green[700] : Colors.red[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Icon(
                      Icons.format_quote,
                      color: victory ? Colors.green[600] : Colors.red[600],
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          PixelButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar dialog
              Navigator.of(context).pop(); // Volver a la pantalla anterior
            },
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Batalla - Pregunta ${_currentQuestionIndex + 1}/${_questionIds.length}'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );

    if (_isLoading || _currentQuestion == null) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: appBar,      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección del enemigo con imagen y diálogo
            if (_currentEnemy != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Imagen del enemigo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),                        child: _currentEnemy!.assetPath != null && _currentEnemy!.assetPath!.isNotEmpty
                            ? Image.asset(
                                _currentEnemy!.assetPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildEnemyPlaceholder();
                                },
                              )
                            : _buildEnemyPlaceholder(),
                      ),
                      const SizedBox(height: 12),
                      
                      // Nombre del enemigo
                      Text(
                        _currentEnemy!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),                      textAlign: TextAlign.center,
                      ),
                        // Descripción del enemigo
                      Text(
                        _currentEnemy!.description ?? 'Enemigo misterioso',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Diálogo del enemigo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: Colors.red[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentEnemy!.dialogue?['encounter'] ?? '¡Prepárate para la batalla!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Icon(
                              Icons.format_quote,
                              color: Colors.red[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Progreso de la batalla
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questionIds.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            
            const SizedBox(height: 24),
            
            // Pregunta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentQuestion!.text,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Opciones de respuesta
            ..._currentQuestion!.options.asMap().entries.map((entry) {
               int idx = entry.key;
               String optionText = entry.value;
              
              Color? buttonColor;
              if (_answerSubmitted && _selectedOptionIndex == idx) {
                buttonColor = _isCurrentAnswerCorrect! ? Colors.green : Colors.red;
              } else if (_answerSubmitted && idx == _currentQuestion!.correctAnswerIndex) {
                buttonColor = Colors.green;
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: PixelButton(
                  onPressed: _answerSubmitted ? null : () => _submitAnswer(idx),
                  color: buttonColor,
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: buttonColor != null ? Colors.white : null,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              );
            }),
            
            // Mostrar explicación si ya se respondió
            if (_answerSubmitted && _currentQuestion!.explanation.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                color: _isCurrentAnswerCorrect! ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCurrentAnswerCorrect! ? '¡Correcto!' : 'Incorrecto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isCurrentAnswerCorrect! ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_currentQuestion!.explanation),
                    ],
                  ),
                ),
              ),
            ],
            
            // Botón manual para avanzar o terminar
            if (_answerSubmitted) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PixelButton(
                  onPressed: () {
                    _nextQuestion();
                  },
                  child: Text(
                    _currentQuestionIndex < _questionIds.length - 1 ? 'SIGUIENTE' : 'FINALIZAR',
                    style: const TextStyle(fontFamily: 'PixelFont'),
                  ),
                ),
              ),
            ],
            
            // Estadísticas de la batalla
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
                          '$_totalIncorrectAnswers',
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
          ],
        ),      ),
    );
  }

  Widget _buildEnemyPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.red[400]!, Colors.red[700]!],
          center: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cuerpo del enemigo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red[600],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          // Cara del enemigo
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ojos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Boca
              Container(
                width: 20,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          // Símbolo de error
          Positioned(
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black),
              ),
              child: const Text(
                'BUG',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

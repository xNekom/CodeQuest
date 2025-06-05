import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/enemy_model.dart';
import '../../models/question_model.dart';
import '../../models/battle_config_model.dart';
import '../../services/question_service.dart';
import '../../services/enemy_service.dart';
import '../../services/user_service.dart';
import '../../services/reward_service.dart';
import '../../services/auth_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/pixel_widgets.dart';
import '../../widgets/pixel_app_bar.dart';
import 'package:codequest/widgets/formatted_text_widget.dart';
import '../mission_completed_screen.dart';

class BattleScreen extends StatefulWidget {
  final BattleConfigModel battleConfig;
  final bool isReplay;

  const BattleScreen({
    super.key,
    required this.battleConfig,
    this.isReplay = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  EnemyModel? _currentEnemy;
  QuestionModel? _currentQuestion;
  int _currentQuestionIndex = 0;
  List<String> _questionIds = [];
  final QuestionService _questionService = QuestionService();
  final EnemyService _enemyService = EnemyService();
  final UserService _userService = UserService();
  final RewardService _rewardService = RewardService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  int? _selectedOptionIndex;
  bool _answerSubmitted = false;
  bool? _isCurrentAnswerCorrect;
  int _totalCorrectAnswers = 0;
  int _totalIncorrectAnswers = 0;
  bool _isProcessingNextQuestion = false; // Variable para evitar doble clic
  int _missionExperience = 175; // Experiencia que otorga la misión de batalla
  @override
  void initState() {
    super.initState();
    _questionIds = widget.battleConfig.questionIds;
    // Asegurar que la música de batalla continúe durante las preguntas
    AudioService().playBattleTheme();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Cargar información del enemigo una sola vez al inicio
    try {
      // [BattleScreen] Loading enemy data for ID: ${widget.battleConfig.enemyId}
      final enemy = await _enemyService.getEnemyById(
        widget.battleConfig.enemyId,
      );
      if (mounted) {
        setState(() {
          _currentEnemy = enemy;
        });
      }
      if (enemy != null) {
        // [BattleScreen] Enemy loaded successfully: ${enemy.name}
      } else {
        // [BattleScreen] Warning: Enemy not found for ID: ${widget.battleConfig.enemyId}
      }
    } catch (e) {
      // [BattleScreen] Error loading enemy: $e
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
      if (_questionIds.isNotEmpty &&
          _currentQuestionIndex < _questionIds.length) {
        final questionId = _questionIds[_currentQuestionIndex];
        // [BattleScreen] Loading question: $questionId

        // Cargar la pregunta real desde el servicio
        final questions = await _questionService.getQuestionsByIds([
          questionId,
        ]);

        if (questions.isNotEmpty) {
          if (mounted) {
            setState(() {
              _currentQuestion = questions.first;
              _isLoading = false;
            });
          }
        } else {
          // [BattleScreen] No question found for ID: $questionId
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: No se pudo cargar la pregunta $questionId',
                ),
              ),
            );
          }
        }
      } else {
        // [BattleScreen] No more questions to load or invalid question index
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // [BattleScreen] Error loading question: $e
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
      _isCurrentAnswerCorrect =
          selectedOptionIndex == _currentQuestion!.correctAnswerIndex;

      if (_isCurrentAnswerCorrect!) {
        _totalCorrectAnswers++;
      } else {
        _totalIncorrectAnswers++;
      }
    });
  }

  void _nextQuestion() {
    // Evitar múltiples clics
    if (_isProcessingNextQuestion) return;
    
    setState(() {
      _isProcessingNextQuestion = true;
    });
    
    if (_currentQuestionIndex < _questionIds.length - 1) {
      _currentQuestionIndex++;
      _loadData();
      // Restablecer el estado después de cargar los datos
      setState(() {
        _isProcessingNextQuestion = false;
      });
    } else {
      _finishBattle();
      // No necesitamos restablecer _isProcessingNextQuestion aquí porque
      // _finishBattle() navega a otra pantalla
    }
  }

  void _finishBattle() async {
    bool victory = _totalCorrectAnswers >= (_questionIds.length * 0.6);
    String? completedMissionId;
    String missionName = 'Batalla contra ${_currentEnemy?.name ?? "Enemigo"}';

    // Reproducir música de victoria si ganó
    if (victory) {
      AudioService().playVictoryTheme();
    }

    if (victory) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && !widget.isReplay) {
        try {
          // Actualizar estadísticas de batalla
          await _userService.updateStatsAfterBattle(userId, true);

          // Si hay enemigo, actualizar estadísticas de enemigo derrotado
          if (_currentEnemy != null) {
            await _userService.updateEnemyDefeatedStats(
              userId,
              _currentEnemy!.enemyId,
            );
            await _rewardService.checkAndUnlockEnemyAchievements(
              userId,
              _currentEnemy!.enemyId,
            );
          }

          // Completar misión si está en progreso
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get();
          final currentMissionId =
              userDoc.data()?['currentMissionId'] as String?;
          if (currentMissionId != null && currentMissionId.isNotEmpty) {
            completedMissionId = currentMissionId;

            // Obtener el nombre real de la misión y experiencia
            try {
              final missionDoc =
                  await FirebaseFirestore.instance
                      .collection('missions')
                      .doc(currentMissionId)
                      .get();
              if (missionDoc.exists) {
                final missionData = missionDoc.data();
                missionName = missionData?['name'] ?? missionName;
                // Guardar experiencia para usar en las recompensas usando el método confiable
                _missionExperience = await _getExperienceFromMissionData(currentMissionId);
              }
            } catch (e) {
              debugPrint(
                '[BattleScreen] Error al obtener datos de misión: $e',
              );
            }
          }
        } catch (e) {
        // debugPrint('[BattleScreen] Error al completar misión: $e'); // REMOVIDO PARA PRODUCCIÓN
      }
      }
    } else {
      // En caso de derrota, solo actualizar estadísticas de batalla si no es repetición
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && !widget.isReplay) {
        try {
          await _userService.updateStatsAfterBattle(userId, false);
        } catch (e) {
        // debugPrint('[BattleScreen] Error al actualizar estadísticas: $e'); // REMOVIDO PARA PRODUCCIÓN
      }
      }
    }
    if (!mounted) return; // Evitar usar contexto si el widget ya fue desmontado

    // Batalla completada
    String resultMessage;
    String? enemyDialogue;

    if (victory) {
      resultMessage =
          '¡Victoria! Respondiste correctamente $_totalCorrectAnswers de ${_questionIds.length} preguntas.';
      enemyDialogue = _currentEnemy?.dialogue?['defeat'];
    } else {
      resultMessage =
          'Derrota. Solo respondiste correctamente $_totalCorrectAnswers de ${_questionIds.length} preguntas.';
      enemyDialogue = _currentEnemy?.dialogue?['victory'];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
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
                              color:
                                  victory ? Colors.green[700] : Colors.red[700],
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

                  if (widget.isReplay) {
                    // Si es repetición, mostrar mensaje y volver al home
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          victory
                              ? "Batalla completada. No se otorgaron recompensas por repetición."
                              : "Batalla perdida. Intenta de nuevo.",
                        ),
                      ),
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  } else if (victory && completedMissionId != null) {
                    // Si ganó y completó una misión, mostrar pantalla de misión completada inmediatamente
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MissionCompletedScreen(
                              missionId: completedMissionId!,
                              missionName: missionName,
                              experiencePoints: _missionExperience, // Usar el valor actualizado
                              coinsEarned: 50, // Monedas por batalla
                              isBattleMission: true,
                              onContinue: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              },
                            ),
                      ),
                    );
                    
                    // Procesar recompensas en segundo plano
                    _processBattleRewardsInBackground(completedMissionId);
                  } else {
                    // Si no completó misión o perdió, volver al home directamente
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  }
                },
                child: const Text('CONTINUAR'),
              ),
            ],
          ),
    );
  }

  // Método para obtener la experiencia directamente del JSON de la misión
  Future<int> _getExperienceFromMissionData(String missionId) async {
    try {
      // Cargar el JSON directamente desde assets
      final String jsonString = await rootBundle.loadString('assets/data/missions_data.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      // Buscar la misión por ID
      for (var missionData in jsonList) {
        if (missionData['id'] == missionId) {
          // Acceder directamente al campo experience en rewards
          return missionData['rewards']?['experience'] ?? 175;
        }
      }
      
      // Si no se encuentra la misión, devolver valor por defecto
      return 175;
    } catch (e) {
      // En caso de error, devolver valor por defecto
      return 175;
    }
  }

  // Procesar recompensas de batalla en segundo plano sin bloquear la UI
  void _processBattleRewardsInBackground(String? missionId) async {
    final String? userId = _authService.currentUser?.uid;
    if (userId == null || missionId == null) return;

    try {
      // Obtener la experiencia correcta directamente del JSON
      final int experiencePoints = await _getExperienceFromMissionData(missionId);
      
      // Primero otorgar experiencia antes de marcar como completada
      await _userService.addExperience(
        userId,
        experiencePoints, // Experiencia correcta desde el JSON
        missionId: missionId,
      );
      
      // Luego ejecutar las demás operaciones
      await Future.wait([
        _userService.completeMission(
          userId,
          missionId,
          isBattleMission: true,
        ),
        _userService.updateStatsAfterBattle(userId, true), // Victoria
      ]);
    } catch (e) {
      // Manejar errores silenciosamente
      debugPrint('Error procesando recompensas de batalla en segundo plano');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = PixelAppBar(
      title: 'Batalla - Pregunta ${_currentQuestionIndex + 1}/${_questionIds.length}',
      backgroundColor: Theme.of(context).colorScheme.primary,
      titleFontSize: 12,
    );

    if (_isLoading || _currentQuestion == null) {
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
                        ),
                        child: _buildEnemyPlaceholder(),
                      ),
                      const SizedBox(height: 12),

                      // Nombre del enemigo
                      Text(
                        _currentEnemy!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                        textAlign: TextAlign.center,
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
                                _currentEnemy!.dialogue?['encounter'] ??
                                    '¡Prepárate para la batalla!',
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
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Pregunta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FormattedTextWidget(
                  text: _currentQuestion!.text,
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
                buttonColor =
                    _isCurrentAnswerCorrect! ? Colors.green : Colors.red;
              } else if (_answerSubmitted &&
                  idx == _currentQuestion!.correctAnswerIndex) {
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
            if (_answerSubmitted &&
                _currentQuestion!.explanation.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                color:
                    _isCurrentAnswerCorrect!
                        ? Colors.green[50]
                        : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCurrentAnswerCorrect! ? '¡Correcto!' : 'Incorrecto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _isCurrentAnswerCorrect!
                                  ? Colors.green[800]
                                  : Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentQuestion!.explanation,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      ),
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
                  onPressed: _isProcessingNextQuestion ? null : () {
                  _nextQuestion();
                },
                child: _isProcessingNextQuestion
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _currentQuestionIndex < _questionIds.length - 1
                            ? 'SIGUIENTE'
                            : 'FINALIZAR',
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
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
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
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
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
        ),
      ),
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

  @override
  void dispose() {
    // Regresar a la música principal al salir de la batalla
    AudioService().playMainTheme();
    super.dispose();
  }
}

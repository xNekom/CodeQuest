import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/pixel_widgets.dart';
import '../../screens/mission_completed_screen.dart';

/// Pantalla de preguntas de una misión
class QuestionScreen extends StatefulWidget {
  final String missionId;

  const QuestionScreen({super.key, required this.missionId});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  List<String> _questionIds = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String _missionName = "";
  final int _experiencePoints = 50; // Puntos base por completar una misión

  @override
  void initState() {
    super.initState();
    _loadMissionStructure();
  }
  Future<void> _loadMissionStructure() async {
    final doc = await FirebaseFirestore.instance
        .collection('missions')
        .doc(widget.missionId)
        .get();
    final data = doc.exists ? doc.data() as Map<String, dynamic> : null;
    setState(() {
      _questionIds = data != null ? List<String>.from(data['structure'] ?? []) : [];
      _missionName = data != null ? data['name'] as String? ?? 'Misión' : 'Misión';
      _isLoading = false;
    });
  }

  Future<DocumentSnapshot> _loadQuestion(String qId) {
    return FirebaseFirestore.instance.collection('questions').doc(qId).get();
  }

  Future<void> _showExplanationAndProceed(String qId, int selectedIndex, int correctIndex, String explanation) async {
    final user = _authService.currentUser;
    if (user == null) return;
    final isCorrect = selectedIndex == correctIndex;
    await _userService.updateStatsAfterQuestion(user.uid, isCorrect);
    if (!mounted) return;
    await _userService.updateProgressInMission(user.uid, qId, isCorrect);
    if (!mounted) return;
    // Diálogo con explicación
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? '¡Correcto!' : 'Incorrecto'),
        content: Text(explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    // Solo avanzar o completar si la respuesta es correcta
    if (isCorrect) {
      if (_currentIndex + 1 < _questionIds.length) {
        setState(() {
          _currentIndex++;
        });      } else {
        await _userService.completeMission(user.uid, widget.missionId);
        await _userService.addExperience(user.uid, _experiencePoints);
        
        if (!mounted) return;
        
        // En lugar de mostrar un diálogo simple, navegar a la pantalla de misión completada
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MissionCompletedScreen(
              missionId: widget.missionId,
              missionName: _missionName,
              experiencePoints: _experiencePoints,
              onContinue: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ),
        );
      }
    }
    // En caso de error, mantener la misma pregunta para reintentar
    // (ya se mostró explicación)
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_questionIds.isEmpty) {
      return Scaffold(body: Center(child: Text('Estructura de misión vacía.')));
    }
    final qId = _questionIds[_currentIndex];
    return FutureBuilder<DocumentSnapshot>(
      future: _loadQuestion(qId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.data!.exists) {
          return Scaffold(body: Center(child: Text('Pregunta no encontrada: $qId')));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final options = List<String>.from(data['options'] ?? []);
        final correctIndex = data['correctAnswerIndex'] ?? 0;
        final explanation = data['explanation'] as String? ?? 'No hay explicación disponible.';

        return Scaffold(
          appBar: AppBar(title: Text('Pregunta ${_currentIndex + 1}/${_questionIds.length}')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['text'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 24),
                ...List.generate(options.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: PixelButton(
                      onPressed: () => _showExplanationAndProceed(qId, i, correctIndex, explanation),
                      color: Theme.of(context).colorScheme.primary,
                      child: Text(options[i]),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

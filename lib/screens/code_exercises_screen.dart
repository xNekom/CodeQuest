import 'package:flutter/material.dart';
import '../models/code_exercise_model.dart';
import '../services/code_exercise_service.dart';
import '../widgets/code_playground.dart';
import '../widgets/pixel_widgets.dart';

/// Pantalla que muestra la lista de ejercicios de código disponibles
class CodeExercisesScreen extends StatefulWidget {
  const CodeExercisesScreen({super.key});

  @override
  State<CodeExercisesScreen> createState() => _CodeExercisesScreenState();
}

class _CodeExercisesScreenState extends State<CodeExercisesScreen> {
  final CodeExerciseService _exerciseService = CodeExerciseService();
  List<CodeExerciseModel> _exercises = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _loadExercises();
      }
    });
  }

  /// Carga los ejercicios desde el servicio
  Future<void> _loadExercises() async {
    try {
      debugPrint('🚀 Iniciando carga de ejercicios...');
      final exercises = await _exerciseService.getAllExercises();
      debugPrint('📚 Ejercicios recibidos: ${exercises.length}');

      setState(() {
        _exercises = exercises;
        _isLoading = false;
        _error = null; // Limpiar error previo
      });

      if (exercises.isEmpty) {
        debugPrint('⚠️ Lista de ejercicios vacía');
      }
    } catch (e) {
      debugPrint('❌ Error en _loadExercises: $e');
      setState(() {
        _error = 'Error al cargar los ejercicios: $e';
        _isLoading = false;
        _exercises = []; // Asegurar que la lista esté vacía
      });
    }
  }

  /// Navega al playground del ejercicio seleccionado
  void _openExercise(CodeExerciseModel exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CodePlayground(
              exercise: exercise,
              onComplete: () {
                Navigator.of(context).pop();
                // Aquí podrías actualizar el progreso del usuario
                _showCompletionMessage(exercise);
              },
            ),
      ),
    );
  }

  /// Muestra mensaje de completación del ejercicio
  void _showCompletionMessage(CodeExerciseModel exercise) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Has completado "${exercise.title}"!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Construye la tarjeta de un ejercicio
  Widget _buildExerciseCard(CodeExerciseModel exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: InkWell(
        onTap: () => _openExercise(exercise),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y dificultad
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Indicador de dificultad
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(exercise.difficulty),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.difficulty}/5',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Descripción
              Text(
                exercise.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Conceptos y estadísticas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Conceptos
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        exercise.concepts.take(3).map((concept) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              concept,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[800],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Información adicional
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 14,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${exercise.hints.length} pistas',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${exercise.testCases.length} pruebas',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Botón de acción
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _openExercise(exercise),
                  icon: const Icon(Icons.code, size: 16),
                  label: const Text('Programar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el color según la dificultad
  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios de Programación'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[800]!, Colors.blue[50]!],
          ),
        ),
        child:
            _isLoading
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Cargando ejercicios...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
                : _error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadExercises();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
                : _exercises.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code_off, size: 64, color: Colors.white70),
                      SizedBox(height: 16),
                      Text(
                        'No hay ejercicios disponibles',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    // Header con estadísticas
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '${_exercises.length}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        color: Colors.blue[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Ejercicios'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '${_exercises.where((e) => e.difficulty <= 2).length}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Fáciles'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '${_exercises.where((e) => e.difficulty >= 4).length}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        color: Colors.red[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Difíciles'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Lista de ejercicios
                    Expanded(
                      child: ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          return _buildExerciseCard(_exercises[index]);
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

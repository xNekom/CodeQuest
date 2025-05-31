/// Modelo para ejercicios de programación interactivos
class CodeExerciseModel {
  /// ID único del ejercicio
  final String exerciseId;

  /// Título del ejercicio
  final String title;

  /// Descripción del problema a resolver
  final String description;

  /// Código inicial que se muestra al usuario
  final String initialCode;

  /// Output esperado cuando el código se ejecuta correctamente
  final String expectedOutput;

  /// Lista de pistas que se pueden mostrar al usuario
  final List<String> hints;

  /// Patrones que el código debe contener para ser válido
  final List<String> requiredPatterns;

  /// Patrones que el código NO debe contener
  final List<String> forbiddenPatterns;

  /// Casos de prueba con diferentes inputs y outputs esperados
  final List<TestCase> testCases;

  /// Nivel de dificultad (1-5)
  final int difficulty;

  /// Conceptos de programación que se practican
  final List<String> concepts;

  /// Contenido teórico del ejercicio (opcional)
  final String? theory;

  const CodeExerciseModel({
    required this.exerciseId,
    required this.title,
    required this.description,
    required this.initialCode,
    required this.expectedOutput,
    required this.hints,
    required this.requiredPatterns,
    required this.forbiddenPatterns,
    required this.testCases,
    required this.difficulty,
    required this.concepts,
    this.theory,
  });

  factory CodeExerciseModel.fromJson(Map<String, dynamic> json) {
    return CodeExerciseModel(
      exerciseId: json['exerciseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      initialCode: json['initialCode'] as String,
      expectedOutput: json['expectedOutput'] as String,
      hints: List<String>.from(json['hints'] as List),
      requiredPatterns: List<String>.from(json['requiredPatterns'] as List),
      forbiddenPatterns: List<String>.from(json['forbiddenPatterns'] as List),
      testCases:
          (json['testCases'] as List)
              .map((tc) => TestCase.fromJson(tc as Map<String, dynamic>))
              .toList(),
      difficulty: json['difficulty'] as int,
      concepts: List<String>.from(json['concepts'] as List),
      theory: json['theory'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'title': title,
      'description': description,
      'initialCode': initialCode,
      'expectedOutput': expectedOutput,
      'hints': hints,
      'requiredPatterns': requiredPatterns,
      'forbiddenPatterns': forbiddenPatterns,
      'testCases': testCases.map((tc) => tc.toJson()).toList(),
      'difficulty': difficulty,
      'concepts': concepts,
      if (theory != null) 'theory': theory,
    };
  }
}

/// Representa un caso de prueba para validar el código
class TestCase {
  /// Descripción del caso de prueba
  final String description;

  /// Input que se pasa al programa (si aplica)
  final String? input;

  /// Output esperado para este caso
  final String expectedOutput;

  /// Si este caso es visible para el usuario o es oculto
  final bool isHidden;

  const TestCase({
    required this.description,
    this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      description: json['description'] as String,
      input: json['input'] as String?,
      expectedOutput: json['expectedOutput'] as String,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      if (input != null) 'input': input,
      'expectedOutput': expectedOutput,
      'isHidden': isHidden,
    };
  }
}

/// Resultado de la validación de código
class CodeValidationResult {
  /// Si el código pasó todas las validaciones
  final bool isValid;

  /// Puntuación obtenida (0-100)
  final int score;

  /// Mensajes de error o advertencias
  final List<String> messages;

  /// Casos de prueba que pasaron
  final List<TestCase> passedTests;

  /// Casos de prueba que fallaron
  final List<TestCase> failedTests;

  /// Output simulado del código
  final String? simulatedOutput;

  const CodeValidationResult({
    required this.isValid,
    required this.score,
    required this.messages,
    required this.passedTests,
    required this.failedTests,
    this.simulatedOutput,
  });
}

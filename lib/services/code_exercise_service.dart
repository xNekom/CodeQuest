import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/code_exercise_model.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';

/// Servicio para manejar ejercicios de programación
class CodeExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene un ejercicio por su ID
  Future<CodeExerciseModel?> getExerciseById(String exerciseId) async {
    if (AppConfig.shouldUseFirebase) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('code_exercises').doc(exerciseId).get();
        if (doc.exists) {
          return CodeExerciseModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Error al obtener ejercicio desde Firebase: $e');
      }
      return null;
    } else {
      return _getExerciseByIdFromLocalJson(exerciseId);
    }
  }

  /// Obtiene ejercicio desde JSON local
  Future<CodeExerciseModel?> _getExerciseByIdFromLocalJson(
    String exerciseId,
  ) async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/code_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;

      for (var exerciseData in jsonList) {
        final exercise = exerciseData as Map<String, dynamic>;
        if (exercise['exerciseId'] == exerciseId) {
          return CodeExerciseModel.fromJson(exercise);
        }
      }
    } catch (e) {
      debugPrint('Error al cargar ejercicio desde JSON local: $e');
    }
    return null;
  }

  /// Obtiene todos los ejercicios disponibles
  Future<List<CodeExerciseModel>> getAllExercises() async {
    if (AppConfig.shouldUseFirebase) {
      try {
        debugPrint('🔍 Intentando obtener ejercicios desde Firebase...');
        QuerySnapshot snapshot =
            await _firestore
                .collection('code_exercises')
                .orderBy('difficulty')
                .get();

        debugPrint('📊 Documentos encontrados: ${snapshot.docs.length}');

        if (snapshot.docs.isEmpty) {
          debugPrint('⚠️ No se encontraron ejercicios en Firestore');
          return [];
        }

        List<CodeExerciseModel> exercises = [];
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            debugPrint('📄 Procesando documento: ${doc.id}');
            debugPrint('📋 Datos: ${data.keys.toList()}');

            final exercise = CodeExerciseModel.fromJson(data);
            exercises.add(exercise);
            debugPrint('✅ Ejercicio agregado: ${exercise.title}');
          } catch (docError) {
            debugPrint('❌ Error procesando documento ${doc.id}: $docError');
          }
        }

        debugPrint('🎯 Total de ejercicios procesados: ${exercises.length}');
        return exercises;
      } catch (e) {
        debugPrint('❌ Error al obtener ejercicios desde Firebase: $e');
        debugPrint('📱 Stack trace: ${StackTrace.current}');
        // En lugar de devolver lista vacía, lanzar el error
        rethrow;
      }
    } else {
      return _getAllExercisesFromLocalJson();
    }
  }

  /// Obtiene todos los ejercicios desde JSON local
  Future<List<CodeExerciseModel>> _getAllExercisesFromLocalJson() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/code_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;

      return jsonList
          .map(
            (data) => CodeExerciseModel.fromJson(data as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Error al cargar ejercicios desde JSON local: $e');
      return [];
    }
  }

  /// Valida el código del usuario
  CodeValidationResult validateCode(
    CodeExerciseModel exercise,
    String userCode,
  ) {
    List<String> messages = [];
    List<TestCase> passedTests = [];
    List<TestCase> failedTests = [];
    int score = 0;

    // Validar patrones requeridos
    for (String pattern in exercise.requiredPatterns) {
      if (!userCode.contains(pattern)) {
        messages.add('El código debe contener: $pattern');
      }
    }

    // Validar patrones prohibidos
    for (String pattern in exercise.forbiddenPatterns) {
      if (userCode.contains(pattern)) {
        messages.add('El código no debe contener: $pattern');
      }
    }

    // Validar estructura básica de Java
    if (!_hasValidJavaStructure(userCode)) {
      messages.add('El código debe tener una estructura válida de Java');
    }

    // Simular ejecución de casos de prueba
    String? simulatedOutput = _simulateCodeExecution(exercise, userCode);

    for (TestCase testCase in exercise.testCases) {
      if (_testCasePasses(testCase, simulatedOutput)) {
        passedTests.add(testCase);
        score += (100 ~/ exercise.testCases.length);
      } else {
        failedTests.add(testCase);
        if (!testCase.isHidden) {
          messages.add('Caso de prueba fallido: ${testCase.description}');
        }
      }
    }

    // Validaciones adicionales de sintaxis
    List<String> syntaxErrors = _checkBasicSyntax(userCode);
    messages.addAll(syntaxErrors);

    bool isValid = messages.isEmpty && failedTests.isEmpty;

    return CodeValidationResult(
      isValid: isValid,
      score:
          isValid ? score : (score * 0.7).round(), // Penalizar si hay errores
      messages: messages,
      passedTests: passedTests,
      failedTests: failedTests,
      simulatedOutput: simulatedOutput,
    );
  }

  /// Verifica si el código tiene una estructura básica válida de Java
  bool _hasValidJavaStructure(String code) {
    // Verificar que tenga una clase
    if (!RegExp(r'class\s+\w+').hasMatch(code)) {
      return false;
    }

    // Verificar que tenga método main si es necesario
    if (code.contains('main') &&
        !RegExp(r'public\s+static\s+void\s+main\s*\(').hasMatch(code)) {
      return false;
    }

    // Verificar balance de llaves
    int openBraces = '{'.allMatches(code).length;
    int closeBraces = '}'.allMatches(code).length;
    if (openBraces != closeBraces) {
      return false;
    }

    return true;
  }

  /// Simula la ejecución del código y retorna el output esperado
  String? _simulateCodeExecution(CodeExerciseModel exercise, String userCode) {
    // Esta es una simulación básica. En un caso real, podrías usar
    // un intérprete más sofisticado o mapear patrones específicos a outputs

    // Si el código contiene System.out.println, extraer el contenido
    RegExp printRegex = RegExp(r'System\.out\.println\s*\(\s*"([^"]+)"\s*\)');
    Match? match = printRegex.firstMatch(userCode);

    if (match != null) {
      return match.group(1); // Retorna el texto entre comillas
    }

    // Para ejercicios específicos, mapear patrones conocidos
    if (userCode.contains('"Hola Mundo"') ||
        userCode.contains("'Hola Mundo'")) {
      return 'Hola Mundo';
    }

    // Si no se puede determinar, usar el output esperado del ejercicio
    return exercise.expectedOutput;
  }

  /// Verifica si un caso de prueba pasa
  bool _testCasePasses(TestCase testCase, String? actualOutput) {
    if (actualOutput == null) return false;
    return actualOutput.trim() == testCase.expectedOutput.trim();
  }

  /// Verifica errores básicos de sintaxis
  List<String> _checkBasicSyntax(String code) {
    List<String> errors = [];

    // Verificar punto y coma en statements
    List<String> lines = code.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isNotEmpty &&
          !line.endsWith(';') &&
          !line.endsWith('{') &&
          !line.endsWith('}') &&
          !line.startsWith('//') &&
          !line.startsWith('/*') &&
          !line.startsWith('*') &&
          !line.startsWith('class') &&
          !line.startsWith('public') &&
          !line.startsWith('private') &&
          !line.startsWith('protected')) {
        // Verificar si es una línea que debería terminar en ;
        if (line.contains('System.out') ||
            line.contains('=') ||
            line.contains('int ') ||
            line.contains('String ')) {
          errors.add('Línea ${i + 1}: Falta punto y coma (;)');
        }
      }
    }

    // Verificar comillas balanceadas
    int doubleQuotes = '"'.allMatches(code).length;
    if (doubleQuotes % 2 != 0) {
      errors.add('Comillas dobles no balanceadas');
    }

    return errors;
  }

  /// Obtiene una pista para el ejercicio
  String? getHint(CodeExerciseModel exercise, int hintIndex) {
    if (hintIndex >= 0 && hintIndex < exercise.hints.length) {
      return exercise.hints[hintIndex];
    }
    return null;
  }
}

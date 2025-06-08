import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/code_exercise_model.dart';

class CodeExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CodeExerciseModel?> getExerciseById(String exerciseId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('code_exercises').doc(exerciseId).get();
      if (doc.exists) {
        return CodeExerciseModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
    }
    return null;
  }

  Future<List<CodeExerciseModel>> getAllExercises() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('code_exercises').orderBy('difficulty').get();
      if (snapshot.docs.isEmpty) {
        return [];
      }
      List<CodeExerciseModel> exercises = [];
      for (var doc in snapshot.docs) {
        try {
          exercises.add(CodeExerciseModel.fromJson(doc.data() as Map<String, dynamic>));
        } catch (docError) {
        }
      }
      return exercises;
    } catch (e) {
      rethrow;
    }
  }

  CodeValidationResult validateCode(CodeExerciseModel exercise, String userCode) {
    List<String> messages = [];
    List<TestCase> passedTests = [];
    List<TestCase> failedTests = [];
    int score = 0;

    for (String pattern in exercise.requiredPatterns) {
      if (!userCode.contains(pattern)) {
        messages.add('El código debe contener: $pattern');
      }
    }

    for (String pattern in exercise.forbiddenPatterns) {
      if (userCode.contains(pattern)) {
        messages.add('El código no debe contener: $pattern');
      }
    }

    if (!_hasValidJavaStructure(userCode)) {
      messages.add('El código debe tener una estructura válida de Java');
    }

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

    List<String> syntaxErrors = _checkBasicSyntax(userCode);
    messages.addAll(syntaxErrors);

    bool isValid = messages.isEmpty && failedTests.isEmpty;

    return CodeValidationResult(
      isValid: isValid,
      score: isValid ? score : (score * 0.7).round(),
      messages: messages,
      passedTests: passedTests,
      failedTests: failedTests,
      simulatedOutput: simulatedOutput,
    );
  }

  bool _hasValidJavaStructure(String code) {
    if (!RegExp(r'class\s+\w+').hasMatch(code)) {
      return false;
    }

    if (code.contains('main') &&
        !RegExp(r'public\s+static\s+void\s+main\s*\(').hasMatch(code)) {
      return false;
    }

    int openBraces = '{'.allMatches(code).length;
    int closeBraces = '}'.allMatches(code).length;
    if (openBraces != closeBraces) {
      return false;
    }

    return true;
  }

  String? _simulateCodeExecution(CodeExerciseModel exercise, String userCode) {
    RegExp printRegex = RegExp(r'System\.out\.println\s*\(\s*"([^"]+)"\s*\)');
    Match? match = printRegex.firstMatch(userCode);

    if (match != null) {
      return match.group(1);
    }

    if (userCode.contains('"Hola Mundo"') ||
        userCode.contains("'Hola Mundo'")) {
      return 'Hola Mundo';
    }

    return exercise.expectedOutput;
  }

  bool _testCasePasses(TestCase testCase, String? actualOutput) {
    if (actualOutput == null) return false;
    return actualOutput.trim() == testCase.expectedOutput.trim();
  }

  List<String> _checkBasicSyntax(String code) {
    List<String> errors = [];

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
        if (line.contains('System.out') ||
            line.contains('=') ||
            line.contains('int ') ||
            line.contains('String ')) {
          errors.add('Línea ${i + 1}: Falta punto y coma (;)');
        }
      }
    }

    int doubleQuotes = '"'.allMatches(code).length;
    if (doubleQuotes % 2 != 0) {
      errors.add('Comillas dobles no balanceadas');
    }

    return errors;
  }

  String? getHint(CodeExerciseModel exercise, int hintIndex) {
    if (hintIndex >= 0 && hintIndex < exercise.hints.length) {
      return exercise.hints[hintIndex];
    }
    return null;
  }
}

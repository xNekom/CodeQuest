import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/code_exercise_model.dart';
import '../services/code_exercise_service.dart';
import '../utils/error_handler.dart';
import '../utils/overflow_utils.dart';
import 'pixel_widgets.dart';

/// Widget del playground de código donde el usuario completa líneas faltantes
class CodePlayground extends StatefulWidget {
  final CodeExerciseModel exercise;
  final Function(CodeValidationResult)? onValidationComplete;
  final VoidCallback? onComplete;

  const CodePlayground({
    super.key,
    required this.exercise,
    this.onValidationComplete,
    this.onComplete,
  });

  @override
  State<CodePlayground> createState() => _CodePlaygroundState();
}

class _CodePlaygroundState extends State<CodePlayground> {
  final CodeExerciseService _exerciseService = CodeExerciseService();
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  CodeValidationResult? _lastResult;
  int _currentHintIndex = 0;
  bool _showResult = false;
  String _javaError = '';

  // Líneas de código con espacios en blanco para completar
  List<String> get _codeLines {
    final lines = widget.exercise.initialCode.split('\n');
    bool foundFirstMatch = false;

    // Buscar solo la primera línea que necesita ser completada
    for (int i = 0; i < lines.length; i++) {
      if (!foundFirstMatch &&
          lines[i].trim().startsWith('// Escribe aquí tu código')) {
        lines[i] = '    // COMPLETAR: Escribe aquí la línea de código';
        foundFirstMatch = true;
        break;
      }
    }
    return lines;
  }

  // Obtener la línea correcta que debe escribir el usuario
  String get _correctLine {
    // Generar línea correcta basada en el ejercicio
    switch (widget.exercise.exerciseId) {
      case 'hola_mundo_java':
        return 'System.out.println("Hola Mundo");';
      case 'variables_basicas':
        return 'String nombre = "Juan"; System.out.println("Mi nombre es " + nombre);';
      case 'operaciones_matematicas':
        return 'int suma = numero1 + numero2; System.out.println("Suma: " + suma);';
      case 'condicionales_if':
        return 'if (edad >= 18) System.out.println("Eres mayor de edad");';
      case 'bucle_for_basico':
        return 'for (int i = 1; i <= 3; i++) System.out.print(i + " ");';
      case 'metodo_simple':
        return 'System.out.println(saludar("Ana"));';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  /// Simula errores de Java comunes
  String _generateJavaError(String userInput) {
    final errors = [
      'Error: cannot find symbol\n  symbol:   variable ${userInput.split(' ').last}\n  location: class Main',
      'Error: \';\' expected\n  ${userInput}\n           ^',
      'Error: incompatible types: String cannot be converted to int\n  ${userInput}\n  ^',
      'Error: method ${userInput.split('(').first} in class Main cannot be applied to given types\n  required: no arguments\n  found: String',
      'Error: variable ${userInput.split(' ').first} might not have been initialized\n  ${userInput}\n  ^',
    ];
    return errors[userInput.length % errors.length];
  }

  /// Verifica la línea de código escrita por el usuario
  void _checkAnswer() {
    final userInput = _codeController.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _showResult = true;
      _javaError = '';
    });

    final correctLine = _correctLine;
    final isCorrect = _isCodeCorrect(userInput, correctLine);

    if (!isCorrect) {
      setState(() {
        _javaError = _generateJavaError(userInput);
      });
    }

    final result = CodeValidationResult(
      isValid: isCorrect,
      score: isCorrect ? 100 : 0,
      messages: [
        isCorrect
            ? '¡Correcto! Has completado la línea de código correctamente.'
            : 'Incorrecto. Revisa la sintaxis y el error de compilación.',
      ],
      passedTests: isCorrect ? widget.exercise.testCases : [],
      failedTests: isCorrect ? [] : widget.exercise.testCases,
      simulatedOutput:
          isCorrect ? widget.exercise.expectedOutput : 'Error de compilación',
    );

    setState(() {
      _lastResult = result;
    });

    if (result.isValid) {
      _showSuccessDialog(result);
    }

    widget.onValidationComplete?.call(result);
  }

  /// Reinicia el playground para permitir otro intento
  void _resetPlayground() {
    setState(() {
      _showResult = false;
      _lastResult = null;
      _javaError = '';
      _codeController.clear();
    });
    _codeFocusNode.requestFocus();
  }

  /// Verifica si el código del usuario es correcto
  bool _isCodeCorrect(String userInput, String correctLine) {
    // Normalizar espacios y comparar
    final normalizedUser = userInput.replaceAll(RegExp(r'\s+'), ' ').trim();
    final normalizedCorrect =
        correctLine.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Verificar si es exactamente igual
    if (normalizedUser == normalizedCorrect) return true;

    // Verificar patrones requeridos
    bool hasAllRequiredPatterns = true;
    for (String pattern in widget.exercise.requiredPatterns) {
      final cleanPattern = pattern.replaceAll('*', '');
      if (!userInput.contains(cleanPattern)) {
        hasAllRequiredPatterns = false;
        break;
      }
    }

    // Verificar patrones prohibidos
    bool hasNoForbiddenPatterns = true;
    for (String pattern in widget.exercise.forbiddenPatterns) {
      final cleanPattern = pattern.replaceAll('*', '');
      if (userInput.contains(cleanPattern)) {
        hasNoForbiddenPatterns = false;
        break;
      }
    }

    // Verificaciones específicas por ejercicio
    switch (widget.exercise.exerciseId) {
      case 'hola_mundo_java':
        return userInput.contains('System.out.println') &&
            userInput.contains('Hola Mundo') &&
            userInput.contains(';');
      case 'variables_basicas':
        return userInput.contains('String nombre') &&
            userInput.contains('System.out.println');
      case 'operaciones_matematicas':
        return userInput.contains('+') &&
            userInput.contains('System.out.println');
      case 'condicionales_if':
        return userInput.contains('if') &&
            userInput.contains('>=') &&
            userInput.contains('System.out.println');
      case 'bucle_for_basico':
        return userInput.contains('for') &&
            userInput.contains('int i') &&
            userInput.contains('System.out.print');
      case 'metodo_simple':
        return userInput.contains('saludar') &&
            userInput.contains('Ana') &&
            userInput.contains('System.out.println');
      default:
        return hasAllRequiredPatterns && hasNoForbiddenPatterns;
    }
  }

  /// Muestra el diálogo de éxito cuando la respuesta es correcta
  void _showSuccessDialog(CodeValidationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber[600]),
                const SizedBox(width: 8),
                const Text('¡Excelente!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntuación: ${result.score}/100'),
                const SizedBox(height: 8),
                const Text('¡Has completado el código correctamente!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onComplete?.call();
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
    );
  }

  /// Muestra una pista
  void _showHint() {
    if (_currentHintIndex < widget.exercise.hints.length) {
      final hint = widget.exercise.hints[_currentHintIndex];

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Pista ${_currentHintIndex + 1}'),
              content: Text(hint),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            ),
      );

      setState(() {
        _currentHintIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (_currentHintIndex < widget.exercise.hints.length)
            IconButton(
              onPressed: _showHint,
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: 'Mostrar pista',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de teoría (si está disponible) - PRIMERO
            if (widget.exercise.theory != null &&
                widget.exercise.theory!.isNotEmpty) ...[
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OverflowUtils.safeRow(
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.purple[700],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: OverflowUtils.safeText(
                              'Teoría del Ejercicio',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Explicación narrativa
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple[25],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OverflowUtils.safeRow(
                              children: [
                                Icon(
                                  Icons.auto_stories,
                                  color: Colors.purple[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: OverflowUtils.safeText(
                                    '📖 Historia del Concepto',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[800],
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.exercise.theory!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Explicación técnica clara
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OverflowUtils.safeRow(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: OverflowUtils.safeText(
                                    '💡 Explicación Técnica',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[800],
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (widget.exercise.concepts.isNotEmpty) ...[
                              Text(
                                '🎯 En este ejercicio aprenderás:',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...widget.exercise.concepts
                                  .map(
                                    (concept) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        bottom: 6,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.purple[600],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              concept,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue[700],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Aplica estos conceptos en el código de abajo para completar el ejercicio.',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Descripción del ejercicio - SEGUNDO
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instrucciones:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.exercise.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),

                    // Información adicional
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Dificultad: ${widget.exercise.difficulty}/5',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        OverflowUtils.safeRow(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.code, size: 16, color: Colors.blue[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: OverflowUtils.safeConceptsList(
                                widget.exercise.concepts,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Salida esperada
            if (widget.exercise.expectedOutput.isNotEmpty) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.output,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Salida esperada:',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Text(
                          widget.exercise.expectedOutput,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Código con línea faltante
            if (widget.exercise.initialCode.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completa el código:',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escribe la línea de código que falta para que el programa funcione correctamente.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Código con numeración de líneas
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            // Header del editor
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.code,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Main.java',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Código con líneas numeradas
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...List.generate(_codeLines.length, (index) {
                                    final line = _codeLines[index];
                                    final lineNumber = index + 1;
                                    final isCompleteLine = line.contains(
                                      'COMPLETAR',
                                    );

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Número de línea
                                          Container(
                                            width: 30,
                                            child: Text(
                                              '$lineNumber',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),

                                          // Línea de código o campo de entrada
                                          Expanded(
                                            child:
                                                isCompleteLine
                                                    ? Container(
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 4,
                                                          ),
                                                      child: TextField(
                                                        controller:
                                                            _codeController,
                                                        focusNode:
                                                            _codeFocusNode,
                                                        enabled: !_showResult,
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'monospace',
                                                          fontSize: 13,
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        decoration: InputDecoration(
                                                          hintText:
                                                              '    // Escribe aquí tu código...',
                                                          hintStyle: TextStyle(
                                                            fontFamily:
                                                                'monospace',
                                                            fontSize: 13,
                                                            color:
                                                                Colors
                                                                    .grey[400],
                                                            fontStyle:
                                                                FontStyle
                                                                    .italic,
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color:
                                                                  Colors
                                                                      .blue[300]!,
                                                            ),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      4,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color:
                                                                          Colors
                                                                              .blue[500]!,
                                                                      width: 2,
                                                                    ),
                                                              ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 8,
                                                              ),
                                                        ),
                                                        onChanged:
                                                            (_) =>
                                                                setState(() {}),
                                                        onSubmitted:
                                                            (_) =>
                                                                _checkAnswer(),
                                                      ),
                                                    )
                                                    : Text(
                                                      line,
                                                      style: const TextStyle(
                                                        fontFamily: 'monospace',
                                                        fontSize: 13,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botones de acción
                      if (!_showResult)
                        // Botón de verificar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _codeController.text.trim().isNotEmpty
                                    ? _checkAnswer
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Compilar y ejecutar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_lastResult != null && !_lastResult!.isValid)
                        // Botón de intentar de nuevo (solo si la respuesta es incorrecta)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _resetPlayground,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.refresh, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Intentar de nuevo',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // Botón de código verificado (respuesta correcta)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Código verificado',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error de Java (si existe)
            if (_javaError.isNotEmpty) ...[
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Error de compilación:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Text(
                          _javaError,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Resultado
            if (_showResult && _lastResult != null) ...[
              Card(
                color: _lastResult!.isValid ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _lastResult!.isValid
                                ? Icons.check_circle
                                : Icons.error,
                            color:
                                _lastResult!.isValid
                                    ? Colors.green[700]
                                    : Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _lastResult!.isValid ? 'Correcto' : 'Incorrecto',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  _lastResult!.isValid
                                      ? Colors.green[700]
                                      : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastResult!.messages.isNotEmpty
                            ? _lastResult!.messages.first
                            : 'Sin mensaje',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Puntuación: ${_lastResult!.score}/100',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

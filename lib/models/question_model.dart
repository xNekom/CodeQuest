class QuestionModel {
  final String questionId;
  final String text;
  final List<String> options; // Siempre 4 opciones
  final int correctAnswerIndex; // 0-3
  final String explanation;
  final List<String> relatedConcepts;
  final String difficultyLevel; // 'Basica', 'Intermedia', 'Avanzada'
  final String type; // 'teoria', 'sintaxis', 'output', 'debug'

  QuestionModel({
    required this.questionId,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.relatedConcepts,
    required this.difficultyLevel,
    required this.type,
  }) : assert(options.length == 4, 'Debe haber exactamente 4 opciones.'),
       assert(correctAnswerIndex >= 0 && correctAnswerIndex < 4, 'El índice de la respuesta correcta debe estar entre 0 y 3.');

  factory QuestionModel.fromJson(Map<String, dynamic> json, String questionId) {
    return QuestionModel(
      questionId: questionId,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
      relatedConcepts: (json['relatedConcepts'] as List<dynamic>).map((e) => e as String).toList(),
      difficultyLevel: json['difficultyLevel'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'relatedConcepts': relatedConcepts,
      'difficultyLevel': difficultyLevel,
      'type': type,
    };
  }
}

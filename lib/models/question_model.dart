import 'package:cloud_firestore/cloud_firestore.dart';

// Representa una pregunta de opción múltiple utilizada en batallas o quizzes.
class QuestionModel {
  final String questionId; // ID único de la pregunta, usualmente el ID del documento de Firestore.
  final String text; // El texto de la pregunta.
  final List<String> options; // Lista de opciones de respuesta (siempre debe haber 4).
  final int correctAnswerIndex; // Índice de la respuesta correcta en la lista `options` (0 a 3).
  final String explanation; // Explicación de por qué la respuesta correcta es correcta.
  final String? originalId; // Campo opcional para mantener el ID original si la pregunta proviene de un JSON con un campo 'id' diferente.
  // Campos 'relatedConcepts', 'difficultyLevel', 'type' no están en el JSON, se omiten.

  // Constructor para crear una instancia de QuestionModel.
  QuestionModel({
    required this.questionId,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.originalId,
  }) : assert(options.length == 4, 'Debe haber exactamente 4 opciones.'),
       assert(correctAnswerIndex >= 0 && correctAnswerIndex < 4, 'El índice de la respuesta correcta debe estar entre 0 y 3.');

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuestionModel.fromJson(data, doc.id);
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json, String questionId) {
    return QuestionModel(
      questionId: questionId, // ID del documento de Firestore
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
      originalId: json['id'] as String?, // Capturar el 'id' original del JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      if (originalId != null) 'id': originalId, // Restaurar el 'id' original si se guarda
    };
  }
}

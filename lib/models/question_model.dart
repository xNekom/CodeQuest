import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String questionId; // ID del documento de Firestore
  final String text;
  final List<String> options; // Siempre 4 opciones
  final int correctAnswerIndex; // 0-3
  final String explanation;
  final String? originalId; // Para mantener el 'id' del JSON original
  // Campos 'relatedConcepts', 'difficultyLevel', 'type' no están en el JSON, se omiten.

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

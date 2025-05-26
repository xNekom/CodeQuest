import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/question_model.dart';
import 'package:codequest/config/app_config.dart';
import 'package:flutter/foundation.dart' show FlutterError;

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuestionModel?> getQuestionById(String questionId) async {
    if (AppConfig.shouldUseFirebase) {
      try {
        DocumentSnapshot doc = await _firestore.collection('questions').doc(questionId).get();
        if (doc.exists) {
          return QuestionModel.fromFirestore(doc);
        }
      } catch (e) {
        // print('Error al obtener pregunta por ID desde Firebase: $e');
      }
      return null;
    } else {
      return _getQuestionByIdFromLocalJson(questionId);
    }
  }

  Future<List<QuestionModel>> getQuestionsByIds(List<String> questionIds) async {
    if (AppConfig.shouldUseFirebase) {
      List<QuestionModel> questions = [];
      try {
        for (String id in questionIds) {
          DocumentSnapshot doc = await _firestore.collection('questions').doc(id).get();
          if (doc.exists) {
            questions.add(QuestionModel.fromFirestore(doc));
          }
        }
      } catch (e) {
        // print('Error al obtener preguntas por IDs desde Firebase: $e');
      }
      return questions;
    } else { // Carga local
      print('[QServ] Loading questions locally for IDs: $questionIds');
      List<QuestionModel> questions = [];
      final allLocalQuestions = await _loadQuestionsFromLocalJson(); // Este método ya tiene logs
      print('[QServ] Total local questions available from _loadQuestionsFromLocalJson: ${allLocalQuestions.length}');
      if (allLocalQuestions.isEmpty && questionIds.isNotEmpty) {
        print('[QServ] Warning: No local questions found in questions.json, but IDs were requested: $questionIds');
      }

      for (String id in questionIds) {
        print('[QServ] Searching for local question with ID: "$id"');
        try {
          // Cuando se cargan desde JSON local, QuestionModel.fromJson(jsonData, idFromJson)
          // establece questionId = idFromJson (que es jsonData['id']).
          // Por lo tanto, comparamos con q.questionId.
          final foundQuestion = allLocalQuestions.firstWhere(
            (q) => q.questionId == id,
          );
          questions.add(foundQuestion);
          print('[QServ] Found local question for ID "$id": ${foundQuestion.text.substring(0,_print_text_length(foundQuestion.text))}...');
        } catch (e) {
          print('[QServ] Local question with ID "$id" NOT FOUND in allLocalQuestions. Error: $e');
        }
      }
      print('[QServ] Returning ${questions.length} local questions for requested IDs: $questionIds');
      return questions;
    }
  }

  Future<List<QuestionModel>> _loadQuestionsFromLocalJson() async {
    try {
      print('[QServ] Attempting to load questions from local JSON: assets/data/questions.json');
      final String jsonString = await rootBundle.loadString('assets/data/questions.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      List<QuestionModel> questions = [];
      for (var data in jsonList) {
          final jsonData = data as Map<String, dynamic>;
          final idFromJson = jsonData['id'] as String? ?? 'unknown_question_${DateTime.now().millisecondsSinceEpoch}';
          // print('[QServ] Parsing local question from JSON with idFromJson: $idFromJson');
          questions.add(QuestionModel.fromJson(jsonData, idFromJson));
      }
      print('[QServ] Successfully loaded ${questions.length} questions from local JSON.');
      return questions;
    } catch (e) {
      print("[QServ] CRITICAL Error loading or decoding local questions from assets/data/questions.json: $e");
      if (e is FlutterError && e.message.contains('Unable to load asset')) {
        // print("[QServ] Asset loading error details: ${e.diagnostics}"); // Puede ser muy verboso
      }
      return [];
    }
  }

  Future<QuestionModel?> _getQuestionByIdFromLocalJson(String questionId) async {
    try {
      final List<QuestionModel> allQuestions = await _loadQuestionsFromLocalJson();
      // Buscar por originalId (si el ID viene del JSON) o questionId (si es un ID generado/de Firestore)
      return allQuestions.firstWhere((q) => q.originalId == questionId || q.questionId == questionId);
    } catch (e) {
      // print("Pregunta local con ID $questionId no encontrada: $e");
      return null;
    }
  }

  // Helper para el log, para no imprimir textos de preguntas muy largos
  int _print_text_length(String text) {
    return text.length > 50 ? 50 : text.length;
  }
}

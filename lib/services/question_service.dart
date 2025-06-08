import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/question_model.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuestionModel?> getQuestionById(String questionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('questions').doc(questionId).get();
      if (doc.exists) {
        return QuestionModel.fromFirestore(doc);
      }
    } catch (e) {
    }
    return null;
  }

  Future<List<QuestionModel>> getQuestionsByIds(List<String> questionIds) async {
    List<QuestionModel> questions = [];
    try {
      for (String id in questionIds) {
        DocumentSnapshot doc = await _firestore.collection('questions').doc(id).get();
        if (doc.exists) {
          questions.add(QuestionModel.fromFirestore(doc));
        }
      }
    } catch (e) {
    }
    return questions;
  }
}

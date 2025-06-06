import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'leaderboard';

  // Obtener todas las entradas del leaderboard ordenadas por puntuación
  Stream<List<LeaderboardEntryModel>> getLeaderboardEntries({int limit = 50}) {
    return _firestore
        .collection(_collectionName)
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaderboardEntryModel.fromJson(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Obtener el ranking de un usuario específico
  Future<int?> getUserRanking(String userId) async {
    try {
      // Obtener todas las entradas ordenadas por puntuación
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('score', descending: true)
          .get();

      // Buscar la posición del usuario
      for (int i = 0; i < snapshot.docs.length; i++) {
        if (snapshot.docs[i].data() is Map<String, dynamic>) {
          final data = snapshot.docs[i].data() as Map<String, dynamic>;
          if (data['userId'] == userId) {
            return i + 1; // Posición basada en 1
          }
        }
      }
      return null; // Usuario no encontrado en el leaderboard
    } catch (e) {
      // debugPrint('Error al obtener ranking del usuario: $e'); // REMOVIDO PARA PRODUCCIÓN
      return null;
    }
  }

  // Actualizar o crear entrada en el leaderboard
  Future<void> updateLeaderboardEntry({
    required String userId,
    required String username,
    required int score,
  }) async {
    try {
      // Buscar si ya existe una entrada para este usuario
      QuerySnapshot existingEntry = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingEntry.docs.isNotEmpty) {
        // Actualizar entrada existente solo si la nueva puntuación es mayor
        final doc = existingEntry.docs.first;
        final currentData = doc.data() as Map<String, dynamic>;
        final currentScore = currentData['score'] as int;

        if (score > currentScore) {
          await doc.reference.update({
            'score': score,
            'username': username, // Actualizar username por si cambió
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Crear nueva entrada
        await _firestore.collection(_collectionName).add({
          'userId': userId,
          'username': username,
          'score': score,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // debugPrint('Error al actualizar entrada del leaderboard: $e'); // REMOVIDO PARA PRODUCCIÓN
      rethrow;
    }
  }

  // Obtener el top N de usuarios
  Future<List<LeaderboardEntryModel>> getTopUsers(int limit) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return LeaderboardEntryModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      // debugPrint('Error al obtener top usuarios: $e'); // REMOVIDO PARA PRODUCCIÓN
      return [];
    }
  }

  // Calcular puntuación basada en datos del usuario
  int calculateUserScore(Map<String, dynamic> userData) {
    int level = userData['level'] ?? 1;
    int experience = userData['experience'] ?? 0;
    int battlesWon = userData['stats']?['battlesWon'] ?? 0;
    int correctAnswers = userData['stats']?['correctAnswers'] ?? 0;
    int completedMissions = userData['completedMissions']?.length ?? 0;

    // Fórmula de puntuación: nivel * 1000 + experiencia + batallas ganadas * 50 + respuestas correctas * 10 + misiones completadas * 200
    return (level * 1000) + experience + (battlesWon * 50) + (correctAnswers * 10) + (completedMissions * 200);
  }

  // Actualizar puntuación de un usuario basada en sus datos actuales
  Future<void> updateUserScore(String userId) async {
    try {
      // Obtener datos del usuario
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final username = userData['username'] ?? 'Usuario';
      final score = calculateUserScore(userData);

      // Actualizar entrada en el leaderboard
      await updateLeaderboardEntry(
        userId: userId,
        username: username,
        score: score,
      );
    } catch (e) {
      // debugPrint('Error al actualizar puntuación del usuario: $e'); // REMOVIDO PARA PRODUCCIÓN
      rethrow;
    }
  }
}
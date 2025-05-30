import 'package:cloud_firestore/cloud_firestore.dart';

// Representa una entrada en la tabla de clasificación (leaderboard).
class LeaderboardEntryModel {
  final String entryId; // ID único de esta entrada en la tabla, usualmente el ID del documento de Firestore.
  final String userId; // ID del usuario al que pertenece esta entrada.
  final String username; // Nombre de usuario para mostrar en la tabla.
  final int score; // Puntuación del usuario.
  final Timestamp lastUpdated; // Fecha y hora de la última actualización de esta entrada.

  // Constructor para una entrada de la tabla de clasificación.
  LeaderboardEntryModel({
    required this.entryId,
    required this.userId,
    required this.username,
    required this.score,
    required this.lastUpdated,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json, String entryId) {
    return LeaderboardEntryModel(
      entryId: entryId,
      userId: json['userId'] as String,
      username: json['username'] as String,
      score: json['score'] as int,
      lastUpdated: json['lastUpdated'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'score': score,
      'lastUpdated': lastUpdated, // O FieldValue.serverTimestamp() si se actualiza al escribir
    };
  }
}

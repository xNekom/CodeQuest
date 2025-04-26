import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntryModel {
  final String entryId; // El ID del documento en Firestore
  final String userId;
  final String username;
  final int score;
  final Timestamp lastUpdated;

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

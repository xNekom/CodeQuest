import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String username;
  final String email;
  String? currentMissionId;
  Map<String, dynamic>? progressInMission; // Ejemplo: {'puzzle1_completed': true, 'current_step': 2}
  Map<String, dynamic>? completedMissions; // Ejemplo: {'mission_id_1': true, 'mission_id_2': true}
  int level;
  int experiencePoints;
  int gameCurrency;
  Map<String, dynamic>? inventory; // Ejemplo: {'item_id_1': 2, 'item_id_2': 1}
  List<String>? unlockedAbilities;
  Map<String, dynamic>? equippedItems; // Ejemplo: {'armor': 'iron_tunic_id', 'weapon': 'basic_sword_id'}
  Map<String, dynamic>? characterStats; // Ejemplo: {'attack': 10, 'defense': 5}
  Map<String, dynamic>? difficultConcepts; // Ejemplo: {'concept_id_1': 3} (contador de fallos)
  Map<String, dynamic>? settings; // Ejemplo: {'volume': 0.8, 'notifications': true}
  Timestamp? lastLogin;
  Timestamp? creationDate;
  String? role; // Añadido para consistencia con el admin panel
  String? skinTone; // Añadido para consistencia con CharacterPixelArt
  String? hairStyle; // Añadido para consistencia con CharacterPixelArt
  String? outfit; // Añadido para consistencia con CharacterPixelArt
  Map<String, dynamic>? stats; // Añadido para consistencia con home_screen


  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.currentMissionId,
    this.progressInMission,
    this.completedMissions,
    this.level = 1,
    this.experiencePoints = 0,
    this.gameCurrency = 0,
    this.inventory,
    this.unlockedAbilities,
    this.equippedItems,
    this.characterStats,
    this.difficultConcepts,
    this.settings,
    this.lastLogin,
    this.creationDate,
    this.role = 'user',
    this.skinTone = 'light',
    this.hairStyle = 'short_brown',
    this.outfit = 'basic_tunic',
    this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String userId) {
    return UserModel(
      userId: userId,
      username: json['username'] as String,
      email: json['email'] as String,
      currentMissionId: json['currentMissionId'] as String?,
      progressInMission: json['progressInMission'] as Map<String, dynamic>?,
      completedMissions: (json['completedMissions'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as bool)) ?? {}, // Asegurar que el valor sea bool
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experiencePoints'] as int? ?? 0,
      gameCurrency: json['gameCurrency'] as int? ?? 0,
      inventory: json['inventory'] as Map<String, dynamic>?,
      unlockedAbilities: (json['unlockedAbilities'] as List<dynamic>?)?.map((e) => e as String).toList(),
      equippedItems: json['equippedItems'] as Map<String, dynamic>?,
      characterStats: json['characterStats'] as Map<String, dynamic>?,
      difficultConcepts: json['difficultConcepts'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      lastLogin: json['lastLogin'] as Timestamp?,
      creationDate: json['creationDate'] as Timestamp?,
      role: json['role'] as String? ?? 'user',
      skinTone: json['skinTone'] as String? ?? 'light',
      hairStyle: json['hairStyle'] as String? ?? 'short_brown',
      outfit: json['outfit'] as String? ?? 'basic_tunic',
      stats: json['stats'] as Map<String, dynamic>? ?? {'questionsAnswered': 0, 'correctAnswers': 0, 'battlesWon': 0, 'battlesLost': 0},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'currentMissionId': currentMissionId,
      'progressInMission': progressInMission,
      'completedMissions': completedMissions,
      'level': level,
      'experiencePoints': experiencePoints,
      'gameCurrency': gameCurrency,
      'inventory': inventory,
      'unlockedAbilities': unlockedAbilities,
      'equippedItems': equippedItems,
      'characterStats': characterStats,
      'difficultConcepts': difficultConcepts,
      'settings': settings,
      'lastLogin': lastLogin ?? FieldValue.serverTimestamp(),
      'creationDate': creationDate ?? FieldValue.serverTimestamp(),
      'role': role,
      'skinTone': skinTone,
      'hairStyle': hairStyle,
      'outfit': outfit,
      'stats': stats,
    };
  }
}

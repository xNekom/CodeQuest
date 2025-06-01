import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Campos básicos requeridos
  final String userId;
  final String username;
  final String email;

  // Campos de progreso del juego
  String? currentMissionId;
  List<String>? completedMissions; // Array de strings según Firebase
  int level;
  int experience; // Campo principal usado en el código
  int experiencePoints; // Campo legacy mantenido por compatibilidad
  int coins; // Campo principal usado en el código
  int gameCurrency; // Campo legacy mantenido por compatibilidad

  // Campos de selección y personalización del personaje
  bool? characterSelected; // Si el personaje ha sido seleccionado
  String? characterName; // Nombre del personaje
  String? adminRole; // Para permisos de admin (user/admin)
  int characterAssetIndex; // Índice del asset del personaje (0-8)
  String? programmingRole; // Rol de programación del personaje

  // Campos de progreso y estadísticas
  Map<String, dynamic>?
  progressInMission; // Para progreso detallado de misiones
  Map<String, dynamic>? inventory; // Para sistema de inventario
  List<String>? unlockedAbilities; // Para habilidades desbloqueadas
  Map<String, dynamic>? equippedItems; // Para equipamiento
  Map<String, dynamic>?
  characterStats; // Para stats de combate (battlesWon, battlesLost, etc.)
  Map<String, dynamic>?
  stats; // Para estadísticas generales (questionsAnswered, correctAnswers)
  Map<String, dynamic>?
  difficultConcepts; // Para sistema de aprendizaje adaptivo
  Map<String, dynamic>? settings; // Para configuraciones del usuario

  // Campos de auditoría
  Timestamp? lastLogin;
  Timestamp? creationDate;
  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.currentMissionId,
    this.completedMissions,
    this.level = 1,
    this.experience = 0,
    this.experiencePoints = 0,
    this.coins = 0,
    this.gameCurrency = 0,
    this.characterSelected,
    this.characterName,
    this.adminRole = 'user',
    this.characterAssetIndex = 0,
    this.programmingRole = 'Desarrollador Full Stack',
    this.progressInMission,
    this.inventory,
    this.unlockedAbilities,
    this.equippedItems,
    this.characterStats,
    this.stats,
    this.difficultConcepts,
    this.settings,
    this.lastLogin,
    this.creationDate,
  });
  factory UserModel.fromJson(Map<String, dynamic> json, String userId) {
    return UserModel(
      userId: userId,
      username: json['username'] as String,
      email: json['email'] as String,
      currentMissionId: json['currentMissionId'] as String?,
      completedMissions:
          (json['completedMissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      experiencePoints: json['experiencePoints'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      gameCurrency: json['gameCurrency'] as int? ?? 0,
      characterSelected: json['characterSelected'] as bool?,
      characterName: json['characterName'] as String?,
      adminRole:
          json['adminRole'] as String? ?? json['role'] as String? ?? 'user',
      characterAssetIndex: json['characterAssetIndex'] as int? ?? 0,
      programmingRole:
          json['programmingRole'] as String? ?? 'Desarrollador Full Stack',
      progressInMission: json['progressInMission'] as Map<String, dynamic>?,
      inventory: json['inventory'] as Map<String, dynamic>?,
      unlockedAbilities:
          (json['unlockedAbilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      equippedItems: json['equippedItems'] as Map<String, dynamic>?,
      characterStats: json['characterStats'] as Map<String, dynamic>?,
      stats:
          json['stats'] as Map<String, dynamic>? ??
          {
            'questionsAnswered': 0,
            'correctAnswers': 0,
            'battlesWon': 0,
            'battlesLost': 0,
          },
      difficultConcepts: json['difficultConcepts'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      lastLogin: json['lastLogin'] as Timestamp?,
      creationDate: json['creationDate'] as Timestamp?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'currentMissionId': currentMissionId,
      'completedMissions': completedMissions,
      'level': level,
      'experience': experience,
      'experiencePoints': experiencePoints,
      'coins': coins,
      'gameCurrency': gameCurrency,

      'characterSelected': characterSelected,
      'characterName': characterName,
      'adminRole': adminRole,
      'characterAssetIndex': characterAssetIndex,
      'programmingRole': programmingRole,
      'progressInMission': progressInMission,
      'inventory': inventory,
      'unlockedAbilities': unlockedAbilities,
      'equippedItems': equippedItems,
      'characterStats': characterStats,
      'stats': stats,
      'difficultConcepts': difficultConcepts,
      'settings': settings,
      'lastLogin': lastLogin ?? FieldValue.serverTimestamp(),
      'creationDate': creationDate ?? FieldValue.serverTimestamp(),
    };
  }
}

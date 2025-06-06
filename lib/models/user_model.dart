import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo que representa los datos de un usuario en la aplicación.
class UserModel {
  // --- Campos básicos de identificación del usuario ---
  final String userId; // ID único del usuario (generalmente de Firebase Auth).
  final String username; // Nombre de usuario elegido.
  final String email; // Correo electrónico del usuario.

  // --- Campos de progreso en el juego ---
  String? currentMissionId; // ID de la misión actual en la que está el usuario.
  List<String>? completedMissions; // Lista de IDs de misiones completadas.
  int level; // Nivel actual del jugador.
  int experience; // Puntos de experiencia actuales (campo principal).
  int experiencePoints; // Puntos de experiencia (campo legacy, mantener por compatibilidad si es necesario).
  int coins; // Monedas del juego actuales (campo principal).
  int gameCurrency; // Monedas del juego (campo legacy, mantener por compatibilidad si es necesario).

  // --- Campos de personalización del personaje y roles ---
  bool? characterSelected; // Indica si el usuario ya ha seleccionado su personaje inicial.
  String? characterName; // Nombre elegido para el personaje del juego.
  String? role; // Rol del usuario en el sistema (ej. 'user', 'admin').
  int characterAssetIndex; // Índice del asset visual para el personaje (rango 0-8).
  String? programmingRole; // Rol de programación elegido por el usuario (ej. 'Desarrollador Full Stack').

  // --- Campos de progreso detallado, inventario y estadísticas ---
  Map<String, dynamic>? progressInMission; // Almacena el progreso detallado dentro de misiones específicas (ej. objetivos completados).
  Map<String, dynamic>? inventory; // Representa el inventario del jugador (ej. ítems y sus cantidades).
  List<String>? unlockedAbilities; // Lista de IDs de habilidades desbloqueadas por el jugador.
  Map<String, dynamic>? equippedItems; // Mapa de ítems equipados por el personaje (ej. 'arma': 'id_espada').

  Map<String, dynamic>? stats; // Estadísticas generales del jugador (ej. preguntas respondidas, respuestas correctas).
  Map<String, dynamic>? difficultConcepts; // Registra conceptos con los que el usuario tiene dificultad, para aprendizaje adaptativo.
  Map<String, dynamic>? settings; // Configuraciones personalizadas del usuario (ej. volumen, notificaciones).

  // --- Campos de auditoría y timestamps ---
  Timestamp? lastLogin; // Fecha y hora del último inicio de sesión.
  Timestamp? creationDate; // Fecha y hora de creación de la cuenta.

  // Getter para verificar fácilmente si el usuario tiene rol de administrador.
  bool get isAdmin => role == 'admin';
  // Constructor para crear una instancia de UserModel.
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
    this.role = 'user',
    this.characterAssetIndex = 0,
    this.programmingRole = 'Desarrollador Full Stack',
    this.progressInMission,
    this.inventory,
    this.unlockedAbilities,
    this.equippedItems,

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
      role: json['role'] as String? ?? json['adminRole'] as String? ?? 'user',
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
      'role': role,
      'characterAssetIndex': characterAssetIndex,
      'programmingRole': programmingRole,
      'progressInMission': progressInMission,
      'inventory': inventory,
      'unlockedAbilities': unlockedAbilities,
      'equippedItems': equippedItems,

      'stats': stats,
      'difficultConcepts': difficultConcepts,
      'settings': settings,
      'lastLogin': lastLogin ?? FieldValue.serverTimestamp(),
      'creationDate': creationDate ?? FieldValue.serverTimestamp(),
    };
  }
}

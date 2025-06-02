import 'package:cloud_firestore/cloud_firestore.dart';

// Representa un logro que el usuario puede desbloquear en el juego.
class Achievement {
  final String id; // Identificador único del logro.
  final String name; // Nombre visible del logro.
  final String description; // Descripción detallada de cómo obtener el logro.
  final String iconUrl; // URL al icono del logro
  final List<String> requiredMissionIds; // IDs de las misiones necesarias para desbloquear
  final String rewardId; // ID de la recompensa otorgada
  final Timestamp? unlockedDate; // Fecha y hora en que el usuario desbloqueó el logro. Null si aún no se ha desbloqueado.
  
  // Nuevos campos requeridos
  final String category; // Categoría del logro
  final int points; // Puntos que otorga el logro
  final Map<String, dynamic> conditions; // Condiciones adicionales o específicas para desbloquear el logro (ej. completar X misiones de tipo Y).
  
  // Nuevos campos para logros basados en enemigos
  final String? requiredEnemyId; // ID del enemigo específico que debe ser derrotado
  final int? requiredEnemyDefeats; // Número de veces que debe ser derrotado
  final String? achievementType; // Tipo de logro, por ejemplo, 'mission' (basado en misiones) o 'enemy' (basado en derrotar enemigos).

  // Constructor para crear una instancia de Achievement.
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.requiredMissionIds,
    required this.rewardId,
    required this.category,
    required this.points,
    required this.conditions,
    this.unlockedDate,
    this.requiredEnemyId,
    this.requiredEnemyDefeats,
    this.achievementType = 'mission',
  });  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'requiredMissionIds': requiredMissionIds,
      'rewardId': rewardId,
      'category': category,
      'points': points,
      'conditions': conditions,
      'unlockedDate': unlockedDate?.toDate(),
      'requiredEnemyId': requiredEnemyId,
      'requiredEnemyDefeats': requiredEnemyDefeats,
      'achievementType': achievementType,
    };
  }
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] is String ? map['id'] as String : throw ArgumentError('Invalid or missing "id"'),
      name: map['name'],
      description: map['description'],
      iconUrl: map['iconUrl'],
      requiredMissionIds: map['requiredMissionIds'] is List
          ? List<String>.from(map['requiredMissionIds'])
          : [],
      rewardId: map['rewardId'],
      category: map['category'] ?? 'general',
      points: map['points'] ?? 0,
      conditions: map['conditions'] != null 
          ? Map<String, dynamic>.from(map['conditions'])
          : {},
      unlockedDate: map['unlockedDate'] as Timestamp?,
      requiredEnemyId: map['requiredEnemyId'] as String?,
      requiredEnemyDefeats: map['requiredEnemyDefeats'] as int?,
      achievementType: map['achievementType'] as String? ?? 'mission',
    );
  }
}

// Representa una recompensa que el jugador puede obtener.
class Reward {
  final String id; // ID único de la recompensa.
  final String name; // Nombre de la recompensa.
  final String description; // Descripción de la recompensa.

  final String type; // Tipo de recompensa (ej. 'points', 'item', 'badge'). Se usa String para flexibilidad con Firestore.
  final int value; // Valor numérico de la recompensa (ej. cantidad de puntos, ID del ítem si type es 'item').
  final Map<String, dynamic> conditions; // Condiciones adicionales para recibir la recompensa.

  // Constructor para crear una instancia de Reward.
  Reward({
    required this.id,
    required this.name,
    required this.description,

    required this.type,
    required this.value,
    this.conditions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,

      'type': type,
      'value': value,
      'conditions': conditions,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',

      type: map['type'] ?? 'points',
      value: map['value'] ?? 0,
      conditions: Map<String, dynamic>.from(map['conditions'] ?? {}),
    );
  }
}

// Mantener enum para referencia pero usar String en la práctica
enum RewardType {
  points, // Puntos de experiencia o de juego
  item,   // Un item específico del juego
  badge,  // Una insignia o título
  coins,  // Monedas del juego
  experience, // Experiencia
}

// Helper para convertir string a enum si es necesario
RewardType stringToRewardType(String type) {
  switch (type.toLowerCase()) {
    case 'points':
      return RewardType.points;
    case 'item':
      return RewardType.item;
    case 'badge':
      return RewardType.badge;
    case 'coins':
      return RewardType.coins;
    case 'experience':
      return RewardType.experience;
    default:
      return RewardType.points;
  }
}

String rewardTypeToString(RewardType type) {
  switch (type) {
    case RewardType.points:
      return 'points';
    case RewardType.item:
      return 'item';
    case RewardType.badge:
      return 'badge';
    case RewardType.coins:
      return 'coins';
    case RewardType.experience:
      return 'experience';
  }
}

// Alias para compatibilidad con mission_model.dart
typedef RewardModel = Reward;

// Factory methods para RewardModel
extension RewardModelExtension on Reward {
  static Reward fromJson(Map<String, dynamic> json) {
    return Reward.fromMap(json);
  }
  
  Map<String, dynamic> toJson() {
    return toMap();
  }
}

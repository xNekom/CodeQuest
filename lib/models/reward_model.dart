class Reward {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String type; // Solo String, no RewardType
  final int value;
  final Map<String, dynamic> conditions;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.value,
    this.conditions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
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
      iconUrl: map['iconUrl'] ?? '',
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

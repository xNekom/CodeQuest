class Reward {
  final String id;
  final String name;
  final String description;
  final String iconUrl; // URL al icono visual de la recompensa
  final RewardType type;
  final int value; // Por ejemplo, cantidad de puntos, ID de un item, etc.

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'type': type.toString(),
      'value': value,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconUrl: map['iconUrl'],
      type: RewardType.values.firstWhere((e) => e.toString() == map['type']),
      value: map['value'],
    );
  }
}

enum RewardType {
  points, // Puntos de experiencia o de juego
  item,   // Un item específico del juego
  badge,  // Una insignia o título
}

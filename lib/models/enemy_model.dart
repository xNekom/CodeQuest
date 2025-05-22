class EnemyModel {
  final String enemyId;
  final String name;
  final String description;
  final String? visualAssetUrl;
  final Map<String, dynamic> stats; // Ejemplo: {'health': 100, 'attack': 10, 'defense': 5}
  final List<String> questionPool; // IDs de las preguntas
  final Map<String, dynamic>? reward; // Ejemplo: {'xp': 50, 'currency': 10, 'itemId': 'item_id_common'}
  final String type; // 'fantastico', 'programacion'

  EnemyModel({
    required this.enemyId,
    required this.name,
    required this.description,
    this.visualAssetUrl,
    required this.stats,
    required this.questionPool,
    this.reward,
    required this.type,
  });

  factory EnemyModel.fromJson(Map<String, dynamic> json, String enemyId) {
    return EnemyModel(
      enemyId: enemyId,
      name: json['name'] as String,
      description: json['description'] as String,
      visualAssetUrl: json['visualAssetUrl'] as String?,
      stats: json['stats'] as Map<String, dynamic>,
      questionPool: (json['questionPool'] as List<dynamic>).map((e) => e as String).toList(),
      reward: json['reward'] as Map<String, dynamic>?,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'visualAssetUrl': visualAssetUrl,
      'stats': stats,
      'questionPool': questionPool,
      'reward': reward,
      'type': type,
    };
  }
}

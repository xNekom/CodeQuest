class EnemyModel {
  final String enemyId; // Firestore document ID
  final String name;
  final String? description;
  final String? assetPath; // Path to the enemy's image asset (opcional)
  final List<Map<String, dynamic>>? lootTable; // Loot table
  final List<Map<String, dynamic>>? drops; // Potential item drops
  final Map<String, String>? dialogue; // Encounter, victory, defeat dialogue

  EnemyModel({
    required this.enemyId,
    required this.name,
    this.description,
    this.assetPath,
    this.lootTable,
    this.drops,
    this.dialogue,
  });

  factory EnemyModel.fromJson(Map<String, dynamic> json, String documentId) {
    // Basic validation for required fields from your sample JSON
    if (json['name'] == null) {
      throw ArgumentError('Missing required field: name is required for enemy.');
    }

    return EnemyModel(
      enemyId: documentId,
      name: json['name'] as String,
      description: json['description'] as String?,
      assetPath: json['assetPath'] as String?,
      lootTable: (json['lootTable'] as List<dynamic>?)
          ?.map((loot) => loot as Map<String, dynamic>)
          .toList(),
      drops: (json['drops'] as List<dynamic>?)
          ?.map((drop) => drop as Map<String, dynamic>)
          .toList(),
      dialogue: json['dialogue'] != null 
          ? (json['dialogue'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value.toString())
            )
          : null,
    );
  }

  // Constructor alternativo para parsear desde JSON local (donde el ID está en el campo 'id')
  factory EnemyModel.fromLocalJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['name'] == null) {
      throw ArgumentError('Missing required fields: id and name are required for enemy.');
    }

    return EnemyModel(
      enemyId: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      assetPath: json['assetPath'] as String?,
      lootTable: (json['lootTable'] as List<dynamic>?)
          ?.map((loot) => loot as Map<String, dynamic>)
          .toList(),
      drops: (json['drops'] as List<dynamic>?)
          ?.map((drop) => drop as Map<String, dynamic>)
          .toList(),
      dialogue: json['dialogue'] != null 
          ? (json['dialogue'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value.toString())
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (assetPath != null) 'assetPath': assetPath,
      if (lootTable != null) 'lootTable': lootTable,
      if (drops != null) 'drops': drops,
      if (dialogue != null) 'dialogue': dialogue,
    };
  }
}
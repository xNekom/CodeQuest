class EnemyModel {
  final String enemyId; // Firestore document ID
  final String name;
  final String? description;
  final String assetPath; // Path to the enemy's image asset
  final Map<String, dynamic>? stats; // e.g., health, attack, defense
  final List<Map<String, dynamic>>? abilities; // List of abilities
  final Map<String, dynamic>? resistances;
  final Map<String, dynamic>? weaknesses;
  final List<Map<String, dynamic>>? drops; // Potential item drops
  final Map<String, String>? dialogue; // Encounter, victory, defeat dialogue

  EnemyModel({
    required this.enemyId,
    required this.name,
    this.description,
    required this.assetPath,
    this.stats,
    this.abilities,
    this.resistances,
    this.weaknesses,
    this.drops,
    this.dialogue,
  });

  factory EnemyModel.fromJson(Map<String, dynamic> json, String documentId) {
    // Basic validation for required fields from your sample JSON
    if (json['name'] == null || json['assetPath'] == null) {
      throw ArgumentError('Missing required fields: name and assetPath are required for enemy.');
    }

    return EnemyModel(
      enemyId: documentId,
      name: json['name'] as String,
      description: json['description'] as String?,
      assetPath: json['assetPath'] as String,
      stats: json['stats'] as Map<String, dynamic>?,
      abilities: (json['abilities'] as List<dynamic>?)
          ?.map((ability) => ability as Map<String, dynamic>)
          .toList(),
      resistances: json['resistances'] as Map<String, dynamic>?,
      weaknesses: json['weaknesses'] as Map<String, dynamic>?,
      drops: (json['drops'] as List<dynamic>?)
          ?.map((drop) => drop as Map<String, dynamic>)
          .toList(),
      dialogue: (json['dialogue'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // enemyId is typically the document ID, so not always included in Firestore data body
      'name': name,
      if (description != null) 'description': description,
      'assetPath': assetPath,
      if (stats != null) 'stats': stats,
      if (abilities != null) 'abilities': abilities,
      if (resistances != null) 'resistances': resistances,
      if (weaknesses != null) 'weaknesses': weaknesses,
      if (drops != null) 'drops': drops,
      if (dialogue != null) 'dialogue': dialogue,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class EnemyModel {
  final String enemyId; // ID del documento de Firestore
  final String name;
  final int level;
  final int health;
  final int attack;
  final int defense;
  final int speed;
  final List<String> abilities;
  final List<LootItem> lootTable;
  final EnemyDialogue dialogue;
  final String? originalId; // Para mantener el 'id' del JSON original
  // Se omite 'description' y 'visualAssetUrl' ya que no están en el JSON proporcionado.
  // Se omite 'questionPool' y 'type' por la misma razón.
  // 'stats' se desglosa en level, health, attack, defense, speed.
  // 'reward' se maneja a través de 'lootTable'.

  EnemyModel({
    required this.enemyId,
    required this.name,
    required this.level,
    required this.health,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.abilities,
    required this.lootTable,
    required this.dialogue,
    this.originalId,
  });

  factory EnemyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EnemyModel.fromJson(data, doc.id);
  }

  factory EnemyModel.fromJson(Map<String, dynamic> json, String enemyId) {
    var abilitiesData = json['abilities'] as List<dynamic>? ?? [];
    List<String> abilitiesList = abilitiesData.map((a) => a as String).toList();

    var lootTableData = json['lootTable'] as List<dynamic>? ?? [];
    List<LootItem> lootList = lootTableData
        .map((l) => LootItem.fromJson(l as Map<String, dynamic>))
        .toList();

    return EnemyModel(
      enemyId: enemyId, // ID del documento de Firestore
      name: json['name'] as String,
      level: json['level'] as int,
      health: json['health'] as int,
      attack: json['attack'] as int,
      defense: json['defense'] as int,
      speed: json['speed'] as int,
      abilities: abilitiesList,
      lootTable: lootList,
      dialogue: EnemyDialogue.fromJson(json['dialogue'] as Map<String, dynamic>),
      originalId: json['id'] as String?, // Capturar el 'id' original del JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'health': health,
      'attack': attack,
      'defense': defense,
      'speed': speed,
      'abilities': abilities,
      'lootTable': lootTable.map((l) => l.toJson()).toList(),
      'dialogue': dialogue.toJson(),
      if (originalId != null) 'id': originalId, // Restaurar el 'id' original si se guarda
    };
  }
}

class LootItem {
  final String itemId;
  final double dropChance;

  LootItem({required this.itemId, required this.dropChance});

  factory LootItem.fromJson(Map<String, dynamic> json) {
    return LootItem(
      itemId: json['itemId'] as String,
      dropChance: (json['dropChance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'dropChance': dropChance,
    };
  }
}

class EnemyDialogue {
  final String encounter;
  final String victory;
  final String defeat;

  EnemyDialogue({
    required this.encounter,
    required this.victory,
    required this.defeat,
  });

  factory EnemyDialogue.fromJson(Map<String, dynamic> json) {
    return EnemyDialogue(
      encounter: json['encounter'] as String,
      victory: json['victory'] as String,
      defeat: json['defeat'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encounter': encounter,
      'victory': victory,
      'defeat': defeat,
    };
  }
}

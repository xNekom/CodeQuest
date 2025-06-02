import 'package:cloud_firestore/cloud_firestore.dart';
import 'battle_config_model.dart';
import 'requirements_model.dart';
import 'reward_model.dart';
import 'story_page_model.dart';

class MissionModel {
  final String missionId;
  final String name; // Renamed from title
  final String description;
  final String zone;
  final int levelRequired;
  final String status; // e.g., 'disponible', 'bloqueada', 'completada'
  // final String? prerequisiteMissionId; // Removed, handled by requirements
  final RequirementsModel? requirements;
  final List<Objective> objectives;
  final Reward rewards;
  final bool isRepeatable;
  final String? theory; // Theory content for theory missions
  final String? technicalExplanation; // Technical explanation without narrative
  final List<String>? examples; // Code examples
  final List<StoryPageModel>? storyPages; // Story content
  final BattleConfigModel? battleConfig;
  final String? type; // 'teoria', 'batalla', etc.
  final int? order; // For ordering missions
  final List<String>? unlocks; // Mission IDs that this mission unlocks
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MissionModel({
    required this.missionId,
    required this.name,
    required this.description,
    required this.zone,
    required this.levelRequired,
    required this.status,
    this.requirements,
    required this.objectives,
    required this.rewards,
    required this.isRepeatable,
    this.theory,
    this.technicalExplanation,
    this.examples,
    this.storyPages,
    this.battleConfig,
    this.type,
    this.order,
    this.unlocks,
    this.createdAt,
    this.updatedAt,
  });

  factory MissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MissionModel.fromJson(data, doc.id);
  }

  factory MissionModel.fromJson(Map<String, dynamic> json, String missionId) {
    // Parse objectives
    var objectivesData = json['objectives'] as List<dynamic>? ?? [];
    List<Objective> objectivesList =
        objectivesData
            .map((objData) {
              try {
                return Objective.fromJson(objData);
              } catch (e) {
                // print('[MissionModel] Invalid objective data type for mission $missionId: $objData');
                return null;
              }
            })
            .where((obj) => obj != null)
            .cast<Objective>()
            .toList();

    // Parse examples
    List<String>? examplesList;
    if (json['examples'] != null) {
      if (json['examples'] is List) {
        examplesList = List<String>.from(json['examples']);
      } else if (json['examples'] is String) {
        examplesList = [json['examples'] as String];
      }
    }

    // Parse unlocks
    List<String>? unlocksList;
    if (json['unlocks'] != null && json['unlocks'] is List) {
      unlocksList = List<String>.from(json['unlocks']);
    }

    // Parse story pages
    List<StoryPageModel>? storyPagesList;
    if (json['storyPages'] != null && json['storyPages'] is List) {
      storyPagesList =
          (json['storyPages'] as List)
              .map((pageData) => StoryPageModel.fromJson(pageData))
              .toList();
    }

    return MissionModel(
      missionId: missionId,
      name:
          json['name'] as String? ??
          json['title'] as String? ??
          'Misión sin nombre',
      description: json['description'] as String? ?? 'Sin descripción',
      zone: json['zone'] as String? ?? 'Zona desconocida',
      levelRequired: json['levelRequired'] as int? ?? 1,
      status: json['status'] as String? ?? 'disponible',
      requirements:
          json['requirements'] != null
              ? RequirementsModel.fromJson(json['requirements'])
              : null,
      objectives: objectivesList,
      rewards: Reward.fromMap(json['rewards'] ?? {}),
      isRepeatable: json['isRepeatable'] as bool? ?? false,
      theory: json['theory'] as String?,
      technicalExplanation: json['technicalExplanation'] as String?,
      examples: examplesList,
      storyPages: storyPagesList,
      battleConfig:
          json['battleConfig'] != null &&
                  json['battleConfig'] is Map<String, dynamic>
              ? BattleConfigModel.fromJson(
                json['battleConfig'] as Map<String, dynamic>,
              )
              : null,
      type: json['type'] as String?,
      order: json['order'] as int?,
      unlocks: unlocksList,
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'missionId': missionId,
      'name': name,
      'description': description,
      'zone': zone,
      'levelRequired': levelRequired,
      'status': status,
      if (requirements != null) 'requirements': requirements!.toJson(),
      'objectives': objectives.map((obj) => obj.toJson()).toList(),
      'rewards': rewards.toMap(),
      'isRepeatable': isRepeatable,
      if (theory != null) 'theory': theory,
      if (technicalExplanation != null) 'technicalExplanation': technicalExplanation,
      if (examples != null) 'examples': examples,
      if (storyPages != null)
        'storyPages': storyPages!.map((page) => page.toJson()).toList(),
      if (battleConfig != null) 'battleConfig': battleConfig!.toJson(),
      if (type != null) 'type': type,
      if (order != null) 'order': order,
      if (unlocks != null) 'unlocks': unlocks,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}

class Objective {
  final String type; // e.g., 'questions', 'batalla', 'collect_items'
  final String description;
  final int target; // Number of questions to answer, enemies to defeat, etc.
  final List<String> questionIds; // For question-based objectives
  final int? timeLimitSeconds;
  final String? itemId; // For item collection objectives
  final int? quantity; // For item collection objectives
  final String? enemyId; // For battle objectives
  final int? targetKillCount; // For battle objectives
  final String? location; // For location-based objectives
  final String? collectionSource; // Where to collect items
  final String? collectionSourceDescription;
  final BattleConfigModel? battleConfig;

  Objective({
    required this.type,
    required this.description,
    required this.target,
    this.questionIds = const [],
    this.timeLimitSeconds,
    this.itemId,
    this.quantity,
    this.enemyId,
    this.targetKillCount,
    this.location,
    this.collectionSource,
    this.collectionSourceDescription,
    this.battleConfig,
  });

  factory Objective.fromJson(Map<String, dynamic> json) {
    // Ensure questionIds is always a List<String>, never null
    List<String> questionIdsList = [];
    if (json['questionIds'] != null && json['questionIds'] is List) {
      questionIdsList = List<String>.from(json['questionIds']);
    }

    return Objective(
      type: json['type'] as String? ?? 'unknown',
      description: json['description'] as String? ?? 'No description',
      target: json['target'] as int? ?? 1,
      questionIds: questionIdsList,
      timeLimitSeconds: json['timeLimitSeconds'] as int?,
      itemId: json['itemId'] as String?,
      quantity: json['quantity'] as int?,
      enemyId: json['enemyId'] as String?,
      targetKillCount: json['targetKillCount'] as int?,
      location: json['location'] as String?,
      collectionSource: json['collectionSource'] as String?,
      collectionSourceDescription:
          json['collectionSourceDescription'] as String?,
      battleConfig:
          json['battleConfig'] != null &&
                  json['battleConfig'] is Map<String, dynamic>
              ? BattleConfigModel.fromJson(
                json['battleConfig'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'target': target,
      if (questionIds.isNotEmpty) 'questionIds': questionIds,
      if (timeLimitSeconds != null) 'timeLimitSeconds': timeLimitSeconds,
      if (itemId != null) 'itemId': itemId,
      if (quantity != null) 'quantity': quantity,
      if (enemyId != null) 'enemyId': enemyId,
      if (targetKillCount != null) 'targetKillCount': targetKillCount,
      if (location != null) 'location': location,
      if (collectionSource != null) 'collectionSource': collectionSource,
      if (collectionSourceDescription != null)
        'collectionSourceDescription': collectionSourceDescription,
      if (battleConfig != null) 'battleConfig': battleConfig!.toJson(),
    };
  }
}

// filepath: c:/Users/Pedro/Documents/GitHub/CodeQuest/lib/models/mission_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'story_page_model.dart';
import 'battle_config_model.dart';
import 'requirements_model.dart';

class MissionModel {
  final String missionId;
  final String name; // Renamed from title
  final String description;
  final String zone;
  final int levelRequired; // Kept for quick access, also in requirements
  String status; // \'disponible\', \'bloqueada\', \'en_progreso\', \'completada\'
  // final String? prerequisiteMissionId; // Removed, handled by requirements
  final bool isRepeatable;
  final List<Objective> objectives;
  final Rewards rewards;
  final Dialogue? dialogue;
  final StoryContent? storyContent;
  final String? originalId; // Para mantener el ID del JSON original si es necesario
  final String? type; // e.g., "exploracion"
  final List<StoryPageModel>? storyPages;
  final BattleConfigModel? battleConfig;
  final RequirementsModel? requirements;

  MissionModel({
    required this.missionId,
    required this.name, // Updated
    required this.description,
    required this.zone,
    required this.levelRequired,
    required this.status,
    // this.prerequisiteMissionId, // Removed
    required this.isRepeatable,
    required this.objectives,
    required this.rewards,
    this.dialogue,
    this.storyContent,
    this.originalId,
    this.type,
    this.storyPages,
    this.battleConfig,
    this.requirements,
  });

  factory MissionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MissionModel.fromJson(data, doc.id);
  }

  factory MissionModel.fromJson(Map<String, dynamic> json, String missionId) {
    try {
      var objectivesData = json['objectives'] as List<dynamic>? ?? [];
      List<Objective> objectivesList = objectivesData
          .map((objData) {
            try {
              if (objData is Map<String, dynamic>) {
                return Objective.fromJson(objData);
              }
              // print('[MissionModel] Invalid objective data type for mission $missionId: $objData');
              return null;
            } catch (e) {
              // print('[MissionModel] Failed to parse an objective for mission $missionId: $e. Data: $objData');
              return null;
            }
          })
          .whereType<Objective>() 
          .toList();

      var rewardsData = json['rewards'] as Map<String, dynamic>?;
      Rewards rewardsInstance;
      if (rewardsData != null) {
        try {
          rewardsInstance = Rewards.fromJson(rewardsData);
        } catch (e) {
          // print('[MissionModel] Failed to parse rewards for mission $missionId: $e. Data: $rewardsData');
          rewardsInstance = Rewards.fromJson({}); 
        }
      } else {
        rewardsInstance = Rewards.fromJson({}); 
      }
      
      List<StoryPageModel>? storyPagesList;
      if (json['storyPages'] is List<dynamic>) {
        storyPagesList = (json['storyPages'] as List<dynamic>)
            .map((pageJson) {
                try {
                  if (pageJson is Map<String, dynamic>) {
                    return StoryPageModel.fromJson(pageJson);
                  }
                  // print('[MissionModel] Invalid story page data type for mission $missionId: $pageJson');
                  return null;
                } catch(e) {
                    // print('[MissionModel] Failed to parse a story page for mission $missionId: $e. Data: $pageJson');
                    return null;
                }
            })
            .whereType<StoryPageModel>()
            .toList();
        if (storyPagesList.isEmpty) storyPagesList = null; 
      }


      return MissionModel(
        missionId: missionId,
        name: json['name'] as String? ?? json['title'] as String? ?? 'Misión sin nombre',
        description: json['description'] as String? ?? 'Sin descripción.',
        zone: json['zone'] as String? ?? 'Zona Desconocida',
        levelRequired: (json['levelRequired'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'bloqueada',
        isRepeatable: json['isRepeatable'] as bool? ?? false,
        objectives: objectivesList,
        rewards: rewardsInstance,
        
        dialogue: json['dialogue'] != null && json['dialogue'] is Map<String, dynamic>
            ? Dialogue.fromJson(json['dialogue'] as Map<String, dynamic>)
            : null,
        storyContent: json['storyContent'] != null && json['storyContent'] is Map<String, dynamic>
            ? StoryContent.fromJson(json['storyContent'] as Map<String, dynamic>)
            : null,
        originalId: json['id'] as String?,
        type: json['type'] as String?,
        storyPages: storyPagesList,
            
        battleConfig: json['battleConfig'] != null && json['battleConfig'] is Map<String, dynamic>
            ? BattleConfigModel.fromJson(json['battleConfig'] as Map<String, dynamic>)
            : null,
            
        requirements: json['requirements'] != null && json['requirements'] is Map<String, dynamic>
            ? RequirementsModel.fromJson(json['requirements'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      // print('[MissionModel] CRITICAL ERROR parsing missionId: $missionId. Data: $json. Exception: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'zone': zone,
      'levelRequired': levelRequired,
      'status': status,
      'isRepeatable': isRepeatable,
      'objectives': objectives.map((obj) => obj.toJson()).toList(),
      'rewards': rewards.toJson(),
      if (dialogue != null) 'dialogue': dialogue!.toJson(),
      if (storyContent != null) 'storyContent': storyContent!.toJson(),
      if (originalId != null) 'id': originalId,
      if (type != null) 'type': type,
      if (storyPages != null) 'storyPages': storyPages!.map((page) => page.toJson()).toList(),
      if (battleConfig != null) 'battleConfig': battleConfig!.toJson(),
      if (requirements != null) 'requirements': requirements!.toJson(),
    };
  }
}

class Objective {
  final String type;
  final String description;
  final int? target;
  final List<String> questionIds;
  final String? enemyId;
  final int? targetKillCount;
  final List<String>? requiredItemIds;
  final int? timeLimitSeconds;
  final String? itemIdToCollect;
  final int? quantity;
  final String? collectionSourceDescription;
  final String? targetObjectId;
  final List<String>? interactionSequence;
  final String? interactionHint;
  final BattleConfigModel? battleConfig;

  Objective({
    required this.type,
    required this.description,
    this.target,
    required this.questionIds,
    this.enemyId,
    this.targetKillCount,
    this.requiredItemIds,
    this.timeLimitSeconds,
    this.itemIdToCollect,
    this.quantity,
    this.collectionSourceDescription,
    this.targetObjectId,
    this.interactionSequence,
    this.interactionHint,
    this.battleConfig,
  });

  factory Objective.fromJson(Map<String, dynamic> json) {
    List<String> parsedQuestionIds;
    if (json['questionIds'] is List) {
      parsedQuestionIds = (json['questionIds'] as List<dynamic>)
          .map((e) => e.toString()) 
          .toList();
    } else {
      parsedQuestionIds = []; 
    }

    return Objective(
      type: json['type'] as String? ?? 'unknown',
      description: json['description'] as String? ?? 'No description',
      target: (json['target'] as num?)?.toInt(),
      questionIds: parsedQuestionIds, 
      enemyId: json['enemyId'] as String?,
      targetKillCount: (json['targetKillCount'] as num?)?.toInt(),
      requiredItemIds: (json['requiredItemIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      timeLimitSeconds: (json['timeLimitSeconds'] as num?)?.toInt(),
      itemIdToCollect: json['itemIdToCollect'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      collectionSourceDescription: json['collectionSourceDescription'] as String?,
      targetObjectId: json['targetObjectId'] as String?,
      interactionSequence: (json['interactionSequence'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      interactionHint: json['interactionHint'] as String?,
      battleConfig: json['battleConfig'] != null && json['battleConfig'] is Map<String, dynamic>
          ? BattleConfigModel.fromJson(json['battleConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      if (target != null) 'target': target,
      if (questionIds.isNotEmpty) 'questionIds': questionIds,
      if (enemyId != null) 'enemyId': enemyId,
      if (targetKillCount != null) 'targetKillCount': targetKillCount,
      if (requiredItemIds != null && requiredItemIds!.isNotEmpty) 'requiredItemIds': requiredItemIds,
      if (timeLimitSeconds != null) 'timeLimitSeconds': timeLimitSeconds,
      if (itemIdToCollect != null) 'itemIdToCollect': itemIdToCollect,
      if (quantity != null) 'quantity': quantity,
      if (collectionSourceDescription != null) 'collectionSourceDescription': collectionSourceDescription,
      if (targetObjectId != null) 'targetObjectId': targetObjectId,
      if (interactionSequence != null && interactionSequence!.isNotEmpty) 'interactionSequence': interactionSequence,
      if (interactionHint != null) 'interactionHint': interactionHint,
      if (battleConfig != null) 'battleConfig': battleConfig!.toJson(),
    };
  }
}

class Rewards {
  final int experience;
  final int gold;
  final List<RewardItem> items;
  final List<String>? unlocks;

  Rewards({
    required this.experience,
    required this.gold,
    required this.items,
    this.unlocks,
  });

  factory Rewards.fromJson(Map<String, dynamic> json) {
    var itemsData = json['items'] as List<dynamic>? ?? [];
    List<RewardItem> itemsList = itemsData
        .map((itemData) {
            try {
                if (itemData is Map<String, dynamic> || itemData is String) {
                    return RewardItem.fromJson(itemData);
                }
                // print('[Rewards.fromJson] Invalid itemData type: ${itemData.runtimeType} for itemData: $itemData');
                return null;
            } catch (e) {
                // print('[Rewards.fromJson] Failed to parse a reward item: $e. Data: $itemData');
                return null; 
            }
        })
        .whereType<RewardItem>() 
        .toList();
    
    List<String> unlocksList;
    if (json['unlocks'] is List) {
        unlocksList = (json['unlocks'] as List<dynamic>)
            .map((unlock) => unlock.toString())
            .toList();
    } else {
        unlocksList = [];
    }

    return Rewards(
      experience: json['experience'] as int? ?? 0,
      gold: json['gold'] as int? ?? json['coins'] as int? ?? 0, 
      items: itemsList,
      unlocks: unlocksList.isNotEmpty ? unlocksList : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'gold': gold,
      'items': items.map((item) => item.toJson()).toList(),
      if (unlocks != null) 'unlocks': unlocks,
    };
  }
}

class RewardItem {
  final String itemId;

  RewardItem({required this.itemId});

  factory RewardItem.fromJson(dynamic json) { 
    if (json is String) {
      return RewardItem(itemId: json);
    } else if (json is Map<String, dynamic>) { 
        final itemId = json['itemId'] as String?;
        if (itemId == null) {
            // print('[RewardItem.fromJson] RewardItem map missing or null itemId. Data: $json');
            throw ArgumentError('RewardItem map missing or null itemId. Data: $json');
        }
      return RewardItem(itemId: itemId);
    } else if (json == null) {
        // print('[RewardItem.fromJson] Received null for reward item.');
        throw ArgumentError('Cannot parse null RewardItem');
    }
    // print('[RewardItem.fromJson] Invalid type for RewardItem: ${json.runtimeType}. Data: $json');
    throw ArgumentError('Invalid type for RewardItem: ${json.runtimeType}. Data: $json');
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
    };
  }
}

class Dialogue {
  final String characterId;
  final List<String> lines;
  final String? mood;

  Dialogue({required this.characterId, required this.lines, this.mood});

  factory Dialogue.fromJson(Map<String, dynamic> json) {
    var linesData = json['lines'] as List<dynamic>? ?? [];
    return Dialogue(
      characterId: json['characterId'] as String? ?? 'unknown_character',
      lines: linesData.map((line) => line.toString()).toList(),
      mood: json['mood'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'characterId': characterId,
      'lines': lines,
      if (mood != null) 'mood': mood,
    };
  }
}

class StoryContent {
  final String introduction;
  final String conclusion;
  final List<String>? keyEvents;

  StoryContent({required this.introduction, required this.conclusion, this.keyEvents});

  factory StoryContent.fromJson(Map<String, dynamic> json) {
    var keyEventsData = json['keyEvents'] as List<dynamic>?;
    return StoryContent(
      introduction: json['introduction'] as String? ?? 'No introduction',
      conclusion: json['conclusion'] as String? ?? 'No conclusion',
      keyEvents: keyEventsData?.map((event) => event.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'introduction': introduction, // No null check needed as it's required in constructor
      'conclusion': conclusion,   // No null check needed as it's required in constructor
      if (keyEvents != null) 'keyEvents': keyEvents,
    };
  }
}

// Ensure other nested models like StoryPageModel, BattleConfigModel, RequirementsModel 
// (defined in their own files) also handle null strings and lists robustly if they have such fields.
// Example for StoryPageModel (in story_page_model.dart):
/*
class StoryPageModel {
  // ... fields ...
  factory StoryPageModel.fromJson(Map<String, dynamic> json) {
    return StoryPageModel(
      pageId: json['pageId'] as String? ?? 'unknown_page_${DateTime.now().millisecondsSinceEpoch}',
      text: json['text'] as String? ?? 'No text for this page.',
      imageUrl: json['imageUrl'] as String?,
      // ... other fields like choices, ensuring robust parsing ...
    );
  }
}
*/
// Example for BattleConfigModel (in battle_config_model.dart):
/*
class BattleConfigModel {
  // ... fields ...
  factory BattleConfigModel.fromJson(Map<String, dynamic> json) {
    return BattleConfigModel(
      enemyId: json['enemyId'] as String? ?? 'default_enemy',
      // ... other fields ...
    );
  }
}
*/
// Example for RequirementsModel (in requirements_model.dart):
/*
class RequirementsModel {
  // ... fields ...
  factory RequirementsModel.fromJson(Map<String, dynamic> json) {
    return RequirementsModel(
      level: (json['level'] as num?)?.toInt(),
      completedMissionIds: (json['completedMissionIds'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [], // Default to empty list
      requiredItemIds: (json['requiredItemIds'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [], // Default to empty list
      // ... other fields ...
    );
  }
}
*/

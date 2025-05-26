// filepath: c:\Users\Pedro\Documents\GitHub\CodeQuest\lib\models\mission_model.dart
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
  String status; // 'disponible', 'bloqueada', 'en_progreso', 'completada'
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
      // Parseo robusto de Objectives
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
          .whereType<Objective>() // Filtra los nulls si Objective.fromJson puede devolver null o fallar
          .toList();

      // Parseo robusto de Rewards
      var rewardsData = json['rewards'] as Map<String, dynamic>?;
      Rewards rewardsInstance;
      if (rewardsData != null) {
        try {
          rewardsInstance = Rewards.fromJson(rewardsData);
        } catch (e) {
          // print('[MissionModel] Failed to parse rewards for mission $missionId: $e. Data: $rewardsData');
          // Asumimos que Rewards tiene un constructor .empty() o uno que puede manejar un mapa vacío.
          // Si no, necesitarías definir Rewards.empty() o ajustar esto.
          rewardsInstance = Rewards.fromJson({}); // Intenta con un mapa vacío como fallback
        }
      } else {
        // Si rewardsData es null, intenta crear una instancia de Rewards con un mapa vacío.
        // Esto requiere que Rewards.fromJson pueda manejar un mapa vacío y asignar valores por defecto.
        rewardsInstance = Rewards.fromJson({}); 
      }
      
      // Parseo robusto de StoryPages
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
        if (storyPagesList.isEmpty) storyPagesList = null; // Si la lista queda vacía después de filtrar, asignar null
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
      // Este rethrow es para errores que no se pudieron manejar con valores por defecto,
      // lo que hará que MissionService omita esta misión.
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name, // Updated
      'description': description,
      'zone': zone,
      'levelRequired': levelRequired,
      'status': status,
      // 'prerequisiteMissionId': prerequisiteMissionId, // Removed
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
  final String type; // 'questions', 'battle', 'collection', 'interaction', etc.
  final String description;
  final int? target; // Para 'questions' (número de respuestas correctas) o 'collection' (cantidad)
  final List<String>? questionIds; // Para 'questions' y 'battle'
  final String? enemyId; // Para 'battle'
  final int? targetKillCount; // Para 'battle' (si es derrotar N enemigos de un tipo)
  final List<String>? requiredItemIds; // Para 'battle' o 'interaction'
  final int? timeLimitSeconds; // Para 'questions' u otros objetivos cronometrados
  final String? itemIdToCollect; // Para 'collection'
  final int? quantity; // Para 'collection', podría ser redundante con 'target'.
  final String? collectionSourceDescription; // Para 'collection'
  final String? targetObjectId; // Para 'interaction'
  final List<String>? interactionSequence; // Para 'interaction'
  final String? interactionHint; // Para 'interaction'

  Objective({
    required this.type,
    required this.description,
    this.target,
    this.questionIds,
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
  });

  factory Objective.fromJson(Map<String, dynamic> json) {
    return Objective(
      type: json['type'] as String,
      description: json['description'] as String,
      target: json['target'] as int?,
      questionIds: (json['questionIds'] as List<dynamic>?)?.map((id) => id as String).toList(),
      enemyId: json['enemyId'] as String?,
      targetKillCount: json['targetKillCount'] as int?,
      requiredItemIds: (json['requiredItemIds'] as List<dynamic>?)?.map((id) => id as String).toList(),
      timeLimitSeconds: json['timeLimitSeconds'] as int?,
      itemIdToCollect: json['itemIdToCollect'] as String?,
      quantity: json['quantity'] as int?,
      collectionSourceDescription: json['collectionSourceDescription'] as String?,
      targetObjectId: json['targetObjectId'] as String?,
      interactionSequence: (json['interactionSequence'] as List<dynamic>?)?.map((step) => step as String).toList(),
      interactionHint: json['interactionHint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      if (target != null) 'target': target,
      if (questionIds != null) 'questionIds': questionIds,
      if (enemyId != null) 'enemyId': enemyId,
      if (targetKillCount != null) 'targetKillCount': targetKillCount,
      if (requiredItemIds != null) 'requiredItemIds': requiredItemIds,
      if (timeLimitSeconds != null) 'timeLimitSeconds': timeLimitSeconds,
      if (itemIdToCollect != null) 'itemIdToCollect': itemIdToCollect,
      if (quantity != null) 'quantity': quantity,
      if (collectionSourceDescription != null) 'collectionSourceDescription': collectionSourceDescription,
      if (targetObjectId != null) 'targetObjectId': targetObjectId,
      if (interactionSequence != null) 'interactionSequence': interactionSequence,
      if (interactionHint != null) 'interactionHint': interactionHint,
    };
  }
}

class Rewards {
  final int experience;
  final int gold; // Renamed from coins
  final List<RewardItem> items;
  final List<String>? unlocks; // IDs de misiones o features desbloqueadas

  Rewards({
    required this.experience,
    required this.gold, // Updated
    required this.items,
    this.unlocks,
  });

  factory Rewards.fromJson(Map<String, dynamic> json) {
    var itemsData = json['items'] as List<dynamic>? ?? [];
    List<RewardItem> itemsList = itemsData
        .map((itemData) => RewardItem.fromJson(itemData)) // Updated to pass dynamic
        .toList();
    
    return Rewards(
      experience: json['experience'] as int? ?? 0,
      gold: json['gold'] as int? ?? json['coins'] as int? ?? 0, // Handle old 'coins' and default to 0
      items: itemsList,
      unlocks: (json['unlocks'] as List<dynamic>?)?.map((unlock) => unlock as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'gold': gold, // Updated
      'items': items.map((item) => item.toJson()).toList(),
      if (unlocks != null) 'unlocks': unlocks,
    };
  }
}

class RewardItem {
  final String itemId;
  // final int quantity; // Removing quantity for now to match simple string list

  RewardItem({required this.itemId /*, required this.quantity */});

  factory RewardItem.fromJson(dynamic json) { // Accept dynamic for item
    if (json is String) {
      return RewardItem(itemId: json);
    } else if (json is Map<String, dynamic>) { // Keep if more complex items are also possible
        if (json['itemId'] == null) throw ArgumentError('RewardItem map missing itemId');
      return RewardItem(itemId: json['itemId'] as String);
    }
    throw ArgumentError('Invalid RewardItem format: must be String or Map. Received: $json');
  }

  // If items are just strings, toJson might just be part of Rewards.toJson
  // For now, let's make it simple, assuming Rewards.toJson will handle it.
  String toJson() => itemId; 
}

class Dialogue {
  final String npcName;
  final String start;
  final List<String>? during;
  final String endSuccess;
  final String? endFailure;

  Dialogue({
    required this.npcName,
    required this.start,
    this.during,
    required this.endSuccess,
    this.endFailure,
  });

  factory Dialogue.fromJson(Map<String, dynamic> json) {
    return Dialogue(
      npcName: json['npcName'] as String,
      start: json['start'] as String,
      during: (json['during'] as List<dynamic>?)?.map((d) => d as String).toList(),
      endSuccess: json['endSuccess'] as String,
      endFailure: json['endFailure'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'npcName': npcName,
      'start': start,
      if (during != null) 'during': during,
      'endSuccess': endSuccess,
      if (endFailure != null) 'endFailure': endFailure,
    };
  }
}

class StoryContent {
  final String? introduction;
  final String? conclusion;

  StoryContent({this.introduction, this.conclusion});

  factory StoryContent.fromJson(Map<String, dynamic> json) {
    return StoryContent(
      introduction: json['introduction'] as String?,
      conclusion: json['conclusion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (introduction != null) 'introduction': introduction,
      if (conclusion != null) 'conclusion': conclusion,
    };
  }
}

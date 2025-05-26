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
    print('[MissionModel] Attempting to parse missionId: $missionId');
    try {
      var objectivesData = json['objectives'] as List<dynamic>? ?? [];
      List<Objective> objectivesList = objectivesData
          .map((objData) => Objective.fromJson(objData as Map<String, dynamic>))
          .toList();

      return MissionModel(
        missionId: missionId,
        name: json['name'] as String? ?? json['title'] as String, // Handle old 'title' field
        description: json['description'] as String,
        zone: json['zone'] as String,
        levelRequired: json['levelRequired'] as int,
        status: json['status'] as String,
        // prerequisiteMissionId: json['prerequisiteMissionId'] as String?, // Removed
        isRepeatable: json['isRepeatable'] as bool,
        objectives: objectivesList,
        rewards: Rewards.fromJson(json['rewards'] as Map<String, dynamic>),
        dialogue: json['dialogue'] != null
            ? Dialogue.fromJson(json['dialogue'] as Map<String, dynamic>)
            : null,
        storyContent: json['storyContent'] != null
            ? StoryContent.fromJson(json['storyContent'] as Map<String, dynamic>)
            : null,
        originalId: json['id'] as String?,
        type: json['type'] as String?,
        storyPages: (json['storyPages'] as List<dynamic>?)
            ?.map((pageJson) => StoryPageModel.fromJson(pageJson as Map<String, dynamic>))
            .toList(),
        battleConfig: json['battleConfig'] != null
            ? BattleConfigModel.fromJson(json['battleConfig'] as Map<String, dynamic>)
            : null,
        requirements: json['requirements'] != null
            ? RequirementsModel.fromJson(json['requirements'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('[MissionModel] ERROR parsing missionId: $missionId. Data: $json');
      print('[MissionModel] Parser exception: $e');
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

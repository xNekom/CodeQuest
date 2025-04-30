// filepath: c:\Users\Pedro\Documents\GitHub\CodeQuest\lib\models\mission_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MissionModel {
  final String missionId;
  final String title;
  final String description;
  final String zone;
  final int levelRequired;
  String status; // 'disponible', 'bloqueada', 'en_progreso', 'completada'
  final String? prerequisiteMissionId;
  final bool isRepeatable;
  final List<Objective> objectives;
  final Rewards rewards;
  final Dialogue? dialogue;
  final StoryContent? storyContent;
  final String? originalId; // Para mantener el ID del JSON original si es necesario

  MissionModel({
    required this.missionId,
    required this.title,
    required this.description,
    required this.zone,
    required this.levelRequired,
    required this.status,
    this.prerequisiteMissionId,
    required this.isRepeatable,
    required this.objectives,
    required this.rewards,
    this.dialogue,
    this.storyContent,
    this.originalId,
  });

  factory MissionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MissionModel.fromJson(data, doc.id);
  }

  factory MissionModel.fromJson(Map<String, dynamic> json, String missionId) {
    var objectivesData = json['objectives'] as List<dynamic>? ?? [];
    List<Objective> objectivesList = objectivesData
        .map((objData) => Objective.fromJson(objData as Map<String, dynamic>))
        .toList();

    return MissionModel(
      missionId: missionId, // Usar el ID del documento de Firestore
      title: json['title'] as String,
      description: json['description'] as String,
      zone: json['zone'] as String,
      levelRequired: json['levelRequired'] as int,
      status: json['status'] as String,
      prerequisiteMissionId: json['prerequisiteMissionId'] as String?,
      isRepeatable: json['isRepeatable'] as bool,
      objectives: objectivesList,
      rewards: Rewards.fromJson(json['rewards'] as Map<String, dynamic>),
      dialogue: json['dialogue'] != null
          ? Dialogue.fromJson(json['dialogue'] as Map<String, dynamic>)
          : null,
      storyContent: json['storyContent'] != null
          ? StoryContent.fromJson(json['storyContent'] as Map<String, dynamic>)
          : null,
      originalId: json['id'] as String?, // Capturar el 'id' original del JSON
    );
  }

  Map<String, dynamic> toJson() {
    // El missionId no se incluye aquí porque es el ID del documento en Firestore
    return {
      'title': title,
      'description': description,
      'zone': zone,
      'levelRequired': levelRequired,
      'status': status,
      'prerequisiteMissionId': prerequisiteMissionId,
      'isRepeatable': isRepeatable,
      'objectives': objectives.map((obj) => obj.toJson()).toList(),
      'rewards': rewards.toJson(),
      if (dialogue != null) 'dialogue': dialogue!.toJson(),
      if (storyContent != null) 'storyContent': storyContent!.toJson(),
      if (originalId != null) 'id': originalId, // Restaurar el 'id' original si se guarda
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
  final int coins;
  final List<RewardItem> items;
  final List<String>? unlocks; // IDs de misiones o features desbloqueadas

  Rewards({
    required this.experience,
    required this.coins,
    required this.items,
    this.unlocks,
  });

  factory Rewards.fromJson(Map<String, dynamic> json) {
    var itemsData = json['items'] as List<dynamic>? ?? [];
    List<RewardItem> itemsList = itemsData
        .map((itemData) => RewardItem.fromJson(itemData as Map<String, dynamic>))
        .toList();
    
    return Rewards(
      experience: json['experience'] as int,
      coins: json['coins'] as int,
      items: itemsList,
      unlocks: (json['unlocks'] as List<dynamic>?)?.map((unlock) => unlock as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'coins': coins,
      'items': items.map((item) => item.toJson()).toList(),
      if (unlocks != null) 'unlocks': unlocks,
    };
  }
}

class RewardItem {
  final String itemId;
  final int quantity;

  RewardItem({required this.itemId, required this.quantity});

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      itemId: json['itemId'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'quantity': quantity,
    };
  }
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

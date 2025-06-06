import 'package:cloud_firestore/cloud_firestore.dart';
import 'battle_config_model.dart';
import 'requirements_model.dart';
import 'reward_model.dart';
import 'story_page_model.dart';

// Define la estructura de una misión en el juego.
class MissionModel {
  final String missionId; // ID único de la misión.
  final String name; // Nombre de la misión (anteriormente 'title').
  final String description; // Descripción de lo que el jugador necesita hacer para completar este objetivo.
  final String zone; // Zona o área del juego donde se desarrolla la misión.
  final int levelRequired; // Nivel mínimo que el jugador debe tener para acceder a esta misión.
  final String status; // Estado actual de la misión para el jugador (ej. 'disponible', 'bloqueada', 'completada').
  // final String? prerequisiteMissionId; // Removed, handled by requirements
  final RequirementsModel? requirements; // Requisitos que el jugador debe cumplir para desbloquear o iniciar la misión.
  final List<Objective> objectives; // Lista de objetivos que deben completarse para finalizar la misión.
  final Reward rewards; // Recompensas que el jugador recibe al completar la misión.
  final bool isRepeatable; // Indica si la misión se puede repetir una vez completada.
  final String? theory; // Contenido teórico asociado a la misión, si es de tipo 'teoria'.
  final String? technicalExplanation; // Explicación técnica del contenido, sin elementos narrativos.
  final List<String>? examples; // Ejemplos de código relevantes para la misión.
  final List<StoryPageModel>? storyPages; // Páginas de historia o narrativa asociadas a la misión.
  final BattleConfigModel? battleConfig; // Configuración específica para una batalla dentro de este objetivo, si aplica.
  final String? type; // Tipo de misión (ej. 'teoria', 'batalla', 'recoleccion').
  final int? order; // Número para ordenar las misiones, útil para mostrarlas en una secuencia específica.
  final List<String>? unlocks; // IDs de otras misiones que se desbloquean al completar esta.
  final DateTime? createdAt; // Fecha de creación del registro de la misión en la base de datos.
  final DateTime? updatedAt; // Fecha de la última actualización del registro de la misión.

  // Constructor para crear una instancia de MissionModel.
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

// Define un objetivo específico dentro de una misión.
class Objective {
  final String type; // Tipo de objetivo (ej. 'questions', 'batalla', 'collect_items', 'location'). Define cómo se completa.
  final String description; // Descripción de lo que el jugador necesita hacer para completar este objetivo.
  final int target; // Cantidad necesaria para completar el objetivo (ej. número de preguntas a responder, enemigos a derrotar).
  final List<String> questionIds; // IDs de las preguntas, si el objetivo es de tipo 'questions'.
  final int? timeLimitSeconds; // Límite de tiempo en segundos para completar el objetivo, si aplica.
  final String? itemId; // ID del ítem a recolectar, si el objetivo es de tipo 'collect_items'.
  final int? quantity; // Cantidad del ítem a recolectar.
  final String? enemyId; // ID del enemigo a derrotar, si el objetivo es de tipo 'batalla' o 'defeat_enemy'.
  final int? targetKillCount; // Número de veces que se debe derrotar al enemigo.
  final String? location; // Nombre o ID de la ubicación a la que se debe llegar, si el objetivo es de tipo 'location'.
  final String? collectionSource; // Descripción de dónde o cómo obtener los ítems de recolección.
  final String? collectionSourceDescription; // Descripción adicional sobre la fuente de recolección.
  final BattleConfigModel? battleConfig; // Configuración específica para una batalla dentro de este objetivo, si aplica.

  // Constructor para un objetivo de misión.
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

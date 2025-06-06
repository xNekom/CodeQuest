// Define los requisitos que un jugador debe cumplir para acceder a cierto contenido (ej. misiones, ítems).
class RequirementsModel {
  final int? level; // Nivel mínimo requerido del jugador.
  final String? completedMissionId; // ID de una misión que debe haber sido completada previamente.
  final String? itemRequired; // ID de un ítem que el jugador debe poseer.
  // Using Map<String, dynamic> for skillRequired to match JSON structure: "skillRequired": {"skillName": "navegacion", "level": 3}
  final Map<String, dynamic>? skillRequired; // Habilidad y nivel requeridos (ej. {"skillName": "navegacion", "level": 3}). 

  // Constructor para crear una instancia de RequirementsModel.
  RequirementsModel({
    this.level,
    this.completedMissionId,
    this.itemRequired,
    this.skillRequired,
  });

  factory RequirementsModel.fromJson(Map<String, dynamic> json) {
    return RequirementsModel(
      level: json['level'] as int?,
      completedMissionId: json['completedMissionId'] as String?,
      itemRequired: json['itemRequired'] as String?,
      skillRequired: json['skillRequired'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (level != null) 'level': level,
      if (completedMissionId != null) 'completedMissionId': completedMissionId,
      if (itemRequired != null) 'itemRequired': itemRequired,
      if (skillRequired != null) 'skillRequired': skillRequired,
    };
  }
}

// Define la configuración para una batalla específica, incluyendo el enemigo y las preguntas.
class BattleConfigModel {
  final String enemyId; // ID del enemigo contra el que se luchará.
  final List<String> questionIds; // Lista de IDs de preguntas que aparecerán durante la batalla (generalmente 3).
  final double? playerHealthMultiplier; // Multiplicador opcional para la salud del jugador en esta batalla.
  final double? enemyAttackMultiplier; // Multiplicador opcional para el ataque del enemigo en esta batalla.
  final String? environment; // Describe el entorno de la batalla, puede influir en la UI (ej. "bosque_oscuro", "cueva_eco").

  // Constructor para crear una configuración de batalla.
  BattleConfigModel({
    required this.enemyId,
    required this.questionIds,
    this.playerHealthMultiplier,
    this.enemyAttackMultiplier,
    this.environment,
  });

  factory BattleConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['enemyId'] == null || json['questionIds'] == null) {
      throw ArgumentError('Missing required fields: enemyId and questionIds are required.');
    }
    return BattleConfigModel(
      enemyId: json['enemyId'] as String,
      // Ensure questionIds is parsed as List<String>
      questionIds: List<String>.from(json['questionIds'] as List<dynamic>),
      playerHealthMultiplier: (json['playerHealthMultiplier'] as num?)?.toDouble(),
      enemyAttackMultiplier: (json['enemyAttackMultiplier'] as num?)?.toDouble(),
      environment: json['environment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enemyId': enemyId,
      'questionIds': questionIds,
      if (playerHealthMultiplier != null) 'playerHealthMultiplier': playerHealthMultiplier,
      if (enemyAttackMultiplier != null) 'enemyAttackMultiplier': enemyAttackMultiplier,
      if (environment != null) 'environment': environment,
    };
  }
}

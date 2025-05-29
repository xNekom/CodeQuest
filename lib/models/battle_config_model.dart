class BattleConfigModel {
  final String enemyId;
  final List<String> questionIds; // List of 3 existing question IDs
  final double? playerHealthMultiplier;
  final double? enemyAttackMultiplier;
  final String? environment; // e.g., "bosque_oscuro", "cueva_eco"

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

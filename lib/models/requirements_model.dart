class RequirementsModel {
  final int? level;
  final String? completedMissionId;
  final String? itemRequired;
  // Using Map<String, dynamic> for skillRequired to match JSON structure: "skillRequired": {"skillName": "navegacion", "level": 3}
  final Map<String, dynamic>? skillRequired; 

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

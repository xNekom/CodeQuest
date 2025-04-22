import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconUrl; // URL al icono del logro
  final List<String> requiredMissionIds; // IDs de las misiones necesarias para desbloquear
  final String rewardId; // ID de la recompensa otorgada
  final Timestamp? unlockedDate;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.requiredMissionIds,
    required this.rewardId,
    this.unlockedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'requiredMissionIds': requiredMissionIds,
      'rewardId': rewardId,
      'unlockedDate': unlockedDate?.toDate(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] is String ? map['id'] as String : throw ArgumentError('Invalid or missing "id"'),
      name: map['name'],
      description: map['description'],
      iconUrl: map['iconUrl'],
      requiredMissionIds: map['requiredMissionIds'] is List
          ? List<String>.from(map['requiredMissionIds'])
          : [],
      rewardId: map['rewardId'],
      unlockedDate: map['unlockedDate'] as Timestamp?,
    );
  }
}

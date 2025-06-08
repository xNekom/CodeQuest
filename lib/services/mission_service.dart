import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/mission_model.dart';

class MissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MissionModel>> getMissions() {
    return _firestore.collection('missions').orderBy('order').snapshots().map((snapshot) {
      List<MissionModel> missions = [];
      for (var doc in snapshot.docs) {
        try {
          missions.add(MissionModel.fromFirestore(doc));
        } catch (e) {
        }
      }
      return missions;
    });
  }

  Future<MissionModel?> getMissionById(String missionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('missions').doc(missionId).get();
      if (doc.exists) {
        return MissionModel.fromFirestore(doc);
      }
    } catch (e) {
    }
    return null;
  }

  Future<void> updateUserMissionStatus(String userId, String missionId, String status) async {
    try {
      await _firestore.collection('missions').doc(missionId).update({'status': status});
    } catch (e) {
    }
  }
}

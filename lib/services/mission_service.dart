import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/mission_model.dart';

class MissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todas las misiones
  Stream<List<MissionModel>> getMissions() {
    return _firestore.collection('missions').orderBy('levelRequired').snapshots().map((snapshot) {
      List<MissionModel> missions = [];
      if (snapshot.docs.isEmpty) {
        return missions;
      }
      for (var doc in snapshot.docs) {
        try {
          missions.add(MissionModel.fromFirestore(doc));
        } catch (e) {
          // print('[MissionService] Error parsing mission with ID ${doc.id}: $e');
          // print('[MissionService] Data for mission ${doc.id}: ${doc.data()}');
        }
      }
      if (missions.isEmpty && snapshot.docs.isNotEmpty) {
        // print('[MissionService] All mission documents failed to parse.');
      }
      return missions;
    });
  }

  // Obtener una misión específica por su ID
  Future<MissionModel?> getMissionById(String missionId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('missions').doc(missionId).get();
      if (doc.exists) {
        return MissionModel.fromFirestore(doc);
      }
    } catch (e) {
      // print('Error al obtener misión por ID: $e'); // Comentado: avoid_print
    }
    return null;
  }

  // Actualizar el estado de una misión (ej. 'en_progreso', 'completada')
  Future<void> updateUserMissionStatus(
      String userId, String missionId, String status) async {
    // Esta función podría ser más compleja, almacenando el progreso de la misión por usuario
    // Por ahora, asumimos que el estado de la misión es global o se maneja de otra forma.
    // Si necesitas un seguimiento por usuario, considera una subcolección en 'users' o 'missions'.
    try {
      await _firestore
          .collection('missions')
          .doc(missionId)
          .update({'status': status});
      // Adicionalmente, podrías querer registrar esto en el perfil del usuario
      // Ejemplo: await _firestore.collection('users').doc(userId).collection('missionProgress').doc(missionId).set({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      // print('Error al actualizar estado de la misión: $e'); // Comentado: avoid_print
    }
  }

  // TODO: Añadir más métodos según sea necesario (ej. obtener misiones disponibles para un nivel, etc.)
}

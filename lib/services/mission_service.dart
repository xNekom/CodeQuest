import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/mission_model.dart';

class MissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todas las misiones
  Stream<List<MissionModel>> getMissions() {
    return _firestore.collection('missions').snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => MissionModel.fromFirestore(doc))
            .toList();
      } catch (e) {
        // print('Error al mapear misiones: $e'); // Comentado: avoid_print
        // print('Datos del documento con error: ${snapshot.docs.firstWhere((d) => MissionModel.fromFirestore(d) == null).data()}'); // Comentado: avoid_print
        return []; // Retorna lista vacía en caso de error de parseo
      }
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

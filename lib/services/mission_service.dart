import 'dart:convert'; // Necesario para json.decode
import 'package:flutter/services.dart' show rootBundle; // Necesario para rootBundle
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codequest/models/mission_model.dart';
import 'package:codequest/config/app_config.dart'; // Importar AppConfig

class MissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Obtener todas las misiones
  Stream<List<MissionModel>> getMissions() {
    if (AppConfig.shouldUseFirebase) {
      return _firestore.collection('missions').orderBy('order').snapshots().map((snapshot) {
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
    } else {
      // Cargar desde JSON local como un stream para mantener la consistencia de la API
      return Stream.fromFuture(_loadMissionsFromLocalJson());
    }
  }

  // Obtener una misión específica por su ID
  Future<MissionModel?> getMissionById(String missionId) async {
    if (AppConfig.shouldUseFirebase) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('missions').doc(missionId).get();
        if (doc.exists) {
          return MissionModel.fromFirestore(doc);
        }
      } catch (e) {
        // print('Error al obtener misión por ID desde Firebase: $e');
      }
      return null;
    } else {
      return _getMissionByIdFromLocalJson(missionId);
    }
  }

  // Helper para cargar todas las misiones desde JSON local
  Future<List<MissionModel>> _loadMissionsFromLocalJson() async {
    try {
      print('[MissionService] Attempting to load missions from local JSON...');
      final String jsonString = await rootBundle.loadString('assets/data/missions_data.json');
      print('[MissionService] JSON string loaded: ${jsonString.substring(0, jsonString.length > 500 ? 500 : jsonString.length)}...'); // Log part of the string
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      print('[MissionService] JSON string decoded into list. Number of items: ${jsonList.length}');
      
      final List<MissionModel> missions = [];
      for (var data in jsonList) {
        try {
          final jsonData = data as Map<String, dynamic>;
          final missionIdFromJson = jsonData['id'] as String? ?? 'unknown_id_${DateTime.now().millisecondsSinceEpoch}';
          // print('[MissionService] Parsing mission with ID from JSON: $missionIdFromJson');
          missions.add(MissionModel.fromJson(jsonData, missionIdFromJson));
        } catch (e) {
          print('[MissionService] Error parsing a single mission object: $e. Data: $data');
          // Continuar con la siguiente misión en lugar de fallar todo
        }
      }
      
      print('[MissionService] Missions parsed from local JSON. Count: ${missions.length}');
      if (jsonList.isNotEmpty && missions.isEmpty) {
        print('[MissionService] CRITICAL: Decoded JSON list was not empty, but no missions were successfully parsed.');
      }
      return missions;
    } catch (e) {
      print("[MissionService] CRITICAL Error loading or decoding local missions: $e");
      return [];
    }
  }

  // Helper para obtener una misión por ID desde JSON local
  Future<MissionModel?> _getMissionByIdFromLocalJson(String missionId) async {
    try {
      // print('Obteniendo misión local por ID: $missionId');
      final List<MissionModel> allMissions = await _loadMissionsFromLocalJson();
      // print('Total de misiones locales para buscar: ${allMissions.length}');
      // Usar try-catch para manejar el caso en que no se encuentra la misión.
      // MissionModel.missionId es el campo correcto a verificar.
      MissionModel mission = allMissions.firstWhere((m) => m.missionId == missionId);
      // print('Misión local encontrada: ${mission.name}');
      return mission;
    } catch (e) {
      // Si firstWhere falla (StateError), significa que no se encontró la misión.
      // print("Misión local con ID $missionId no encontrada o error al buscar: $e");
      return null;
    }
  }

  // Actualizar el estado de una misión (ej. 'en_progreso', 'completada')
  Future<void> updateUserMissionStatus(
      String userId, String missionId, String status) async {
    if (AppConfig.shouldUseFirebase) {
      try {
        await _firestore
            .collection('missions')
            .doc(missionId)
            .update({'status': status});
      } catch (e) {
        // print('Error al actualizar estado de la misión en Firebase: $e');
      }
    } else {
      // print('[Local] Simulación de actualización de estado de misión para $missionId a $status. No implementado para JSON local.');
      // Para una base de datos local como Hive, aquí actualizarías el registro.
      // Para JSON, sería más complejo ya que tendrías que reescribir el archivo.
    }
  }

  // TODO: Añadir más métodos según sea necesario (ej. obtener misiones disponibles para un nivel, etc.)
  // Asegúrate de que los nuevos métodos también respeten AppConfig.shouldUseFirebase
}

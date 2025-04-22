import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mission_detail_screen.dart';

/// Pantalla que muestra todas las misiones disponibles
class MissionListScreen extends StatefulWidget {
  const MissionListScreen({super.key});

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Misiones')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
        builder: (context, userSnap) {
          if (userSnap.hasError) return Center(child: Text('Error usuario: ${userSnap.error}'));
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {}; // Asegurar que userData no sea null
          
          List<String> completed = [];
          final completedData = userData['completedMissions'];
          if (completedData is List) {
            try {
              // Intentar convertir cada elemento a String, filtrando nulos si los hubiera
              completed = completedData.whereType<String>().toList();
            } catch (e) {
              print('Error al procesar completedMissions: $e. Data: $completedData');
              // Mantener completed como lista vacía en caso de error inesperado en la conversión
            }
          } else if (completedData != null) {
            // Si completedMissions existe pero no es una lista, loguear y usar lista vacía.
            print('El campo completedMissions no es una lista para el usuario ${_uid}. Data: $completedData');
          }
          // Si completedData es null, 'completed' ya es [] por defecto.

          final current = userData['currentMissionId'] as String? ?? '';
          
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('missions')
                .orderBy('difficultyLevel')
                .orderBy('order')
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) return Center(child: Text('Error misiones: ${snap.error}'));
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final missions = snap.data!.docs;
              if (missions.isEmpty) return const Center(child: Text('No hay misiones disponibles.'));

              return ListView.builder(
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  final doc = missions[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final requires = data['requiresMissionCompleted'] as String?;
                  final isLocked = requires != null && requires.isNotEmpty && !completed.contains(requires);
                  final isCompleted = completed.contains(doc.id);
                  final isCurrent = current == doc.id;
                  return ListTile(
                    title: Text(data['name'] ?? ''),
                    subtitle: Text(data['description'] ?? ''),
                    leading: isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : isCurrent
                            ? const Icon(Icons.play_circle_fill, color: Colors.blue)
                            : null,
                    enabled: !isLocked,
                    onTap: !isLocked
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MissionDetailScreen(missionId: doc.id),
                              ),
                            );
                          }
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

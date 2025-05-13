import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // REMOVED
import 'mission_detail_screen.dart';
import '../../utils/custom_page_route.dart'; // Import FadePageRoute

/// Pantalla que muestra todas las misiones disponibles
class MissionListScreen extends StatefulWidget {
  const MissionListScreen({super.key});

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Misiones')),
      body: StreamBuilder<QuerySnapshot>(
        // Stream simple de la colección 'missions' sin ordenar por campos inexistentes
        stream: FirebaseFirestore.instance
            .collection('missions')
            .orderBy('levelRequired') // Updated orderBy field
            .snapshots(),
        builder: (context, snapshot) {
          // Added logging
          if (snapshot.hasError) {
            print('[MissionListScreen] StreamBuilder error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            print('[MissionListScreen] StreamBuilder: No data yet.');
          } else {
            final docs = snapshot.data!.docs;
            print('[MissionListScreen] StreamBuilder: Received ${docs.length} documents.');
            if (docs.isEmpty) {
              print('[MissionListScreen] StreamBuilder: Document list is empty.');
            }
          }

          if (snapshot.hasError) return Center(child: Text('Error misiones: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No hay misiones disponibles.'));
          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final level = data['levelRequired'] as int? ?? 0; // Updated field name
              final zone = data['zone'] as String? ?? '';
              return Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.surface, // Explicitly set card color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(Icons.assignment, color: Theme.of(context).colorScheme.primary), // Kept as primary
                  title: Text(
                    data['name'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description'] as String? ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        'Zona: $zone',
                        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withAlpha(50), // Changed background to secondary.withAlpha(50)
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Nivel $level',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary, // Kept text color as primary
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      FadePageRoute( // Use FadePageRoute
                        builder: (_) => MissionDetailScreen(missionId: doc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

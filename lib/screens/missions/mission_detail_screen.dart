import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import './theory_screen.dart';
import '../../widgets/pixel_widgets.dart';

/// Pantalla de detalle de misión y primer paso de aventura
class MissionDetailScreen extends StatelessWidget {
  final String missionId;

  const MissionDetailScreen({super.key, required this.missionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Misión')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('missions').doc(missionId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] as String? ?? 'Misión sin nombre';
          final description = data['description'] as String? ?? '';
          final steps = (data['structure'] as List<dynamic>? ?? []).cast<String>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(description),
                const SizedBox(height: 24),
                Text('Pasos:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...steps.map((step) => ListTile(
                      title: Text(step),
                    )),
                const SizedBox(height: 24),
                Center(
                  child: PixelButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await UserService().startMission(user.uid, missionId);
                      }
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TheoryScreen(
                            missionId: missionId,
                            theoryText: data['theory'] ?? 'Sin teoría disponible.',
                            examples: (data['examples'] as List<dynamic>? ?? []).cast<String>(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Iniciar Misión'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

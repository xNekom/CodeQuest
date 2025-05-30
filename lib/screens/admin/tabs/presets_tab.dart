import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresetsTab extends StatefulWidget {
  final VoidCallback? onDataUpdated;
  
  const PresetsTab({super.key, this.onDataUpdated});

  @override
  State<PresetsTab> createState() => _PresetsTabState();
}

class _PresetsTabState extends State<PresetsTab> {
  final CollectionReference _usersCol = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    if (currentUserId == null) {
      return Center(
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(
                  'Error de autenticación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'No se pudo obtener la información del usuario actual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(26), // equivalente a 0.1 de opacidad (255 * 0.1 ≈ 26)
            border: Border.all(color: Colors.orange.withAlpha(77)), // equivalente a 0.3 de opacidad (255 * 0.3 ≈ 77)
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.flash_on, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRESETS RÁPIDOS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aplica configuraciones predefinidas a tu perfil de forma rápida.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.withAlpha(204), // equivalente a 0.8 de opacidad (255 * 0.8 ≈ 204)
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _usersCol.doc(currentUserId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('No se encontraron datos del usuario'));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Text(
                                (data['username'] ?? 'Usuario actual')
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['username'] ?? 'Usuario actual',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Nivel: ${data['level'] ?? 0} | Exp: ${data['experience'] ?? 0} | Monedas: ${data['coins'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final changed = await _applyHackPreset(currentUserId, 'beginner');
                                    if (changed) widget.onDataUpdated?.call();
                                  },
                                  icon: const Icon(Icons.child_care, size: 16),
                                  label: const Text('Principiante',
                                    style: TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final changed = await _applyHackPreset(currentUserId, 'advanced');
                                    if (changed) widget.onDataUpdated?.call();
                                  },
                                  icon: const Icon(Icons.school, size: 16),
                                  label: const Text('Avanzado',
                                    style: TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final changed = await _applyHackPreset(currentUserId, 'master');
                                    if (changed) widget.onDataUpdated?.call();
                                  },
                                  icon: const Icon(Icons.emoji_events, size: 16),
                                  label: const Text('Maestro',
                                    style: TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      ],
    );
  }

  Future<bool> _applyHackPreset(String uid, String preset) async {
    Map<String, int> values;
    String presetName;

    switch (preset) {
      case 'beginner':
        values = {'level': 5, 'experience': 1000, 'coins': 500};
        presetName = 'Principiante';
        break;
      case 'advanced':
        values = {'level': 25, 'experience': 15000, 'coins': 5000};
        presetName = 'Avanzado';
        break;
      case 'master':
        values = {'level': 50, 'experience': 50000, 'coins': 25000};
        presetName = 'Maestro';
        break;
      default:
        return false;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Aplicar Preset $presetName',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Se aplicarán los siguientes valores:'),
            const SizedBox(height: 8),
            ...values.entries.map(
              (entry) => Text(
                '• ${entry.key == 'level'
                    ? 'Nivel'
                    : entry.key == 'experience'
                    ? 'Experiencia'
                    : entry.key == 'coins'
                    ? 'Monedas'
                    : entry.key}: ${entry.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _usersCol.doc(uid).update(values);
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preset $presetName aplicado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    }
    return false;
  }
}
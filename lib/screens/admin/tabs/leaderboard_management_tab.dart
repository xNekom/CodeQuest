import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardManagementTab extends StatefulWidget {
  const LeaderboardManagementTab({super.key});

  @override
  State<LeaderboardManagementTab> createState() => _LeaderboardManagementTabState();
}

class _LeaderboardManagementTabState extends State<LeaderboardManagementTab> {
  final CollectionReference _leaderboardsCol = FirebaseFirestore.instance
      .collection('leaderboard');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _leaderboardsCol.orderBy('score', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando clasificación...'),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        if (docs.isEmpty) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.leaderboard_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay datos en la clasificación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Los usuarios aparecerán aquí cuando completen misiones',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'] ?? '';
            final username = data['username'] ?? 'Usuario ${index + 1}';
            final score = data['score'] ?? 0;
            final isCurrentUser = userId == currentUserId;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              elevation: isCurrentUser ? 4 : 2,
              color: isCurrentUser ? Colors.blue.shade50 : null,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        style: TextStyle(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TÚ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '$score puntos',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                trailing: isCurrentUser
                    ? IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar mi puntuación',
                        onPressed: () => _editMyScore(doc, data),
                      )
                    : Icon(
                        Icons.lock,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRankColor(int position) {
    switch (position) {
      case 0:
        return Colors.amber; // Oro
      case 1:
        return Colors.grey.shade400; // Plata
      case 2:
        return Colors.brown; // Bronce
      default:
        return Colors.blue.shade300;
    }
  }

  Future<void> _editMyScore(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) async {
    final formKey = GlobalKey<FormState>();
    final scoreCtrl = TextEditingController(
      text: (data['score'] ?? 0).toString(),
    );

    // Capture context before async operation
    final dialogContext = context;

    await showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Editar Mi Puntuación', style: TextStyle(fontSize: 11)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usuario: ${data['username'] ?? data['userId'] ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: scoreCtrl,
                decoration: InputDecoration(
                  labelText: 'Nueva Puntuación',
                  prefixIcon: Icon(Icons.star, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) {
                    return 'Debe ser un número válido';
                  }
                  if (int.parse(v) < 0) return 'No puede ser negativo';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              // Capture contexts before async operation
              final navigatorContext = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                final newScore = int.parse(scoreCtrl.text);
                await _leaderboardsCol.doc(doc.id).update({
                  'score': newScore,
                  'lastUpdated': FieldValue.serverTimestamp(),
                });

                if (!mounted) return;
                navigatorContext.pop();

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Puntuación actualizada correctamente'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Error al actualizar: $e'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
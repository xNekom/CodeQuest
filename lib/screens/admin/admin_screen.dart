// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/reward_model.dart'; 
import '../../models/achievement_model.dart'; 
import '../../services/reward_service.dart'; 

// Helper class for Grid items
class _AdminGridItem {
  final String title;
  final IconData icon;
  final Widget Function() contentBuilder; // Function that returns the widget for the section

  _AdminGridItem({
    required this.title,
    required this.icon,
    required this.contentBuilder,
  });
}

// Helper StatelessWidget to display individual admin sections
class _SectionDetailScreen extends StatelessWidget {
  final String title;
  final Widget contentWidget;

  const _SectionDetailScreen({
    // Key? key, // Not needed if not passing a key
    required this.title,
    required this.contentWidget,
  }); // : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: contentWidget,
    );
  }
}


class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

// Remove SingleTickerProviderStateMixin
class _AdminScreenState extends State<AdminScreen> {
  final AuthService _authService = AuthService();
  final RewardService _rewardService = RewardService();
  // TabController _tabController; // Removed

  final CollectionReference _usersCol = FirebaseFirestore.instance.collection('users');
  final CollectionReference _missionsCol = FirebaseFirestore.instance.collection('missions');
  final CollectionReference _itemsCol = FirebaseFirestore.instance.collection('items');
  final CollectionReference _enemiesCol = FirebaseFirestore.instance.collection('enemies');
  final CollectionReference _leaderboardsCol = FirebaseFirestore.instance.collection('leaderboards');
  final CollectionReference _questionsCol = FirebaseFirestore.instance.collection('questions');
  final CollectionReference _rewardsCol = FirebaseFirestore.instance.collection('rewards'); 
  final CollectionReference _achievementsCol = FirebaseFirestore.instance.collection('achievements'); 
  
  Future<DocumentSnapshot?>? _userDataFuture;
  late List<_AdminGridItem> _adminGridItems; // For GridView

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Initialize grid items
    _adminGridItems = [
      _AdminGridItem(title: 'Usuarios', icon: Icons.person, contentBuilder: () => _buildUsersTab()),
      _AdminGridItem(title: 'Misiones', icon: Icons.flag, contentBuilder: () => _buildMissionsTab()),
      _AdminGridItem(title: 'Items', icon: Icons.inventory, contentBuilder: () => _buildItemsTab()),
      _AdminGridItem(title: 'Enemigos', icon: Icons.shield, contentBuilder: () => _buildEnemiesTab()),
      _AdminGridItem(title: 'Clasificación', icon: Icons.leaderboard, contentBuilder: () => _buildLeaderboardsTab()),
      _AdminGridItem(title: 'Preguntas', icon: Icons.question_answer, contentBuilder: () => _buildQuestionsTab()),
      _AdminGridItem(title: 'Recompensas', icon: Icons.star, contentBuilder: () => _buildRewardsTab()),
      _AdminGridItem(title: 'Logros', icon: Icons.emoji_events, contentBuilder: () => _buildAchievementsTab()),
    ];
    // _tabController = TabController(length: 8, vsync: this); // Removed
    // _tabController.addListener(() { // Removed
    //   if (mounted) { 
    //     setState(() {});
    //   }
    // });
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataFuture = _usersCol.doc(user.uid).get();
    } else {
      _userDataFuture = Future.value(null); 
    }
  }

  @override
  void dispose() {
    // _tabController.dispose(); // Removed
    super.dispose();
  }

  Future<void> _resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email de restablecimiento enviado.')));
    } catch (e) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _viewProfile(Map<String, dynamic> data) async {
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Detalles de Usuario'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      );
    });
  }

  Future<void> _editField(String uid, String field, int current) async {
    final controller = TextEditingController(text: current.toString());
    final formKey = GlobalKey<FormState>();
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text('Editar $field'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            validator: (v) => v == null || int.tryParse(v) == null ? 'Ingrese número válido' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final val = int.parse(controller.text);
            await _usersCol.doc(uid).update({field: val});
            if (!mounted) return; 
            Navigator.pop(context);
          }, child: const Text('Guardar')),
        ],
      );
    });
  }
  
  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Denegado'),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Usuario no autorizado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('No tienes permisos para acceder a esta sección.'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Volver al Inicio'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && ModalRoute.of(context)?.isCurrent == true) {
                 Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
            }
          });
          return const Scaffold(body: Center(child: Text("Redirigiendo a autenticación...")));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final String? role = userData?['role'] as String?;

        if (role != 'admin') {
          return _buildUnauthorizedScreen(context);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Administrador'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: () async {
                  await _authService.signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                },
              ),
            ],
            // bottom: TabBar(...) // Removed
          ),
          body: Padding( // Added padding around GridView
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 8.0, // Spacing between columns
                mainAxisSpacing: 8.0, // Spacing between rows
                childAspectRatio: 1.2, // Aspect ratio of the cards
              ),
              itemCount: _adminGridItems.length,
              itemBuilder: (context, index) {
                final item = _adminGridItems[index];
                return Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (newContext) => _SectionDetailScreen(
                            title: item.title,
                            contentWidget: item.contentBuilder(),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(item.icon, size: 48.0, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12.0),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // floatingActionButton: _buildFloatingActionButton(), // Removed
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
            stream: _usersCol.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No hay usuarios registrados.'));
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final role = data['role'] as String? ?? 'user';
                  return ExpansionTile(
                    title: Text(data['username'] ?? doc.id),
                    subtitle: Text(data['email'] ?? ''),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButton<String>(
                        value: role,
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (val) async {
                          if (val == null) return;
                          await _usersCol.doc(doc.id).update({'role': val});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Eliminar usuario'),
                              content: Text('¿Seguro que deseas eliminar a ${data['username'] ?? doc.id}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                              ],
                            ),
                          );
                          if (!context.mounted) return;
                          if (confirm == true) await _usersCol.doc(doc.id).delete();
                        },
                      ),
                    ]),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Text('Nivel: ${data['level'] ?? 0}'), IconButton(icon: const Icon(Icons.edit), onPressed: () => _editField(doc.id, 'level', data['level'] ?? 0))]),
                            Row(children: [Text('Exp: ${data['experiencePoints'] ?? 0}'), IconButton(icon: const Icon(Icons.edit), onPressed: () => _editField(doc.id, 'experiencePoints', data['experiencePoints'] ?? 0))]),
                            Row(children: [Text('Monedas: ${data['gameCurrency'] ?? 0}'), IconButton(icon: const Icon(Icons.edit), onPressed: () => _editField(doc.id, 'gameCurrency', data['gameCurrency'] ?? 0))]),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              TextButton(onPressed: () => _resetPassword(data['email'] ?? ''), child: const Text('Reset Password')),
                              TextButton(onPressed: () => _viewProfile(data), child: const Text('Ver Perfil')),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
  }

  Widget _buildItemsTab() {
     return StreamBuilder<QuerySnapshot>(
            stream: _itemsCol.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No hay items registrados.'));
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name'] ?? doc.id),
                    subtitle: Text(data['type'] ?? ''),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {
                        final nameCtrl = TextEditingController(text: data['name'] ?? '');
                        final descCtrl = TextEditingController(text: data['description'] ?? '');
                        final typeCtrl = TextEditingController(text: data['type'] ?? '');
                        showDialog(context: context, builder: (_) => AlertDialog(
                          title: const Text('Editar Item'),
                          content: Form(key: GlobalKey<FormState>(), child: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v==null||v.isEmpty?'Requerido':null),
                            TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                            TextFormField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Tipo')),
                          ])),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                            TextButton(onPressed: () async {
                              await _itemsCol.doc(doc.id).update({
                                'name': nameCtrl.text,
                                'description': descCtrl.text,
                                'type': typeCtrl.text,
                              });
                              if (!mounted) return; 
                              Navigator.pop(context);
                            }, child: const Text('Guardar'))],
                        ));
                      }),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _itemsCol.doc(doc.id).delete()),
                    ]),
                  );
                },
              );
            },
          );
  }

  Widget _buildEnemiesTab() {
    return StreamBuilder<QuerySnapshot>(
            stream: _enemiesCol.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No hay enemigos registrados.'));
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = docs[index]; final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name'] ?? doc.id),
                    subtitle: Text(data['type'] ?? ''),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () {
                        final formKey = GlobalKey<FormState>();
                        final n = TextEditingController(text: data['name'] as String? ?? '');
                        final d = TextEditingController(text: data['description'] as String? ?? '');
                        final t = TextEditingController(text: data['type'] as String? ?? '');
                        final v = TextEditingController(text: data['visualAssetUrl'] as String? ?? '');
                        final pool = TextEditingController(text: (data['questionPool'] as List<dynamic>?)?.join(',') ?? '');
                        showDialog(context: context, builder: (_) => AlertDialog(
                          title: const Text('Editar Enemigo'),
                          content: Form(
                            key: formKey,
                            child: SingleChildScrollView(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                TextFormField(controller: n, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                                TextFormField(controller: d, decoration: const InputDecoration(labelText: 'Descripción')),
                                TextFormField(controller: t, decoration: const InputDecoration(labelText: 'Tipo'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                                TextFormField(controller: v, decoration: const InputDecoration(labelText: 'Asset URL'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                                TextFormField(controller: pool, decoration: const InputDecoration(labelText: 'Question IDs (coma)'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                              ]),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                            TextButton(onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final qList = pool.text.split(',').map((e) => e.trim()).toList();
                              await _enemiesCol.doc(doc.id).update({
                                'name': n.text,
                                'description': d.text,
                                'type': t.text,
                                'visualAssetUrl': v.text,
                                'questionPool': qList,
                              });
                              if (!mounted) return; 
                              Navigator.pop(context);
                            }, child: const Text('Guardar'))
                          ],
                        ));
                      }),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _enemiesCol.doc(doc.id).delete()),
                    ]),
                  );
                },
              );
            },
          );
  }

  Widget _buildLeaderboardsTab() {
    return StreamBuilder<QuerySnapshot>(
            stream: _leaderboardsCol.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No hay entradas de clasificación.'));
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = docs[index]; final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['username'] ?? data['userId'] ?? ''),
                    subtitle: Text('Puntos: ${data['score'] ?? 0}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () {
                        final formKey = GlobalKey<FormState>();
                        final userCtrl = TextEditingController(text: data['userId'] as String? ?? '');
                        final unameCtrl = TextEditingController(text: data['username'] as String? ?? '');
                        final scoreCtrl = TextEditingController(text: (data['score'] ?? 0).toString());
                        showDialog(context: context, builder: (_) => AlertDialog(
                          title: const Text('Editar Entrada de Clasificación'),
                          content: Form(
                            key: formKey,
                            child: SingleChildScrollView(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                TextFormField(controller: userCtrl, decoration: const InputDecoration(labelText: 'User ID'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                                TextFormField(controller: unameCtrl, decoration: const InputDecoration(labelText: 'Username'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                                TextFormField(controller: scoreCtrl, decoration: const InputDecoration(labelText: 'Puntuación'), keyboardType: TextInputType.number, validator: (v) => v == null || int.tryParse(v) == null ? 'Número inválido' : null),
                              ]),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                            TextButton(onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final sc = int.parse(scoreCtrl.text);
                              await _leaderboardsCol.doc(doc.id).update({
                                'userId': userCtrl.text,
                                'username': unameCtrl.text,
                                'score': sc,
                                'lastUpdated': FieldValue.serverTimestamp(),
                              });
                              if (!mounted) return; 
                              Navigator.pop(context);
                            }, child: const Text('Guardar'))
                          ],
                        ));
                      }),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _leaderboardsCol.doc(doc.id).delete()),
                    ]),
                  );
                },
              );
            },
          );
  }

  Widget _buildQuestionsTab() {
    return StreamBuilder<QuerySnapshot>(
            stream: _questionsCol.snapshots(), 
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No hay preguntas registradas.'));
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['text'] ?? ''),
                    subtitle: Text('Opciones: ${(data['options'] as List<dynamic>?)?.length ?? 0}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {
                        final formKey = GlobalKey<FormState>();
                        final textCtrl = TextEditingController(text: data['text']);
                        final optsCtrl = TextEditingController(text: (data['options'] as List<dynamic>?)?.join('||') ?? '');
                        final correctCtrl = TextEditingController(text: (data['correctAnswerIndex'] ?? 0).toString());
                        final explCtrl = TextEditingController(text: data['explanation'] ?? '');
                        showDialog(context: context, builder: (_) => AlertDialog(
                          title: const Text('Editar Pregunta'),
                          content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextFormField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Texto'), validator: (v)=>v==null||v.isEmpty?'Requerido':null),
                            TextFormField(controller: optsCtrl, decoration: const InputDecoration(labelText: 'Opciones (separadas por ||)'), validator: (v)=>v==null||v.isEmpty?'Requerido':null),
                            TextFormField(controller: correctCtrl, decoration: const InputDecoration(labelText: 'Índice correcto'), keyboardType: TextInputType.number, validator: (v)=>v==null||int.tryParse(v)==null?'Número inválido':null),
                            TextFormField(controller: explCtrl, decoration: const InputDecoration(labelText: 'Explicación')),
                          ]))),
                          actions: [
                            TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancelar')),
                            TextButton(onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              await _questionsCol.doc(doc.id).update({ 
                                'text': textCtrl.text,
                                'options': optsCtrl.text.split('||'),
                                'correctAnswerIndex': int.parse(correctCtrl.text),
                                'explanation': explCtrl.text,
                              });
                              if (!mounted) return; 
                              Navigator.pop(context);
                            }, child: const Text('Guardar'))
                          ],
                        ));
                      }),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _questionsCol.doc(doc.id).delete()), 
                    ]),
                  );
                },
              );
            },
          );
  }
  
  // --- Widgets para las nuevas pestañas (Recompensas y Logros) ---
  Widget _buildRewardsTab() {
    return StreamBuilder<List<Reward>>(
      stream: _rewardService.getRewards(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rewards = snapshot.data!;
        if (rewards.isEmpty) return const Center(child: Text('No hay recompensas registradas.'));
        return ListView.separated(
          itemCount: rewards.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return ListTile(
              leading: reward.iconUrl.isNotEmpty ? Image.network(reward.iconUrl, width: 40, height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.star_border)) : const Icon(Icons.star_border),
              title: Text(reward.name),
              subtitle: Text('${reward.description}\\nTipo: ${reward.type.name}, Valor: ${reward.value}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showRewardDialog(reward: reward)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                  final confirm = await _showConfirmDialog('Eliminar Recompensa', '¿Seguro que deseas eliminar ${reward.name}?');
                  if (confirm == true) {
                    await _rewardService.deleteReward(reward.id);
                  }
                }),
              ]),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementsTab() {
    return StreamBuilder<List<Achievement>>(
      stream: _rewardService.getAchievements(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final achievements = snapshot.data!;
        if (achievements.isEmpty) return const Center(child: Text('No hay logros registrados.'));
        return ListView.separated(
          itemCount: achievements.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return ListTile(
              leading: achievement.iconUrl.isNotEmpty ? Image.network(achievement.iconUrl, width: 40, height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events_outlined)) : const Icon(Icons.emoji_events_outlined),
              title: Text(achievement.name),
              subtitle: Text('${achievement.description}\\nMisiones: ${achievement.requiredMissionIds.join(", ")}\\nRecompensa ID: ${achievement.rewardId}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAchievementDialog(achievement: achievement)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                  final confirm = await _showConfirmDialog('Eliminar Logro', '¿Seguro que deseas eliminar ${achievement.name}?');
                  if (confirm == true) {
                    await _rewardService.deleteAchievement(achievement.id);
                  }
                }),
              ]),
            );
          },
        );
      },
    );
  }

  // --- Diálogos para CRUD de Recompensas y Logros ---
  Future<void> _showRewardDialog({Reward? reward}) async {
    final isEditing = reward != null;
    final idCtrl = TextEditingController(text: isEditing ? reward.id : ''); 
    final nameCtrl = TextEditingController(text: isEditing ? reward.name : '');
    final descCtrl = TextEditingController(text: isEditing ? reward.description : '');
    final iconCtrl = TextEditingController(text: isEditing ? reward.iconUrl : '');
    RewardType typeValue = isEditing ? reward.type : RewardType.points;
    final valueCtrl = TextEditingController(text: isEditing ? reward.value.toString() : '0');
    final formKey = GlobalKey<FormState>();

    await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(isEditing ? 'Editar Recompensa' : 'Crear Recompensa'),
      content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (isEditing) TextFormField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID (no editable)'), readOnly: true),
        TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
        TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
        TextFormField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'URL del Icono')),
        DropdownButtonFormField<RewardType>(
          value: typeValue,
          decoration: const InputDecoration(labelText: 'Tipo de Recompensa'),
          items: RewardType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.name))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => typeValue = val); // Necesita ser StatefulBuilder o mover lógica al estado del diálogo
          },
        ),
        TextFormField(controller: valueCtrl, decoration: const InputDecoration(labelText: 'Valor (ej: puntos, ID item)'), keyboardType: TextInputType.number, validator: (v) => v == null || int.tryParse(v) == null ? 'Número inválido' : null),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          final newReward = Reward(
            id: idCtrl.text.isNotEmpty ? idCtrl.text : _rewardsCol.doc().id, // Generar ID si es nuevo
            name: nameCtrl.text,
            description: descCtrl.text,
            iconUrl: iconCtrl.text,
            type: typeValue, // Asegúrate que typeValue esté actualizada
            value: int.parse(valueCtrl.text),
          );
          if (isEditing) {
            await _rewardService.updateReward(newReward);
          } else {
            await _rewardService.createReward(newReward);
          }
          if (!mounted) return;
          Navigator.pop(context);
        }, child: const Text('Guardar')),
      ],
    ));
  }

  Future<void> _showAchievementDialog({Achievement? achievement}) async {
    final isEditing = achievement != null;
    final idCtrl = TextEditingController(text: isEditing ? achievement.id : ''); 
    final nameCtrl = TextEditingController(text: isEditing ? achievement.name : '');
    final descCtrl = TextEditingController(text: isEditing ? achievement.description : '');
    final iconCtrl = TextEditingController(text: isEditing ? achievement.iconUrl : '');
    final missionsCtrl = TextEditingController(text: isEditing ? achievement.requiredMissionIds.join(',') : '');
    final formKey = GlobalKey<FormState>();

    List<Reward> allRewards = [];
    String? selectedRewardId = isEditing ? achievement.rewardId : null;

    // Cargar recompensas para el Dropdown
    try {
      allRewards = await _rewardService.getRewards().first;
      if (allRewards.isNotEmpty && selectedRewardId == null && !isEditing) {
        // selectedRewardId = allRewards.first.id; // Opcional: preseleccionar la primera recompensa al crear
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar recompensas: $e')));
      return; // No mostrar diálogo si fallan las recompensas
    }
    

    await showDialog(context: context, builder: (_) => StatefulBuilder( 
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Logro' : 'Crear Logro'),
          content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (isEditing) TextFormField(controller: idCtrl, decoration: const InputDecoration(labelText: 'ID (no editable)'), readOnly: true),
            TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
            TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
            TextFormField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'URL del Icono')),
            TextFormField(controller: missionsCtrl, decoration: const InputDecoration(labelText: 'IDs de Misiones (separadas por coma)')),
            DropdownButtonFormField<String>(
              value: selectedRewardId,
              decoration: const InputDecoration(labelText: 'Recompensa Otorgada'),
              items: allRewards.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
              onChanged: (val) {
                if (val != null) setDialogState(() => selectedRewardId = val);
              },
              validator: (v) => v == null ? 'Seleccione una recompensa' : null,
            ),
          ]))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              if (selectedRewardId == null) { 
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe seleccionar una recompensa.')));
                  return;
              }
              final newAchievement = Achievement(
                id: idCtrl.text.isNotEmpty ? idCtrl.text : _achievementsCol.doc().id, // Generar ID si es nuevo
                name: nameCtrl.text,
                description: descCtrl.text,
                iconUrl: iconCtrl.text,
                requiredMissionIds: missionsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                rewardId: selectedRewardId!,
              );
              if (isEditing) {
                await _rewardService.updateAchievement(newAchievement);
              } else {
                await _rewardService.createAchievement(newAchievement);
              }
              if (!mounted) return;
              Navigator.pop(context);
            }, child: const Text('Guardar')),
          ],
        );
      }
    ));
  }

  Future<bool?> _showConfirmDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
  }

  // --- CRUD para Misiones ---
  Widget _buildMissionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _missionsCol.orderBy('difficultyLevel').orderBy('order').snapshots(), // Añadido orderBy
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No hay misiones registradas.'));
        
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            // TODO: Definir un modelo para Mission y usarlo aquí
            return ListTile(
              title: Text(data['name'] ?? data['title'] ?? doc.id), // Usar 'name' o 'title'
              subtitle: Text("Desc: ${data['description'] ?? 'N/A'}\\nDiff: ${data['difficultyLevel'] ?? 'N/A'}, Orden: ${data['order'] ?? 'N/A'}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showMissionDialog(missionDoc: doc),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await _showConfirmDialog('Eliminar Misión', '¿Seguro que deseas eliminar ${data['name'] ?? data['title'] ?? doc.id}?');
                      if (confirm == true) {
                        await _missionsCol.doc(doc.id).delete();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMissionDialog({DocumentSnapshot? missionDoc}) async {
    final isEditing = missionDoc != null;
    final data = missionDoc?.data() as Map<String, dynamic>?;

    final idCtrl = TextEditingController(text: isEditing ? missionDoc.id : '');
    final nameCtrl = TextEditingController(text: isEditing ? (data?['name'] as String? ?? data?['title'] as String? ?? '') : ''); 
    final descCtrl = TextEditingController(text: isEditing ? (data?['description'] as String? ?? '') : '');
    final difficultyLevelCtrl = TextEditingController(text: isEditing ? (data?['difficultyLevel']?.toString() ?? '1') : '1');
    final orderCtrl = TextEditingController(text: isEditing ? (data?['order']?.toString() ?? '10') : '10');
    
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Editar Misión' : 'Crear Misión'), 
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEditing)
                  TextFormField(
                    controller: idCtrl,
                    decoration: const InputDecoration(labelText: 'ID (no editable)'),
                    readOnly: true,
                  ),
                TextFormField(
                  controller: nameCtrl, 
                  decoration: const InputDecoration(labelText: 'Nombre de la Misión'), 
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: difficultyLevelCtrl,
                  decoration: const InputDecoration(labelText: 'Nivel de Dificultad (ej: 1, 2)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || int.tryParse(v) == null ? 'Número inválido' : null,
                ),
                TextFormField(
                  controller: orderCtrl,
                  decoration: const InputDecoration(labelText: 'Orden (ej: 10, 20)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || int.tryParse(v) == null ? 'Número inválido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final missionData = {
                'name': nameCtrl.text, 
                'description': descCtrl.text,
                'difficultyLevel': int.tryParse(difficultyLevelCtrl.text) ?? 1,
                'order': int.tryParse(orderCtrl.text) ?? 10,
              };

              try {
                if (isEditing) {
                  // El operador '!' se elimina aquí porque isEditing ya garantiza que missionDoc no es null
                  await _missionsCol.doc(missionDoc.id).update(missionData);
                } else {
                  await _missionsCol.add(missionData);
                }
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Misión ${isEditing ? 'actualizada' : 'creada'} con éxito.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al guardar misión: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

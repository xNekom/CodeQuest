import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final CollectionReference _usersCol = FirebaseFirestore.instance.collection('users');
  final CollectionReference _itemsCol = FirebaseFirestore.instance.collection('items');
  final CollectionReference _enemiesCol = FirebaseFirestore.instance.collection('enemies');
  final CollectionReference _leaderboardsCol = FirebaseFirestore.instance.collection('leaderboards');
  final AuthService _authService = AuthService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email de restablecimiento enviado.')));
    } catch (e) {
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
            Navigator.pop(context);
          }, child: const Text('Guardar')),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.person), text: 'Usuarios'),
            Tab(icon: Icon(Icons.flag), text: 'Misiones'),
            Tab(icon: Icon(Icons.inventory), text: 'Items'),
            Tab(icon: Icon(Icons.shield), text: 'Enemigos'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Clasificación'),
            Tab(icon: Icon(Icons.question_answer), text: 'Preguntas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña Usuarios
          StreamBuilder<QuerySnapshot>(
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
          ),
          // Pestaña Misiones (temporal)
          Center(child: Text('Gestión de misiones próximamente')),
          // Pestaña Items
          StreamBuilder<QuerySnapshot>(
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
                              await _itemsCol.doc(doc.id).update({'name': nameCtrl.text, 'description': descCtrl.text, 'type': typeCtrl.text});
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
          ),
          // Pestaña Enemigos
          StreamBuilder<QuerySnapshot>(
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
                              await _enemiesCol.doc(doc.id).update({'name': n.text, 'description': d.text, 'type': t.text, 'visualAssetUrl': v.text, 'questionPool': qList});
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
          ),
          // Pestaña Leaderboards
          StreamBuilder<QuerySnapshot>(
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
                              await _leaderboardsCol.doc(doc.id).update({'userId': userCtrl.text, 'username': unameCtrl.text, 'score': sc, 'lastUpdated': FieldValue.serverTimestamp()});
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
          ),
          // Pestaña Preguntas
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('questions').snapshots(),
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
                              await FirebaseFirestore.instance.collection('questions').doc(doc.id).update({
                                'text': textCtrl.text,
                                'options': optsCtrl.text.split('||'),
                                'correctAnswerIndex': int.parse(correctCtrl.text),
                                'explanation': explCtrl.text,
                              });
                              Navigator.pop(context);
                            }, child: const Text('Guardar'))
                          ],
                        ));
                      }),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('questions').doc(doc.id).delete()),
                    ]),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: Builder(builder: (context) {
        switch (_tabController.index) {
          case 0: // Usuarios
            return const SizedBox.shrink();
          case 1: // Misiones
            return const SizedBox.shrink();
          case 2: // Items
            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                final nameCtrl = TextEditingController();
                final descCtrl = TextEditingController();
                final typeCtrl = TextEditingController();
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('Crear Item'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v)=>v==null||v.isEmpty?'Requerido':null),
                    TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                    TextFormField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Tipo')),
                  ]),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    TextButton(onPressed: () async {
                      // Utiliza la instancia de Firestore directamente o asegúrate que _itemsCol está definida y es correcta.
                      await FirebaseFirestore.instance.collection('items').add({'name': nameCtrl.text, 'description': descCtrl.text, 'type': typeCtrl.text});
                      Navigator.pop(context);
                    }, child: const Text('Crear'))],
                ));
              },
            );
          case 3: // Enemigos
            return FloatingActionButton(onPressed: () {
              final formKey = GlobalKey<FormState>();
              final n = TextEditingController(); final d = TextEditingController(); final t = TextEditingController(); final v = TextEditingController(); final pool = TextEditingController();
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Crear Enemigo'),
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
                    final list = pool.text.split(',').map((e) => e.trim()).toList();
                    // Utiliza la instancia de Firestore directamente o asegúrate que _enemiesCol está definida y es correcta.
                    await FirebaseFirestore.instance.collection('enemies').add({'name': n.text, 'description': d.text, 'type': t.text, 'visualAssetUrl': v.text, 'questionPool': list});
                    Navigator.pop(context);
                  }, child: const Text('Crear'))
                ],
              ));
            }, child: const Icon(Icons.add));
          case 4: // Leaderboards
            return FloatingActionButton(onPressed: () {
              final formKey = GlobalKey<FormState>();
              final userCtrl = TextEditingController(); final uname = TextEditingController(); final score = TextEditingController();
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Crear Entrada de Clasificación'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextFormField(controller: userCtrl, decoration: const InputDecoration(labelText: 'User ID'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                      TextFormField(controller: uname, decoration: const InputDecoration(labelText: 'Username'), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                      TextFormField(controller: score, decoration: const InputDecoration(labelText: 'Puntuación'), keyboardType: TextInputType.number, validator: (v) => v == null || int.tryParse(v) == null ? 'Número inválido' : null),
                    ]),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  TextButton(onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final sc = int.parse(score.text);
                    // Utiliza la instancia de Firestore directamente o asegúrate que _leaderboardsCol está definida y es correcta.
                    await FirebaseFirestore.instance.collection('leaderboards').add({'userId': userCtrl.text, 'username': uname.text, 'score': sc, 'lastUpdated': FieldValue.serverTimestamp()});
                    Navigator.pop(context);
                  }, child: const Text('Crear'))
                ],
              ));
            }, child: const Icon(Icons.add));
          case 5: // Preguntas
            return FloatingActionButton(
              onPressed: () {
                final formKey = GlobalKey<FormState>();
                final textCtrl = TextEditingController();
                final optsCtrl = TextEditingController();
                final correctCtrl = TextEditingController();
                final explCtrl = TextEditingController();
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('Crear Pregunta'),
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
                      await FirebaseFirestore.instance.collection('questions').add({
                        'text': textCtrl.text,
                        'options': optsCtrl.text.split('||'),
                        'correctAnswerIndex': int.parse(correctCtrl.text),
                        'explanation': explCtrl.text,
                      });
                      Navigator.pop(context);
                    }, child: const Text('Crear'))
                  ],
                ));
              },
              child: const Icon(Icons.add),
            );
          default:
            return const SizedBox.shrink();
        }
      }),
    );
  }
}

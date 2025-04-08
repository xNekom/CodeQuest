import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final CollectionReference _usersCol = FirebaseFirestore.instance.collection('users');
  final AuthService _authService = AuthService();

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Usuarios'),
              Tab(icon: Icon(Icons.flag), text: 'Misiones'),
              Tab(icon: Icon(Icons.inventory), text: 'Items'),
            ],
          ),
        ),
        body: TabBarView(
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
            // Pestaña Misiones
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('missions').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name'] ?? doc.id),
                      subtitle: Text('Nivel: ${data['difficultyLevel'] ?? ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Editar misión',
                            onPressed: () {
                              final _formKey = GlobalKey<FormState>();
                              final nameCtrl = TextEditingController(text: data['name'] ?? '');
                              final descCtrl = TextEditingController(text: data['description'] ?? '');
                              final diffCtrl = TextEditingController(text: data['difficultyLevel'] ?? '');
                              final structCtrl = TextEditingController(text: (data['structure'] as List<dynamic>?)?.join(',') ?? '');
                              showDialog(context: context, builder: (_) {
                                return AlertDialog(
                                  title: const Text('Editar Misión'),
                                  content: Form(
                                    key: _formKey,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: nameCtrl,
                                            decoration: const InputDecoration(labelText: 'Nombre'),
                                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                          ),
                                          TextFormField(
                                            controller: descCtrl,
                                            decoration: const InputDecoration(labelText: 'Descripción'),
                                          ),
                                          TextFormField(
                                            controller: diffCtrl,
                                            decoration: const InputDecoration(labelText: 'Dificultad'),
                                          ),
                                          TextFormField(
                                            controller: structCtrl,
                                            decoration: const InputDecoration(labelText: 'Estructura (IDs por coma)'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                                    TextButton(onPressed: () async {
                                      if (!_formKey.currentState!.validate()) return;
                                      final ids = structCtrl.text.split(',').map((e) => e.trim()).toList();
                                      await FirebaseFirestore.instance.collection('missions').doc(doc.id).update({
                                        'name': nameCtrl.text,
                                        'description': descCtrl.text,
                                        'difficultyLevel': diffCtrl.text,
                                        'structure': ids,
                                      });
                                      Navigator.pop(context);
                                    }, child: const Text('Guardar')),
                                  ],
                                );
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => FirebaseFirestore.instance.collection('missions').doc(doc.id).delete(),
                          ),
                        ],
                      ),
                      onTap: () {
                        final _formKey = GlobalKey<FormState>();
                        final nameCtrl = TextEditingController(text: data['name'] ?? '');
                        final descCtrl = TextEditingController(text: data['description'] ?? '');
                        final diffCtrl = TextEditingController(text: data['difficultyLevel'] ?? '');
                        final structCtrl = TextEditingController(text: (data['structure'] as List<dynamic>?)?.join(',') ?? '');
                        showDialog(context: context, builder: (_) {
                          return AlertDialog(
                            title: const Text('Editar Misión'),
                            content: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: nameCtrl,
                                      decoration: const InputDecoration(labelText: 'Nombre'),
                                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                    ),
                                    TextFormField(
                                      controller: descCtrl,
                                      decoration: const InputDecoration(labelText: 'Descripción'),
                                    ),
                                    TextFormField(
                                      controller: diffCtrl,
                                      decoration: const InputDecoration(labelText: 'Dificultad'),
                                    ),
                                    TextFormField(
                                      controller: structCtrl,
                                      decoration: const InputDecoration(labelText: 'Estructura (IDs por coma)'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                              TextButton(onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;
                                final ids = structCtrl.text.split(',').map((e) => e.trim()).toList();
                                await FirebaseFirestore.instance.collection('missions').doc(doc.id).update({
                                  'name': nameCtrl.text,
                                  'description': descCtrl.text,
                                  'difficultyLevel': diffCtrl.text,
                                  'structure': ids,
                                });
                                Navigator.pop(context);
                              }, child: const Text('Guardar')),
                            ],
                          );
                        });
                      },
                    );
                  },
                );
              },
            ),
            // Pestaña Items
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('items').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name'] ?? doc.id),
                      subtitle: Text(data['type'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('items').doc(doc.id).delete(),
                      ),
                      onTap: () {
                        // TODO: editar item
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            // Dialogo para crear nueva misión
            final _formKey = GlobalKey<FormState>();
            final nameCtrl = TextEditingController();
            final descCtrl = TextEditingController();
            final diffCtrl = TextEditingController();
            final structCtrl = TextEditingController();
            showDialog(context: context, builder: (_) {
              return AlertDialog(
                title: const Text('Crear Misión'),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre'),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(labelText: 'Descripción'),
                        ),
                        TextFormField(
                          controller: diffCtrl,
                          decoration: const InputDecoration(labelText: 'Dificultad'),
                        ),
                        TextFormField(
                          controller: structCtrl,
                          decoration: const InputDecoration(labelText: 'Estructura (IDs separados por coma)'),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  TextButton(onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final ids = structCtrl.text.split(',').map((e) => e.trim()).toList();
                    await FirebaseFirestore.instance.collection('missions').add({
                      'name': nameCtrl.text,
                      'description': descCtrl.text,
                      'difficultyLevel': diffCtrl.text,
                      'structure': ids,
                      'javaConcepts': [],
                      'reward': {},
                      'unlockCondition': {},
                    });
                    Navigator.pop(context);
                  }, child: const Text('Crear')),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}

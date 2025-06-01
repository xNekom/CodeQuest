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
  final Widget Function()
  contentBuilder; // Function that returns the widget for the section

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
    return Scaffold(appBar: AppBar(title: Text(title)), body: contentWidget);
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

  final CollectionReference _usersCol = FirebaseFirestore.instance.collection(
    'users',
  );
  final CollectionReference _missionsCol = FirebaseFirestore.instance
      .collection('missions');
  final CollectionReference _itemsCol = FirebaseFirestore.instance.collection(
    'items',
  );
  final CollectionReference _enemiesCol = FirebaseFirestore.instance.collection(
    'enemies',
  );
  final CollectionReference _leaderboardsCol = FirebaseFirestore.instance
      .collection('leaderboard');
  final CollectionReference _questionsCol = FirebaseFirestore.instance
      .collection('questions');
  final CollectionReference _rewardsCol = FirebaseFirestore.instance.collection(
    'rewards',
  );
  final CollectionReference _achievementsCol = FirebaseFirestore.instance
      .collection('achievements');

  Future<DocumentSnapshot?>? _userDataFuture;
  late List<_AdminGridItem> _adminGridItems; // For GridView

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Initialize grid items
    _adminGridItems = [
      _AdminGridItem(
        title: 'Gestión de Monedas',
        icon: Icons.monetization_on,
        contentBuilder: () => _buildCoinsManagementTab(),
      ),
      _AdminGridItem(
        title: 'Gestión de Experiencia',
        icon: Icons.star,
        contentBuilder: () => _buildExperienceManagementTab(),
      ),
      _AdminGridItem(
        title: 'Gestión de Nivel',
        icon: Icons.trending_up,
        contentBuilder: () => _buildLevelManagementTab(),
      ),
      _AdminGridItem(
        title: 'Gestión de Clasificación',
        icon: Icons.leaderboard,
        contentBuilder: () => _buildLeaderboardsTab(),
      ),
      _AdminGridItem(
        title: 'Gestión de Logros',
        icon: Icons.emoji_events,
        contentBuilder: () => _buildUserAchievementsTab(),
      ),
      _AdminGridItem(
        title: 'Presets Rápidos',
        icon: Icons.flash_on,
        contentBuilder: () => _buildPresetsTab(),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de restablecimiento enviado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _viewProfile(Map<String, dynamic> data) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Detalles de Usuario'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  data.entries
                      .map((e) => Text('${e.key}: ${e.value}'))
                      .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editField(String uid, String field, int current) async {
    final controller = TextEditingController(text: current.toString());
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Editar $field'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              validator:
                  (v) =>
                      v == null || int.tryParse(v) == null
                          ? 'Ingrese número válido'
                          : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final val = int.parse(controller.text);
                await _usersCol.doc(uid).update({field: val});
                if (!mounted) return;
                _loadUserData(); // Recargar datos
                setState(() {}); // Actualizar interfaz
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && ModalRoute.of(context)?.isCurrent == true) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/auth',
                (route) => false,
              );
            }
          });
          return const Scaffold(
            body: Center(child: Text("Redirigiendo a autenticación...")),
          );
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/auth',
                    (route) => false,
                  );
                },
              ),
            ],
            // bottom: TabBar(...) // Removed
          ),
          body: Padding(
            // Added padding around GridView
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (newContext) => _SectionDetailScreen(
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
                        Icon(
                          item.icon,
                          size: 48.0,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
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
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('No hay usuarios registrados.'));
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final role = data['role'] as String? ?? 'user';
            return ExpansionTile(
              title: Text(
                data['username'] ?? doc.id,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                data['email'] ?? '',
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SizedBox(
                width: 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: DropdownButton<String>(
                        value: role,
                        isExpanded: false,
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (val) async {
                          if (val == null) return;
                          await _usersCol.doc(doc.id).update({'role': val});
                          _loadUserData(); // Recargar datos
                          setState(() {}); // Actualizar interfaz
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Eliminar usuario'),
                                content: Text(
                                  '¿Seguro que deseas eliminar a ${data['username'] ?? doc.id}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                        );
                        if (!context.mounted) return;
                        if (confirm == true)
                          await _usersCol.doc(doc.id).delete();
                      },
                    ),
                  ],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Nivel: ${data['level'] ?? 0}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed:
                                () => _editField(
                                  doc.id,
                                  'level',
                                  data['level'] ?? 0,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Exp: ${data['experience'] ?? 0}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed:
                                () => _editField(
                                  doc.id,
                                  'experience',
                                  data['experience'] ?? 0,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Monedas: ${data['coins'] ?? 0}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed:
                                () => _editField(
                                  doc.id,
                                  'coins',
                                  data['coins'] ?? 0,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed:
                                () => _resetPassword(data['email'] ?? ''),
                            child: const Text('Reset Password'),
                          ),
                          TextButton(
                            onPressed: () => _viewProfile(data),
                            child: const Text('Ver Perfil'),
                          ),
                        ],
                      ),
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
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('No hay items registrados.'));
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? doc.id),
              subtitle: Text(data['type'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final nameCtrl = TextEditingController(
                        text: data['name'] ?? '',
                      );
                      final descCtrl = TextEditingController(
                        text: data['description'] ?? '',
                      );
                      final typeCtrl = TextEditingController(
                        text: data['type'] ?? '',
                      );
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Editar Item'),
                              content: Form(
                                key: GlobalKey<FormState>(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: nameCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Nombre',
                                      ),
                                      validator:
                                          (v) =>
                                              v == null || v.isEmpty
                                                  ? 'Requerido'
                                                  : null,
                                    ),
                                    TextFormField(
                                      controller: descCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Descripción',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: typeCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Tipo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _itemsCol.doc(doc.id).update({
                                      'name': nameCtrl.text,
                                      'description': descCtrl.text,
                                      'type': typeCtrl.text,
                                    });
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Guardar'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _itemsCol.doc(doc.id).delete(),
                  ),
                ],
              ),
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
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('No hay enemigos registrados.'));
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? doc.id),
              subtitle: Text(data['type'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      final formKey = GlobalKey<FormState>();
                      final n = TextEditingController(
                        text: data['name'] as String? ?? '',
                      );
                      final d = TextEditingController(
                        text: data['description'] as String? ?? '',
                      );
                      final t = TextEditingController(
                        text: data['type'] as String? ?? '',
                      );
                      final v = TextEditingController(
                        text: data['visualAssetUrl'] as String? ?? '',
                      );
                      final pool = TextEditingController(
                        text:
                            (data['questionPool'] as List<dynamic>?)?.join(
                              ',',
                            ) ??
                            '',
                      );
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Editar Enemigo'),
                              content: Form(
                                key: formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: n,
                                        decoration: const InputDecoration(
                                          labelText: 'Nombre',
                                        ),
                                        validator:
                                            (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Requerido'
                                                    : null,
                                      ),
                                      TextFormField(
                                        controller: d,
                                        decoration: const InputDecoration(
                                          labelText: 'Descripción',
                                        ),
                                      ),
                                      TextFormField(
                                        controller: t,
                                        decoration: const InputDecoration(
                                          labelText: 'Tipo',
                                        ),
                                        validator:
                                            (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Requerido'
                                                    : null,
                                      ),
                                      TextFormField(
                                        controller: v,
                                        decoration: const InputDecoration(
                                          labelText: 'Asset URL',
                                        ),
                                        validator:
                                            (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Requerido'
                                                    : null,
                                      ),
                                      TextFormField(
                                        controller: pool,
                                        decoration: const InputDecoration(
                                          labelText: 'Question IDs (coma)',
                                        ),
                                        validator:
                                            (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Requerido'
                                                    : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate())
                                      return;
                                    final qList =
                                        pool.text
                                            .split(',')
                                            .map((e) => e.trim())
                                            .toList();
                                    await _enemiesCol.doc(doc.id).update({
                                      'name': n.text,
                                      'description': d.text,
                                      'type': t.text,
                                      'visualAssetUrl': v.text,
                                      'questionPool': qList,
                                    });
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Guardar'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _enemiesCol.doc(doc.id).delete(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _leaderboardsCol.orderBy('score', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
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
        if (!snapshot.hasData)
          return const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando clasificación...'),
                  ],
                ),
              ),
            ),
          );
        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return Center(
            child: Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.leaderboard, color: Colors.blue, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'No hay entradas de clasificación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Los usuarios aparecerán aquí cuando completen misiones',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );

        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final userId = data['userId'] as String? ?? '';
              final username = data['username'] as String? ?? userId;
              final score = data['score'] as int? ?? 0;
              final isCurrentUser = userId == currentUserId;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                elevation: isCurrentUser ? 4 : 2,
                color: isCurrentUser ? Colors.blue.shade50 : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          username,
                          style: TextStyle(
                            fontWeight:
                                isCurrentUser
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
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
                  trailing:
                      isCurrentUser
                          ? IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Editar mi puntuación',
                            onPressed: () => _showEditScoreDialog(doc, data),
                          )
                          : Icon(
                            Icons.lock,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                ),
              );
            },
          ),
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

  Future<void> _showEditScoreDialog(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
  ) async {
    final formKey = GlobalKey<FormState>();
    final scoreCtrl = TextEditingController(
      text: (data['score'] ?? 0).toString(),
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text('Editar Mi Puntuación'),
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
                      if (int.tryParse(v) == null)
                        return 'Debe ser un número válido';
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

                  try {
                    final newScore = int.parse(scoreCtrl.text);
                    await _leaderboardsCol.doc(doc.id).update({
                      'score': newScore,
                      'lastUpdated': FieldValue.serverTimestamp(),
                    });

                    if (!mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
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
                    ScaffoldMessenger.of(context).showSnackBar(
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

  Widget _buildQuestionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _questionsCol.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('No hay preguntas registradas.'));
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['text'] ?? ''),
              subtitle: Text(
                'Opciones: ${(data['options'] as List<dynamic>?)?.length ?? 0}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final formKey = GlobalKey<FormState>();
                      final textCtrl = TextEditingController(
                        text: data['text'],
                      );
                      final optsCtrl = TextEditingController(
                        text:
                            (data['options'] as List<dynamic>?)?.join('||') ??
                            '',
                      );
                      final correctCtrl = TextEditingController(
                        text: (data['correctAnswerIndex'] ?? 0).toString(),
                      );
                      final explCtrl = TextEditingController(
                        text: data['explanation'] ?? '',
                      );
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Editar Pregunta'),
                              content: Form(
                                key: formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: textCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Texto',
                                        ),
                                        validator:
                                            (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Requerido'
                                                    : null,
                                      ),
                                      TextFormField(
                                        controller: optsCtrl,
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Opciones (separadas por ||)',
                                        ),
                                        validator:
                                            (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Requerido'
                                                    : null,
                                      ),
                                      TextFormField(
                                        controller: correctCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Índice correcto',
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator:
                                            (v) =>
                                                v == null ||
                                                        int.tryParse(v) == null
                                                    ? 'Número inválido'
                                                    : null,
                                      ),
                                      TextFormField(
                                        controller: explCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Explicación',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate())
                                      return;
                                    await _questionsCol.doc(doc.id).update({
                                      'text': textCtrl.text,
                                      'options': optsCtrl.text.split('||'),
                                      'correctAnswerIndex': int.parse(
                                        correctCtrl.text,
                                      ),
                                      'explanation': explCtrl.text,
                                    });
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Guardar'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _questionsCol.doc(doc.id).delete(),
                  ),
                ],
              ),
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
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final rewards = snapshot.data!;
        if (rewards.isEmpty)
          return const Center(child: Text('No hay recompensas registradas.'));
        return ListView.separated(
          itemCount: rewards.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return ListTile(
              leading:
                  reward.iconUrl.isNotEmpty
                      ? Image.network(
                        reward.iconUrl,
                        width: 40,
                        height: 40,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.star_border),
                      )
                      : const Icon(Icons.star_border),
              title: Text(reward.name),
              subtitle: Text(
                '${reward.description}\\nTipo: ${reward.type}, Valor: ${reward.value}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showRewardDialog(reward: reward),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await _showConfirmDialog(
                        'Eliminar Recompensa',
                        '¿Seguro que deseas eliminar ${reward.name}?',
                      );
                      if (confirm == true) {
                        await _rewardService.deleteReward(reward.id);
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

  Widget _buildAchievementsTab() {
    return StreamBuilder<List<Achievement>>(
      stream: _rewardService.getAchievements(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final achievements = snapshot.data!;
        if (achievements.isEmpty)
          return const Center(child: Text('No hay logros registrados.'));
        return ListView.separated(
          itemCount: achievements.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return ListTile(
              leading:
                  achievement.iconUrl.isNotEmpty
                      ? Image.network(
                        achievement.iconUrl,
                        width: 40,
                        height: 40,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.emoji_events_outlined),
                      )
                      : const Icon(Icons.emoji_events_outlined),
              title: Text(achievement.name),
              subtitle: Text(
                '${achievement.description}\\nMisiones: ${achievement.requiredMissionIds.join(", ")}\\nRecompensa ID: ${achievement.rewardId}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed:
                        () => _showAchievementDialog(achievement: achievement),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await _showConfirmDialog(
                        'Eliminar Logro',
                        '¿Seguro que deseas eliminar ${achievement.name}?',
                      );
                      if (confirm == true) {
                        await _rewardService.deleteAchievement(achievement.id);
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

  // --- Diálogos para CRUD de Recompensas y Logros ---
  Future<void> _showRewardDialog({Reward? reward}) async {
    final isEditing = reward != null;
    final idCtrl = TextEditingController(text: isEditing ? reward.id : '');
    final nameCtrl = TextEditingController(text: isEditing ? reward.name : '');
    final descCtrl = TextEditingController(
      text: isEditing ? reward.description : '',
    );
    final iconCtrl = TextEditingController(
      text: isEditing ? reward.iconUrl : '',
    );
    String typeValue = isEditing ? reward.type : 'points';
    final valueCtrl = TextEditingController(
      text: isEditing ? reward.value.toString() : '0',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(isEditing ? 'Editar Recompensa' : 'Crear Recompensa'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEditing)
                      TextFormField(
                        controller: idCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ID (no editable)',
                        ),
                        readOnly: true,
                      ),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator:
                          (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                    TextFormField(
                      controller: iconCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL del Icono',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: typeValue,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Recompensa',
                      ),
                      items:
                          RewardType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type.name,
                                  child: Text(type.name),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(
                            () => typeValue = val,
                          ); // Necesita ser StatefulBuilder o mover lógica al estado del diálogo
                      },
                    ),
                    TextFormField(
                      controller: valueCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Valor (ej: puntos, ID item)',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) =>
                              v == null || int.tryParse(v) == null
                                  ? 'Número inválido'
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final newReward = Reward(
                    id:
                        idCtrl.text.isNotEmpty
                            ? idCtrl.text
                            : _rewardsCol.doc().id, // Generar ID si es nuevo
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    iconUrl: iconCtrl.text,
                    type: typeValue,
                    value: int.parse(valueCtrl.text),
                  );
                  if (isEditing) {
                    await _rewardService.updateReward(newReward);
                  } else {
                    await _rewardService.createReward(newReward);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Future<void> _showAchievementDialog({Achievement? achievement}) async {
    final isEditing = achievement != null;
    final idCtrl = TextEditingController(text: isEditing ? achievement.id : '');
    final nameCtrl = TextEditingController(
      text: isEditing ? achievement.name : '',
    );
    final descCtrl = TextEditingController(
      text: isEditing ? achievement.description : '',
    );
    final iconCtrl = TextEditingController(
      text: isEditing ? achievement.iconUrl : '',
    );
    final missionsCtrl = TextEditingController(
      text: isEditing ? achievement.requiredMissionIds.join(',') : '',
    );
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
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar recompensas: $e')),
        );
      return; // No mostrar diálogo si fallan las recompensas
    }

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(isEditing ? 'Editar Logro' : 'Crear Logro'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEditing)
                          TextFormField(
                            controller: idCtrl,
                            decoration: const InputDecoration(
                              labelText: 'ID (no editable)',
                            ),
                            readOnly: true,
                          ),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty ? 'Requerido' : null,
                        ),
                        TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                        ),
                        TextFormField(
                          controller: iconCtrl,
                          decoration: const InputDecoration(
                            labelText: 'URL del Icono',
                          ),
                        ),
                        TextFormField(
                          controller: missionsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'IDs de Misiones (separadas por coma)',
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedRewardId,
                          decoration: const InputDecoration(
                            labelText: 'Recompensa Otorgada',
                          ),
                          items:
                              allRewards
                                  .map(
                                    (r) => DropdownMenuItem(
                                      value: r.id,
                                      child: Text(r.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setDialogState(() => selectedRewardId = val);
                          },
                          validator:
                              (v) =>
                                  v == null
                                      ? 'Seleccione una recompensa'
                                      : null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      if (selectedRewardId == null) {
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Debe seleccionar una recompensa.'),
                            ),
                          );
                        return;
                      }
                      final newAchievement = Achievement(
                        id:
                            idCtrl.text.isNotEmpty
                                ? idCtrl.text
                                : _achievementsCol
                                    .doc()
                                    .id, // Generar ID si es nuevo
                        name: nameCtrl.text,
                        description: descCtrl.text,
                        iconUrl: iconCtrl.text,
                        category: 'general', // Añadir categoría por defecto
                        points: 10, // Añadir puntos por defecto
                        conditions: {}, // Añadir condiciones vacías
                        requiredMissionIds:
                            missionsCtrl.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList(),
                        rewardId: selectedRewardId!,
                      );
                      if (isEditing) {
                        await _rewardService.updateAchievement(newAchievement);
                      } else {
                        await _rewardService.createAchievement(newAchievement);
                      }
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  // --- CRUD para Misiones ---
  Widget _buildMissionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _missionsCol
              .orderBy('difficultyLevel')
              .orderBy('order')
              .snapshots(), // Añadido orderBy
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('No hay misiones registradas.'));

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            // TODO: Definir un modelo para Mission y usarlo aquí
            return ListTile(
              title: Text(
                data['name'] ?? data['title'] ?? doc.id,
              ), // Usar 'name' o 'title'
              subtitle: Text(
                "Desc: ${data['description'] ?? 'N/A'}\\nDiff: ${data['difficultyLevel'] ?? 'N/A'}, Orden: ${data['order'] ?? 'N/A'}",
              ),
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
                      final confirm = await _showConfirmDialog(
                        'Eliminar Misión',
                        '¿Seguro que deseas eliminar ${data['name'] ?? data['title'] ?? doc.id}?',
                      );
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
    final nameCtrl = TextEditingController(
      text:
          isEditing
              ? (data?['name'] as String? ?? data?['title'] as String? ?? '')
              : '',
    );
    final descCtrl = TextEditingController(
      text: isEditing ? (data?['description'] as String? ?? '') : '',
    );
    final difficultyLevelCtrl = TextEditingController(
      text: isEditing ? (data?['difficultyLevel']?.toString() ?? '1') : '1',
    );
    final orderCtrl = TextEditingController(
      text: isEditing ? (data?['order']?.toString() ?? '10') : '10',
    );

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                        decoration: const InputDecoration(
                          labelText: 'ID (no editable)',
                        ),
                        readOnly: true,
                      ),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Misión',
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: difficultyLevelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nivel de Dificultad (ej: 1, 2)',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) =>
                              v == null || int.tryParse(v) == null
                                  ? 'Número inválido'
                                  : null,
                    ),
                    TextFormField(
                      controller: orderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Orden (ej: 10, 20)',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) =>
                              v == null || int.tryParse(v) == null
                                  ? 'Número inválido'
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final missionData = {
                    'name': nameCtrl.text,
                    'description': descCtrl.text,
                    'difficultyLevel':
                        int.tryParse(difficultyLevelCtrl.text) ?? 1,
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
                      SnackBar(
                        content: Text(
                          'Misión ${isEditing ? 'actualizada' : 'creada'} con éxito.',
                        ),
                      ),
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

  // Método para construir la pestaña de logs de errores

  // Gestión específica de monedas
  Widget _buildCoinsManagementTab() {
    return _buildSpecificManagementTab(
      title: 'GESTIÓN DE MONEDAS',
      field: 'coins',
      fieldName: 'Monedas',
      icon: Icons.monetization_on,
      color: Colors.amber,
      maxValue: 1000000,
      quickIncrements: [100, 1000, 10000],
      quickLabels: ['100', '1K', '10K'],
    );
  }

  // Gestión específica de experiencia
  Widget _buildExperienceManagementTab() {
    return _buildSpecificManagementTab(
      title: 'GESTIÓN DE EXPERIENCIA',
      field: 'experience',
      fieldName: 'Experiencia',
      icon: Icons.star,
      color: Colors.purple,
      maxValue: 1000000,
      quickIncrements: [500, 5000, 50000],
      quickLabels: ['500', '5K', '50K'],
    );
  }

  // Gestión específica de nivel
  Widget _buildLevelManagementTab() {
    return _buildSpecificManagementTab(
      title: 'GESTIÓN DE NIVEL',
      field: 'level',
      fieldName: 'Nivel',
      icon: Icons.trending_up,
      color: Colors.green,
      maxValue: 100,
      quickIncrements: [1, 5, 10],
      quickLabels: ['1', '5', '10'],
    );
  }

  // Widget genérico para gestión específica
  Widget _buildSpecificManagementTab({
    required String title,
    required String field,
    required String fieldName,
    required IconData icon,
    required Color color,
    required int maxValue,
    required List<int> quickIncrements,
    required List<String> quickLabels,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestiona específicamente los valores de $fieldName de los usuarios.',
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _usersCol.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;
              if (users.isEmpty) {
                return const Center(child: Text('No hay usuarios registrados'));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final doc = users[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final currentValue = data[field] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: color,
                                child: Icon(icon, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['username'] ?? doc.id,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$fieldName actual: $currentValue',
                                      style: TextStyle(
                                        fontSize: 14,
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
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () => _showSpecificHackDialog(
                                        doc.id,
                                        field,
                                        currentValue,
                                        fieldName,
                                        icon,
                                        color,
                                        maxValue,
                                        quickIncrements,
                                        quickLabels,
                                      ),
                                  icon: Icon(Icons.edit, size: 16),
                                  label: Text('Editar $fieldName'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed:
                                    () => _quickUpdate(
                                      doc.id,
                                      field,
                                      0,
                                      fieldName,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              quickIncrements.length,
                              (i) => TextButton(
                                onPressed:
                                    () => _quickUpdate(
                                      doc.id,
                                      field,
                                      currentValue + quickIncrements[i],
                                      fieldName,
                                    ),
                                child: Text('+${quickLabels[i]}'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Tab para presets rápidos
  Widget _buildPresetsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
                      'Aplica configuraciones predefinidas a los usuarios de forma rápida.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _usersCol.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;
              if (users.isEmpty) {
                return const Center(child: Text('No hay usuarios registrados'));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final doc = users[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Text(
                                  (data['username'] ?? doc.id)
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
                                      data['username'] ?? doc.id,
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
                              ElevatedButton.icon(
                                onPressed:
                                    () => _applyHackPreset(doc.id, 'beginner'),
                                icon: const Icon(Icons.child_care, size: 16),
                                label: const Text('Principiante'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed:
                                    () => _applyHackPreset(doc.id, 'advanced'),
                                icon: const Icon(Icons.school, size: 16),
                                label: const Text('Avanzado'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed:
                                    () => _applyHackPreset(doc.id, 'master'),
                                icon: const Icon(Icons.emoji_events, size: 16),
                                label: const Text('Maestro'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHackStatCard(
    String title,
    int value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHackDialog(
    String uid,
    String field,
    int currentValue,
    String fieldName,
  ) async {
    final controller = TextEditingController(text: currentValue.toString());
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.build, color: Colors.red),
              const SizedBox(width: 8),
              Text('Hack: $fieldName'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Valor actual: $currentValue',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nuevo valor de $fieldName',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      field == 'level'
                          ? Icons.trending_up
                          : field == 'experience'
                          ? Icons.star
                          : Icons.monetization_on,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Ingrese un valor';
                    }
                    final val = int.tryParse(v);
                    if (val == null) {
                      return 'Ingrese un número válido';
                    }
                    if (val < 0) {
                      return 'El valor no puede ser negativo';
                    }
                    if (field == 'level' && val > 100) {
                      return 'El nivel máximo es 100';
                    }
                    if (field == 'experience' && val > 1000000) {
                      return 'La experiencia máxima es 1,000,000';
                    }
                    if (field == 'coins' && val > 1000000) {
                      return 'Las monedas máximas son 1,000,000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        final newValue =
                            currentValue +
                            (field == 'coins'
                                ? 1000
                                : field == 'experience'
                                ? 500
                                : 1);
                        controller.text = newValue.toString();
                      },
                      child: Text(
                        '+${field == 'coins'
                            ? '1K'
                            : field == 'experience'
                            ? '500'
                            : '1'}',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final newValue =
                            currentValue +
                            (field == 'coins'
                                ? 10000
                                : field == 'experience'
                                ? 5000
                                : 5);
                        controller.text = newValue.toString();
                      },
                      child: Text(
                        '+${field == 'coins'
                            ? '10K'
                            : field == 'experience'
                            ? '5K'
                            : '5'}',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.text = '0';
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final val = int.parse(controller.text);
                await _usersCol.doc(uid).update({field: val});
                if (!mounted) return;
                _loadUserData(); // Recargar datos
                setState(() {}); // Actualizar interfaz
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$fieldName actualizado a $val'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aplicar Hack'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyHackPreset(String uid, String preset) async {
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
        return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Aplicar Preset $presetName'),
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
      if (!mounted) return;
      _loadUserData(); // Recargar datos
      setState(() {}); // Actualizar interfaz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preset $presetName aplicado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Diálogo específico para cada tipo de gestión
  void _showSpecificHackDialog(
    String userId,
    String field,
    int currentValue,
    String fieldName,
    IconData icon,
    Color color,
    int maxValue,
    List<int> quickIncrements,
    List<String> quickLabels,
  ) {
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text('Editar $fieldName'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: fieldName,
                    hintText: 'Valor entre 0 y $maxValue',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(icon, color: color),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Incrementos rápidos:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    quickIncrements.length,
                    (i) => ElevatedButton(
                      onPressed: () {
                        int newValue = currentValue + quickIncrements[i];
                        if (newValue <= maxValue) {
                          controller.text = newValue.toString();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('+${quickLabels[i]}'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    controller.text = '0';
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset a 0'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final value = int.tryParse(controller.text);
                  if (value == null || value < 0 || value > maxValue) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Valor inválido. Debe estar entre 0 y $maxValue',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await _usersCol.doc(userId).update({field: value});
                    _loadUserData(); // Recargar datos
                    setState(() {}); // Actualizar interfaz
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$fieldName actualizado correctamente a $value',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al actualizar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  // Método para actualizaciones rápidas
  Future<void> _quickUpdate(
    String userId,
    String field,
    int newValue,
    String fieldName,
  ) async {
    try {
      await _usersCol.doc(userId).update({field: newValue});
      _loadUserData(); // Recargar datos
      setState(() {}); // Actualizar interfaz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName actualizado a $newValue'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para gestión de logros de usuarios
  Widget _buildUserAchievementsTab() {
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
                  'Usuario no autenticado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Debes iniciar sesión para gestionar tus logros',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _usersCol.doc(currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
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
        if (!snapshot.hasData)
          return const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando tus logros...'),
                  ],
                ),
              ),
            ),
          );

        if (!snapshot.data!.exists) {
          return Center(
            child: Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off, color: Colors.orange, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Usuario no encontrado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tu perfil de usuario no existe en la base de datos',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final unlockedAchievements = List<String>.from(
          data['unlockedAchievements'] ?? [],
        );
        final username = data['username'] as String? ?? 'Usuario';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información del usuario
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${unlockedAchievements.length} logros desbloqueados',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 160, // Ancho fijo para evitar overflow
                        child: ElevatedButton.icon(
                          onPressed:
                              () => _showManageMyAchievementsDialog(
                                currentUserId,
                                username,
                                unlockedAchievements,
                              ),
                          icon: Icon(Icons.edit, size: 16),
                          label: Text(
                            'Gestionar',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Lista de logros
              Text(
                'Mis Logros:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12),

              Expanded(
                child:
                    unlockedAchievements.isEmpty
                        ? Center(
                          child: Card(
                            color: Colors.grey.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    color: Colors.grey.shade400,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aún no tienes logros',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Completa misiones y desafíos para desbloquear logros',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : StreamBuilder<List<Achievement>>(
                          stream: _rewardService.getAchievements(),
                          builder: (context, achievementsSnapshot) {
                            if (achievementsSnapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error al cargar logros: ${achievementsSnapshot.error}',
                                ),
                              );
                            }
                            if (!achievementsSnapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final allAchievements = achievementsSnapshot.data!;

                            // Crear mapeo de document ID a achievement ID
                            return FutureBuilder<Map<String, String>>(
                              future: _createDocumentToAchievementMapping(),
                              builder: (context, mappingSnapshot) {
                                if (!mappingSnapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final docIdToAchievementId =
                                    mappingSnapshot.data!;

                                // Convertir document IDs a achievement IDs
                                final achievementIds =
                                    unlockedAchievements
                                        .map(
                                          (docId) =>
                                              docIdToAchievementId[docId],
                                        )
                                        .where((id) => id != null)
                                        .cast<String>()
                                        .toSet();

                                final unlockedAchievementDetails =
                                    allAchievements
                                        .where(
                                          (achievement) => achievementIds
                                              .contains(achievement.id),
                                        )
                                        .toList();

                                print(
                                  'DEBUG: Total achievements: ${allAchievements.length}',
                                );
                                print(
                                  'DEBUG: Unlocked achievement IDs: $unlockedAchievements',
                                );
                                print(
                                  'DEBUG: Achievement IDs after mapping: $achievementIds',
                                );
                                print(
                                  'DEBUG: Filtered achievements: ${unlockedAchievementDetails.length}',
                                );

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              MediaQuery.of(
                                                        context,
                                                      ).size.width >
                                                      600
                                                  ? 3
                                                  : 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 0.85,
                                        ),
                                    itemCount:
                                        unlockedAchievementDetails.length,
                                    itemBuilder: (context, index) {
                                      final achievement =
                                          unlockedAchievementDetails[index];
                                      return Card(
                                        elevation: 3,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.amber.shade100,
                                                Colors.amber.shade50,
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.emoji_events,
                                                        color:
                                                            Colors
                                                                .amber
                                                                .shade700,
                                                        size: 32,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        achievement.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      SizedBox(height: 4),
                                                      Flexible(
                                                        child: Text(
                                                          achievement
                                                              .description,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 3,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed:
                                                      () =>
                                                          _removeMyAchievement(
                                                            achievement.id,
                                                          ),
                                                  icon: Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.red.shade400,
                                                    size: 20,
                                                  ),
                                                  tooltip: 'Remover logro',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Diálogo para gestionar mis logros
  Future<void> _showManageMyAchievementsDialog(
    String userId,
    String username,
    List<String> currentAchievements,
  ) async {
    // DEBUG: Agregar logs para debugging
    print('DEBUG: _showManageMyAchievementsDialog called');
    print('DEBUG: userId: $userId');
    print('DEBUG: username: $username');
    print('DEBUG: currentAchievements: $currentAchievements');
    print('DEBUG: currentAchievements.length: ${currentAchievements.length}');

    final achievements = await _rewardService.getAchievements().first;
    print('DEBUG: achievements from service: ${achievements.length}');

    // Crear mapeo de document ID -> achievement ID
    final Map<String, String> docIdToAchievementId = {};
    final Map<String, String> achievementIdToDocId = {};

    // Obtener todos los documentos de achievements para crear el mapeo
    final achievementsSnapshot =
        await FirebaseFirestore.instance.collection('achievements').get();
    for (final doc in achievementsSnapshot.docs) {
      final data = doc.data();
      final achievementId = data['id'] as String;
      docIdToAchievementId[doc.id] = achievementId;
      achievementIdToDocId[achievementId] = doc.id;
      print('DEBUG: Mapping ${doc.id} -> $achievementId');
    }

    achievements.forEach((achievement) {
      print(
        'DEBUG: Available achievement: ${achievement.id} - ${achievement.name}',
      );
    });

    // Convertir currentAchievements (document IDs) a achievement IDs para la comparación
    final selectedAchievementIds =
        currentAchievements
            .map((docId) => docIdToAchievementId[docId])
            .where((id) => id != null)
            .cast<String>()
            .toSet();

    print('DEBUG: selectedAchievementIds Set: $selectedAchievementIds');
    final selectedAchievements = Set<String>.from(selectedAchievementIds);

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Gestionar Mis Logros'),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Usuario: $username',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Selecciona los logros que quieres tener:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child:
                              achievements.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.emoji_events_outlined,
                                          color: Colors.grey.shade400,
                                          size: 48,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No hay logros disponibles',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    itemCount: achievements.length,
                                    itemBuilder: (context, index) {
                                      final achievement = achievements[index];
                                      final isSelected = selectedAchievements
                                          .contains(achievement.id);

                                      // DEBUG: Log para cada checkbox
                                      print(
                                        'DEBUG: Checkbox $index - Achievement ID: ${achievement.id}',
                                      );
                                      print(
                                        'DEBUG: Checkbox $index - Achievement Name: ${achievement.name}',
                                      );
                                      print(
                                        'DEBUG: Checkbox $index - selectedAchievements.contains(${achievement.id}): $isSelected',
                                      );
                                      print(
                                        'DEBUG: Checkbox $index - Will be ${isSelected ? "CHECKED" : "UNCHECKED"}',
                                      );
                                      return Card(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        color:
                                            isSelected
                                                ? Colors.amber.shade50
                                                : null,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: isSelected,
                                                activeColor: Colors.amber,
                                                onChanged: (bool? value) {
                                                  setDialogState(() {
                                                    if (value == true) {
                                                      selectedAchievements.add(
                                                        achievement.id,
                                                      );
                                                    } else {
                                                      selectedAchievements
                                                          .remove(
                                                            achievement.id,
                                                          );
                                                    }
                                                  });
                                                },
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.emoji_events,
                                                color:
                                                    isSelected
                                                        ? Colors.amber
                                                        : Colors.grey.shade400,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      achievement.name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            isSelected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      achievement.description,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
                        // Convertir achievement IDs de vuelta a document IDs
                        final documentIds =
                            selectedAchievements
                                .map(
                                  (achievementId) =>
                                      achievementIdToDocId[achievementId],
                                )
                                .where((docId) => docId != null)
                                .cast<String>()
                                .toList();

                        await _updateMyAchievements(documentIds);
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Guardar Cambios'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Crear mapeo de document ID a achievement ID
  Future<Map<String, String>> _createDocumentToAchievementMapping() async {
    final Map<String, String> docIdToAchievementId = {};

    try {
      final achievementsSnapshot =
          await FirebaseFirestore.instance.collection('achievements').get();
      for (final doc in achievementsSnapshot.docs) {
        final data = doc.data();
        final achievementId = data['id'] as String;
        docIdToAchievementId[doc.id] = achievementId;
      }
    } catch (e) {
      print('Error creating document to achievement mapping: $e');
    }

    return docIdToAchievementId;
  }

  // Actualizar mis logros
  Future<void> _updateMyAchievements(List<String> achievements) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Usuario no autenticado'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('DEBUG: Updating achievements for user $currentUserId');
      print('DEBUG: New achievements list: $achievements');

      await _usersCol.doc(currentUserId).update({
        'unlockedAchievements': achievements,
      });

      print('DEBUG: Achievements updated successfully in Firestore');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Mis logros actualizados correctamente'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error al actualizar logros: $e'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Remover uno de mis logros
  Future<void> _removeMyAchievement(String achievementId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Usuario no autenticado'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Confirmar eliminación'),
              ],
            ),
            content: Text(
              '¿Estás seguro de que quieres remover el logro "$achievementId"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Remover'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _usersCol.doc(currentUserId).update({
        'unlockedAchievements': FieldValue.arrayRemove([achievementId]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Logro "$achievementId" removido'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error al remover logro: $e'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

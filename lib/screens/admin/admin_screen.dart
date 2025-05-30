// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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
  final CollectionReference _leaderboardsCol = FirebaseFirestore.instance
      .collection('leaderboard');


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
          Future.microtask(() {
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

  Widget _buildLeaderboardsTab() {
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
        if (!snapshot.hasData) {
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
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
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
        }

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

  // --- Widgets para las nuevas pestañas (Recompensas y Logros) ---
  // --- Diálogos para CRUD de Recompensas y Logros ---
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
                      'Gestiona específicamente tus valores de $fieldName.',
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
              final currentValue = data[field] ?? 0;

              return Center(
                child: Card(
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
                              backgroundColor: color,
                              child: Icon(icon, color: Colors.white),
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
                                      currentUserId,
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
                                    currentUserId,
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
                                    currentUserId,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tab para presets rápidos
  Widget _buildPresetsTab() {
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
                      'Aplica configuraciones predefinidas a tu perfil de forma rápida.',
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

              return Center(
                child: Card(
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
                                  onPressed:
                                      () => _applyHackPreset(currentUserId, 'beginner'),
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
                                  onPressed:
                                      () => _applyHackPreset(currentUserId, 'advanced'),
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
                                  onPressed:
                                      () => _applyHackPreset(currentUserId, 'master'),
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
                ),
              );
            },
          ),
        ),
      ],
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
        if (!snapshot.hasData) {
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
        }

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
                                Expanded(
                                  child: Text(
                                    '${unlockedAchievements.length} logros desbloqueados',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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

    for (var achievement in achievements) {
      print(
        'DEBUG: Available achievement: ${achievement.id} - ${achievement.name}',
      );
    }

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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../widgets/pixel_app_bar.dart';

// Components
import 'components/admin_grid_item.dart';
import 'components/section_detail_screen.dart';
import 'components/unauthorized_screen.dart';

// Tabs
import 'tabs/leaderboard_management_tab.dart';
import 'tabs/specific_management_tab.dart';
import 'tabs/presets_tab.dart';
import 'tabs/user_achievements_tab.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final CollectionReference _usersCol =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _achievementsCol =
      FirebaseFirestore.instance.collection('achievements');

  List<AdminGridItem> _adminGridItems = [];
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _initializeAdminItems();
    _loadUserData();
  }

  void _initializeAdminItems() {
    _adminGridItems = [
      AdminGridItem(
        title: 'Clasificaciones',
        icon: Icons.leaderboard,
        color: Colors.orange,
        onTap: () => _navigateToSection('Leaderboards'),
      ),
      AdminGridItem(
        title: 'Gestión Monedas',
        icon: Icons.monetization_on,
        color: Colors.green,
        onTap: () => _navigateToSection('Coin Management'),
      ),
      AdminGridItem(
        title: 'Gestión Experiencia',
        icon: Icons.trending_up,
        color: Colors.blue,
        onTap: () => _navigateToSection('Experience Management'),
      ),
      AdminGridItem(
        title: 'Gestión Niveles',
        icon: Icons.bar_chart,
        color: Colors.purple,
        onTap: () => _navigateToSection('Level Management'),
      ),
      AdminGridItem(
        title: 'Config',
        icon: Icons.settings,
        color: Colors.red,
        onTap: () => _navigateToSection('Hack Presets'),
      ),
      AdminGridItem(
        title: 'Mis Logros',
        icon: Icons.emoji_events,
        color: Colors.amber,
        onTap: () => _navigateToSection('My Achievements'),
      ),
    ];
  }

  Future<UserModel?> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!, currentUser.uid);
      }
    } catch (e) {
      // Error loading user data
    }
    return null;
  }

  Future<void> _loadUserData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      try {
        final userDoc = await _usersCol.doc(currentUserId).get();
        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
          });
        }
      } catch (e) {
        // Error loading user data
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToSection(String section) {
    Widget sectionWidget;
    
    switch (section) {
      case 'Leaderboards':
        sectionWidget = LeaderboardManagementTab();
        break;
      case 'Coin Management':
        sectionWidget = SpecificManagementTab(
          title: 'Gestión de Monedas',
          field: 'coins',
          fieldName: 'Monedas',
          icon: Icons.monetization_on,
          color: Colors.green,
          maxValue: 10000,
          quickIncrements: [10, 50, 100, 500],
          quickLabels: ['+10', '+50', '+100', '+500'],
          onDataUpdated: () {
            // Notificar que hubo cambios en los datos
          },
        );
        break;
      case 'Experience Management':
        sectionWidget = SpecificManagementTab(
          title: 'Gestión de Experiencia',
          field: 'experience',
          fieldName: 'Experiencia',
          icon: Icons.trending_up,
          color: Colors.blue,
          maxValue: 100000,
          quickIncrements: [100, 500, 1000, 5000],
          quickLabels: ['+100', '+500', '+1K', '+5K'],
          onDataUpdated: () {
            // Notificar que hubo cambios en los datos
          },
        );
        break;
      case 'Level Management':
        sectionWidget = SpecificManagementTab(
          title: 'Gestión de Nivel',
          field: 'level',
          fieldName: 'Nivel',
          icon: Icons.bar_chart,
          color: Colors.purple,
          maxValue: 100,
          quickIncrements: [1, 5, 10, 20],
          quickLabels: ['+1', '+5', '+10', '+20'],
          onDataUpdated: () {
            // Notificar que hubo cambios en los datos
          },
        );
        break;
      case 'Hack Presets':
        sectionWidget = PresetsTab(
          onDataUpdated: () {
            // Notificar que hubo cambios en los datos
          },
        );
        break;
      case 'My Achievements':
        sectionWidget = UserAchievementsTab(
          usersCol: _usersCol,
          achievementsCol: _achievementsCol,
          userData: _userData,
        );
        break;
      default:
        sectionWidget = Center(
          child: Text('Sección no implementada: $section'),
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionDetailScreen(
          title: section,
          contentWidget: sectionWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final UserModel? user = snapshot.data;
        
        // Check if user is authenticated and is admin
        if (user == null || !user.isAdmin) {
          return UnauthorizedScreen();
        }

        return PopScope<bool>(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, bool? result) {
            // Notificar que hubo cambios cuando se sale del panel de admin
            if (!didPop) {
              Navigator.pop(context, true);
            }
          },
          child: Scaffold(
            appBar: PixelAdminAppBar(
              title: 'Panel Admin',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurple,
                    Colors.deepPurple.shade300,
                    Colors.white,
                  ],
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome section
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                size: 30,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenido, ${user.username}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  Text(
                                    'Panel de administración de CodeQuest',
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
                      ),
                      SizedBox(height: 24),
                      
                      // Admin tools grid
                      Text(
                        'Herramientas de Administración',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _adminGridItems.length,
                          itemBuilder: (context, index) {
                            return _adminGridItems[index];
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
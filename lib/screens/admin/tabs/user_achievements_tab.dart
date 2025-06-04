import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/achievement_model.dart';
import '../../../config/app_config.dart';
import '../../../services/reward_service.dart';

class UserAchievementsTab extends StatefulWidget {
  final CollectionReference usersCol;
  final CollectionReference achievementsCol;
  final Map<String, dynamic>? userData;

  const UserAchievementsTab({
    super.key,
    required this.usersCol,
    required this.achievementsCol,
    required this.userData,
  });

  @override
  State<UserAchievementsTab> createState() => _UserAchievementsTabState();
}

class _UserAchievementsTabState extends State<UserAchievementsTab> {
  final RewardService _rewardService = RewardService();
  List<Achievement> _unlockedAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlockedAchievements();
  }

  Future<void> _loadUnlockedAchievements() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      if (AppConfig.shouldUseFirebase) {
        // Usar datos de Firebase (userData)
        final unlockedIds = List<String>.from(
          widget.userData?['unlockedAchievements'] ?? [],
        );
        
        if (unlockedIds.isNotEmpty) {
          final List<Achievement> achievements = [];
          for (final id in unlockedIds) {
            try {
              final doc = await widget.achievementsCol.doc(id).get();
              if (doc.exists) {
                final data = doc.data() as Map<String, dynamic>;
                achievements.add(Achievement.fromMap(data));
              }
            } catch (e) {
              // Error loading achievement
            }
          }
          setState(() {
            _unlockedAchievements = achievements;
            _isLoading = false;
          });
        } else {
          setState(() {
            _unlockedAchievements = [];
            _isLoading = false;
          });
        }
      } else {
        // Usar datos locales de SharedPreferences
        _rewardService.getUnlockedAchievements(currentUserId).listen((achievements) {
          if (mounted) {
            setState(() {
              _unlockedAchievements = achievements;
              _isLoading = false;
            });
          }
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Debes estar autenticado para ver esta sección',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando logros del usuario...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userData?['username'] ?? 'Usuario',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Logros desbloqueados: ${_unlockedAchievements.length}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showManageMyAchievementsDialog(),
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Gestionar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Mis Logros Desbloqueados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          if (_unlockedAchievements.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tienes logros desbloqueados aún',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _unlockedAchievements.length,
              itemBuilder: (context, index) {
                final achievement = _unlockedAchievements[index];
                final achievementData = achievement.toMap();

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAchievementIcon(achievementData),
                              SizedBox(height: 8),
                              Flexible(
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    achievement.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _removeMyAchievement(achievement.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              'Eliminar',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Mostrar diálogo para gestionar mis logros
  Future<void> _showManageMyAchievementsDialog() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Obtener todos los logros disponibles
    final achievementsSnapshot = await widget.achievementsCol.get();
    final allAchievements = achievementsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Achievement.fromMap(data);
    }).toList();

    // Crear mapeo de document ID a achievement ID
    final docIdToAchievementId = await _createDocumentToAchievementMapping();

    // Obtener logros actuales del usuario
    final currentAchievements = List<String>.from(
      widget.userData!['unlockedAchievements'] ?? [],
    );

    // Crear lista de logros seleccionados (usando document IDs)
    final selectedAchievements = <String>{};
    for (final achievementId in currentAchievements) {
      // Buscar el document ID correspondiente al achievement ID
      final docId = docIdToAchievementId.entries
          .firstWhere(
            (entry) => entry.value == achievementId,
            orElse: () => MapEntry('', ''),
          )
          .key;
      if (docId.isNotEmpty) {
        selectedAchievements.add(docId);
      }
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gestionar Mis Logros',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // User info
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
                      Flexible(
                        child: Text(
                          widget.userData!['username'] ?? 'Usuario',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: allAchievements.length,
                    itemBuilder: (context, index) {
                      final achievement = allAchievements[index];
                      final docId = achievementsSnapshot.docs[index].id;
                      final isSelected = selectedAchievements.contains(docId);



                      return CheckboxListTile(
                        title: Text(
                          achievement.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          achievement.description,
                          style: TextStyle(fontSize: 12),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedAchievements.add(docId);
                            } else {
                              selectedAchievements.remove(docId);
                            }
                          });
                        },
                        secondary: Icon(
                          Icons.emoji_events,
                          color: isSelected ? Colors.amber : Colors.grey,
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
              onPressed: () {
                // Convertir document IDs seleccionados a achievement IDs
                final newAchievements = selectedAchievements
                    .map((docId) => docIdToAchievementId[docId])
                    .where((id) => id != null)
                    .cast<String>()
                    .toList();


                _updateMyAchievements(newAchievements);
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
      // Error creating document to achievement mapping
    }

    return docIdToAchievementId;
  }

  // Actualizar mis logros
  Future<void> _updateMyAchievements(List<String> achievements) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usuario no autenticado',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Capture ScaffoldMessenger before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      if (AppConfig.shouldUseFirebase) {
        // Modo Firebase
        await widget.usersCol.doc(currentUserId).update({
          'unlockedAchievements': achievements,
        });
      } else {
        // Modo local
        final prefs = await SharedPreferences.getInstance();
        final key = 'user_${currentUserId}_unlocked_achievements';
        await prefs.setStringList(key, achievements);
      }

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Mis logros actualizados correctamente',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recargar los logros
        _loadUnlockedAchievements();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
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
  }



  // Remover uno de mis logros
  Future<void> _removeMyAchievement(String achievementId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usuario no autenticado',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Capture context and ScaffoldMessenger before async operations
    final dialogContext = context;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Confirmar eliminación',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar el logro "$achievementId"?',
              overflow: TextOverflow.visible,
              softWrap: true,
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
                child: Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;
    
    try {
      if (AppConfig.shouldUseFirebase) {
        // Modo Firebase
        await widget.usersCol.doc(currentUserId).update({
          'unlockedAchievements': FieldValue.arrayRemove([achievementId]),
        });
      } else {
        // Modo local
        final prefs = await SharedPreferences.getInstance();
        final key = 'user_${currentUserId}_unlocked_achievements';
        final currentAchievements = prefs.getStringList(key) ?? [];
        
        // Remover el achievement de la lista
        currentAchievements.remove(achievementId);
        
        // Guardar en SharedPreferences
        await prefs.setStringList(key, currentAchievements);
      }
      
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Logro "$achievementId" eliminado',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Recargar los logros
        _loadUnlockedAchievements();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error al eliminar logro: $e',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para construir el icono del achievement
  Widget _buildAchievementIcon(Map<String, dynamic> achievementData) {
    final iconUrl = achievementData['iconUrl'] as String?;
    
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return SvgPicture.asset(
        iconUrl,
        width: 32,
        height: 32,
        placeholderBuilder: (context) => const Icon(
          Icons.emoji_events,
          size: 32,
          color: Colors.amber,
        ),
      );
    }
    
    return const Icon(
      Icons.emoji_events,
      size: 32,
      color: Colors.amber,
    );
  }
}
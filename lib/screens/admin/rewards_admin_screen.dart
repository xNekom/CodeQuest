// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../models/reward_model.dart';
import '../../models/achievement_model.dart';
import '../../../services/reward_service.dart';

class RewardsAdminScreen extends StatefulWidget {
  const RewardsAdminScreen({super.key});

  @override
  State<RewardsAdminScreen> createState() => _RewardsAdminScreenState();
}

class _RewardsAdminScreenState extends State<RewardsAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Recompensas y Logros'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recompensas'),
              Tab(text: 'Logros'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RewardsTab(),
            AchievementsTab(),
          ],
        ),
      ),
    );
  }
}

class RewardsTab extends StatefulWidget {
  const RewardsTab({super.key});

  @override
  State<RewardsTab> createState() => _RewardsTabState();
}

class _RewardsTabState extends State<RewardsTab> {
  final RewardService _rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showCreateRewardDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Crear Nueva Recompensa'),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Reward>>(
            stream: _rewardService.getRewards(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final rewards = snapshot.data!;
              
              if (rewards.isEmpty) {
                return const Center(child: Text('No hay recompensas registradas.'));
              }
              
              return ListView.separated(
                itemCount: rewards.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return ListTile(
                    leading: _getRewardIcon(reward.type),
                    title: Text(reward.name),
                    subtitle: Text('${reward.description}\nTipo: ${_getRewardTypeDisplayName(reward.type)} | Valor: ${reward.value}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditRewardDialog(reward),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReward(reward.id),
                        ),
                      ],
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

  Widget _getRewardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'points':
        return const Icon(Icons.star, color: Colors.amber);
      case 'item':
        return const Icon(Icons.inventory, color: Colors.blue);
      case 'badge':
        return const Icon(Icons.military_tech, color: Colors.orange);
      case 'coins':
        return const Icon(Icons.monetization_on, color: Colors.yellow);
      case 'experience':
        return const Icon(Icons.trending_up, color: Colors.green);
      default:
        return const Icon(Icons.card_giftcard, color: Colors.purple);
    }
  }

  String _getRewardTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'points':
        return 'Puntos';
      case 'item':
        return 'Objeto';
      case 'badge':
        return 'Insignia';
      case 'coins':
        return 'Monedas';
      case 'experience':
        return 'Experiencia';
      default:
        return 'Desconocido';
    }
  }

  void _showCreateRewardDialog() {
    _showRewardDialog();
  }

  void _showEditRewardDialog(Reward reward) {
    _showRewardDialog(reward: reward);
  }

  void _showRewardDialog({Reward? reward}) {
    final isEditing = reward != null;
    
    final nameController = TextEditingController(text: reward?.name ?? '');
    final descriptionController = TextEditingController(text: reward?.description ?? '');
    final iconUrlController = TextEditingController(text: reward?.iconUrl ?? '');
    final valueController = TextEditingController(text: reward?.value.toString() ?? '0');
    
    String selectedType = reward?.type ?? 'points';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Editar Recompensa' : 'Crear Nueva Recompensa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: iconUrlController,
                  decoration: const InputDecoration(labelText: 'URL del Icono'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo de Recompensa'),
                  items: const [
                    DropdownMenuItem(value: 'points', child: Text('Puntos')),
                    DropdownMenuItem(value: 'item', child: Text('Objeto')),
                    DropdownMenuItem(value: 'badge', child: Text('Insignia')),
                    DropdownMenuItem(value: 'coins', child: Text('Monedas')),
                    DropdownMenuItem(value: 'experience', child: Text('Experiencia')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
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
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                final iconUrl = iconUrlController.text.trim();
                final value = int.tryParse(valueController.text) ?? 0;
                
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es requerido')),
                  );
                  return;
                }
                
                final newReward = Reward(
                  id: reward?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  description: description,
                  iconUrl: iconUrl,
                  type: selectedType,
                  value: value,
                );
                
                try {
                  if (isEditing) {
                    await _rewardService.updateReward(newReward);
                  } else {
                    await _rewardService.createReward(newReward);
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Recompensa ${isEditing ? 'actualizada' : 'creada'} exitosamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReward(String rewardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta recompensa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _rewardService.deleteReward(rewardId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recompensa eliminada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }
}

class AchievementsTab extends StatefulWidget {
  const AchievementsTab({super.key});

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  final RewardService _rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showCreateAchievementDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Crear Nuevo Logro'),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Achievement>>(
            stream: _rewardService.getAchievements(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final achievements = snapshot.data!;
              
              if (achievements.isEmpty) {
                return const Center(child: Text('No hay logros registrados.'));
              }
              
              return ListView.separated(
                itemCount: achievements.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return ListTile(
                    leading: const Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text(achievement.name),
                    subtitle: Text('${achievement.description}\nCategoría: ${achievement.category} | Puntos: ${achievement.points}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditAchievementDialog(achievement),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAchievement(achievement.id),
                        ),
                      ],
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

  void _showCreateAchievementDialog() {
    _showAchievementDialog();
  }

  void _showEditAchievementDialog(Achievement achievement) {
    _showAchievementDialog(achievement: achievement);
  }

  void _showAchievementDialog({Achievement? achievement}) {
    final isEditing = achievement != null;
    
    final nameController = TextEditingController(text: achievement?.name ?? '');
    final descriptionController = TextEditingController(text: achievement?.description ?? '');
    final iconUrlController = TextEditingController(text: achievement?.iconUrl ?? '');
    final pointsController = TextEditingController(text: achievement?.points.toString() ?? '10');
    
    String selectedCategory = achievement?.category ?? 'general';
    String selectedRewardId = achievement?.rewardId ?? '';
    List<String> requiredMissionIds = List.from(achievement?.requiredMissionIds ?? []);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Editar Logro' : 'Crear Nuevo Logro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: iconUrlController,
                  decoration: const InputDecoration(labelText: 'URL del Icono'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'enemy', child: Text('Enemigos')),
                    DropdownMenuItem(value: 'mission', child: Text('Misiones')),
                    DropdownMenuItem(value: 'combat', child: Text('Combate')),
                    DropdownMenuItem(value: 'exploration', child: Text('Exploración')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pointsController,
                  decoration: const InputDecoration(labelText: 'Puntos'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Reward>>(
                  stream: _rewardService.getRewards(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    
                    final rewards = snapshot.data!;
                    
                    return DropdownButtonFormField<String>(
                      value: selectedRewardId.isEmpty ? null : selectedRewardId,
                      decoration: const InputDecoration(labelText: 'Recompensa'),
                      items: rewards.map((reward) => DropdownMenuItem(
                        value: reward.id,
                        child: Text(reward.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRewardId = value ?? '';
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Misiones Requeridas:'),
                ElevatedButton(
                  onPressed: () => _showSelectMissionsDialog(
                    selectedMissions: requiredMissionIds,
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        requiredMissionIds.clear();
                        requiredMissionIds.addAll(newSelection);
                      });
                    },
                  ),
                  child: const Text('Seleccionar Misiones'),
                ),
                Text(
                  'Misiones seleccionadas: ${requiredMissionIds.length}',
                  style: const TextStyle(fontSize: 12),
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
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                final iconUrl = iconUrlController.text.trim();
                final points = int.tryParse(pointsController.text) ?? 10;
                
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es requerido')),
                  );
                  return;
                }
                
                if (selectedRewardId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debe seleccionar una recompensa')),
                  );
                  return;
                }
                
                final newAchievement = Achievement(
                  id: achievement?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  description: description,
                  iconUrl: iconUrl,
                  category: selectedCategory,
                  points: points,
                  conditions: _buildConditions(selectedCategory, requiredMissionIds),
                  requiredMissionIds: requiredMissionIds,
                  rewardId: selectedRewardId,
                );
                
                try {
                  if (isEditing) {
                    await _rewardService.updateAchievement(newAchievement);
                  } else {
                    await _rewardService.createAchievement(newAchievement);
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logro ${isEditing ? 'actualizado' : 'creado'} exitosamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _buildConditions(String category, List<String> requiredMissionIds) {
    switch (category) {
      case 'enemy':
        return {
          'type': 'enemy_defeated',
          'count': 1,
        };
      case 'mission':
        return {
          'type': 'missions_completed',
          'count': requiredMissionIds.length,
        };
      case 'combat':
        return {
          'type': 'battles_won',
          'count': 5,
        };
      default:
        return {};
    }
  }

  void _showSelectMissionsDialog({
    required List<String> selectedMissions,
    required Function(List<String>) onSelectionChanged,
  }) {
    // Implementar diálogo de selección de misiones
    // Por simplicidad, mostramos un diálogo básico
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Misiones'),
        content: const Text('Funcionalidad de selección de misiones en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _deleteAchievement(String achievementId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este logro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _rewardService.deleteAchievement(achievementId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logro eliminado exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }
}

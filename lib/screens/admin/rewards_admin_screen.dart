// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reward_model.dart';
import '../../models/achievement_model.dart';
import '../../services/reward_service.dart';

class RewardsAdminScreen extends StatefulWidget {
  const RewardsAdminScreen({super.key});

  @override
  State<RewardsAdminScreen> createState() => _RewardsAdminScreenState();
}

class _RewardsAdminScreenState extends State<RewardsAdminScreen> with SingleTickerProviderStateMixin {
  final RewardService _rewardService = RewardService();
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Recompensas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'RECOMPENSAS'),
            Tab(text: 'LOGROS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRewardsTab(),
          _buildAchievementsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddRewardDialog();
          } else {
            _showAddAchievementDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRewardsTab() {
    return StreamBuilder<List<Reward>>(
      stream: _rewardService.getRewards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final rewards = snapshot.data ?? [];
        if (rewards.isEmpty) {
          return const Center(child: Text('No hay recompensas disponibles'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: _getRewardTypeIcon(reward.type),
                ),
                title: Text(reward.name),
                subtitle: Text(reward.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getRewardValueText(reward),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRewardTypeColor(reward.type),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditRewardDialog(reward),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteRewardDialog(reward),
                    ),
                  ],
                ),
                onTap: () => _showRewardDetails(reward),
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
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final achievements = snapshot.data ?? [];
        if (achievements.isEmpty) {
          return const Center(child: Text('No hay logros disponibles'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.emoji_events),
                ),
                title: Text(achievement.name),
                subtitle: Text(achievement.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${achievement.requiredMissionIds.length} misiones',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditAchievementDialog(achievement),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteAchievementDialog(achievement),
                    ),
                  ],
                ),
                onTap: () => _showAchievementDetails(achievement),
              ),
            );
          },
        );
      },
    );
  }

  // Funciones auxiliares para la visualización de recompensas
  Widget _getRewardTypeIcon(RewardType type) {
    switch (type) {
      case RewardType.points:
        return const Icon(Icons.star, color: Colors.amber);
      case RewardType.item:
        return const Icon(Icons.inventory_2, color: Colors.blue);
      case RewardType.badge:
        return const Icon(Icons.emoji_events, color: Colors.orange);
    }
  }

  String _getRewardValueText(Reward reward) {
    switch (reward.type) {
      case RewardType.points:
        return '+${reward.value} XP';
      case RewardType.item:
        return 'Item ${reward.value}';
      case RewardType.badge:
        return 'Insignia';
    }
  }

  Color _getRewardTypeColor(RewardType type) {
    switch (type) {
      case RewardType.points:
        return Colors.amber;
      case RewardType.item:
        return Colors.blue;
      case RewardType.badge:
        return Colors.orange;
    }
  }

  // Diálogos para gestión de recompensas
  void _showAddRewardDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController iconUrlController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    RewardType selectedType = RewardType.points;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Añadir Nueva Recompensa'),
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
                const Text('Tipo de Recompensa:'),
                DropdownButton<RewardType>(
                  value: selectedType,
                  onChanged: (RewardType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedType = newValue;
                      });
                    }
                  },
                  items: RewardType.values.map((RewardType type) {
                    return DropdownMenuItem<RewardType>(
                      value: type,
                      child: Text(_getRewardTypeName(type)),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: selectedType == RewardType.points
                        ? 'Cantidad de Puntos'
                        : selectedType == RewardType.item
                            ? 'ID del Item'
                            : 'Valor',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    valueController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }

                setState(() => _isLoading = true);
                try {
                  final String id = DateTime.now().millisecondsSinceEpoch.toString();
                  final Reward newReward = Reward(
                    id: id,
                    name: nameController.text,
                    description: descriptionController.text,
                    iconUrl: iconUrlController.text,
                    type: selectedType,
                    value: int.parse(valueController.text),
                  );
                  await _rewardService.createReward(newReward);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recompensa creada correctamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRewardDialog(Reward reward) {
    final TextEditingController nameController = TextEditingController(text: reward.name);
    final TextEditingController descriptionController = TextEditingController(text: reward.description);
    final TextEditingController iconUrlController = TextEditingController(text: reward.iconUrl);
    final TextEditingController valueController = TextEditingController(text: reward.value.toString());
    RewardType selectedType = reward.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Recompensa'),
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
                const Text('Tipo de Recompensa:'),
                DropdownButton<RewardType>(
                  value: selectedType,
                  onChanged: (RewardType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedType = newValue;
                      });
                    }
                  },
                  items: RewardType.values.map((RewardType type) {
                    return DropdownMenuItem<RewardType>(
                      value: type,
                      child: Text(_getRewardTypeName(type)),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: selectedType == RewardType.points
                        ? 'Cantidad de Puntos'
                        : selectedType == RewardType.item
                            ? 'ID del Item'
                            : 'Valor',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    valueController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }

                setState(() => _isLoading = true);
                try {
                  final Reward updatedReward = Reward(
                    id: reward.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    iconUrl: iconUrlController.text,
                    type: selectedType,
                    value: int.parse(valueController.text),
                  );
                  await _rewardService.updateReward(updatedReward);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recompensa actualizada correctamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteRewardDialog(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Recompensa'),
        content: Text('¿Estás seguro de eliminar la recompensa "${reward.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _rewardService.deleteReward(reward.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recompensa eliminada correctamente')),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _showRewardDetails(Reward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reward.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getRewardTypeColor(reward.type).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getRewardTypeColor(reward.type),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: reward.iconUrl.isNotEmpty
                      ? Image.network(
                          reward.iconUrl,
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) => _getRewardTypeIcon(reward.type),
                        )
                      : _getRewardTypeIcon(reward.type),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Descripción: ${reward.description}'),
            const SizedBox(height: 8),
            Text('Tipo: ${_getRewardTypeName(reward.type)}'),
            const SizedBox(height: 8),
            Text('Valor: ${reward.value}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  // Diálogos para gestión de logros
  void _showAddAchievementDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController iconUrlController = TextEditingController();
    final List<String> requiredMissionIds = [];
    String selectedRewardId = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Añadir Nuevo Logro'),
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
                const SizedBox(height: 16),
                const Text('Recompensa Otorgada:'),
                ElevatedButton(
                  onPressed: () => _showSelectRewardDialog(
                    selectedRewardId: selectedRewardId,
                    onSelectionChanged: (String newRewardId) {
                      setState(() {
                        selectedRewardId = newRewardId;
                      });
                    },
                  ),
                  child: const Text('Seleccionar Recompensa'),
                ),
                Text(
                  selectedRewardId.isEmpty
                      ? 'Ninguna recompensa seleccionada'
                      : 'Recompensa seleccionada: $selectedRewardId',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    requiredMissionIds.isEmpty ||
                    selectedRewardId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }

                setState(() => _isLoading = true);
                try {
                  final String id = DateTime.now().millisecondsSinceEpoch.toString();
                  final Achievement newAchievement = Achievement(
                    id: id,
                    name: nameController.text,
                    description: descriptionController.text,
                    iconUrl: iconUrlController.text,
                    requiredMissionIds: requiredMissionIds,
                    rewardId: selectedRewardId,
                  );
                  await _rewardService.createAchievement(newAchievement);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logro creado correctamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAchievementDialog(Achievement achievement) {
    final TextEditingController nameController = TextEditingController(text: achievement.name);
    final TextEditingController descriptionController = TextEditingController(text: achievement.description);
    final TextEditingController iconUrlController = TextEditingController(text: achievement.iconUrl);
    final List<String> requiredMissionIds = List.from(achievement.requiredMissionIds);
    String selectedRewardId = achievement.rewardId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Logro'),
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
                const SizedBox(height: 16),
                const Text('Recompensa Otorgada:'),
                ElevatedButton(
                  onPressed: () => _showSelectRewardDialog(
                    selectedRewardId: selectedRewardId,
                    onSelectionChanged: (String newRewardId) {
                      setState(() {
                        selectedRewardId = newRewardId;
                      });
                    },
                  ),
                  child: const Text('Seleccionar Recompensa'),
                ),
                Text(
                  selectedRewardId.isEmpty
                      ? 'Ninguna recompensa seleccionada'
                      : 'Recompensa seleccionada: $selectedRewardId',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    requiredMissionIds.isEmpty ||
                    selectedRewardId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }

                setState(() => _isLoading = true);
                try {
                  final Achievement updatedAchievement = Achievement(
                    id: achievement.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    iconUrl: iconUrlController.text,
                    requiredMissionIds: requiredMissionIds,
                    rewardId: selectedRewardId,
                  );
                  await _rewardService.updateAchievement(updatedAchievement);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logro actualizado correctamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAchievementDialog(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Logro'),
        content: Text('¿Estás seguro de eliminar el logro "${achievement.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _rewardService.deleteAchievement(achievement.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logro eliminado correctamente')),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: achievement.iconUrl.isNotEmpty
                      ? Image.network(
                          achievement.iconUrl,
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.emoji_events, color: Colors.orange, size: 40),
                        )
                      : const Icon(Icons.emoji_events, color: Colors.orange, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Descripción: ${achievement.description}'),
            const SizedBox(height: 8),
            Text('Misiones requeridas: ${achievement.requiredMissionIds.length}'),
            const SizedBox(height: 8),
            Text('ID de Recompensa: ${achievement.rewardId}'),
            const SizedBox(height: 16),
            FutureBuilder<Reward?>(
              future: _rewardService.getRewardById(achievement.rewardId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reward = snapshot.data;
                if (reward == null) {
                  return const Text('Recompensa no encontrada');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recompensa:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Nombre: ${reward.name}'),
                    Text('Descripción: ${reward.description}'),
                    Text('Tipo: ${_getRewardTypeName(reward.type)}'),
                    Text('Valor: ${reward.value}'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  String _getRewardTypeName(RewardType type) {
    switch (type) {
      case RewardType.points:
        return 'Puntos';
      case RewardType.item:
        return 'Item';
      case RewardType.badge:
        return 'Insignia';
    }
  }

  void _showSelectMissionsDialog({
    required List<String> selectedMissions,
    required Function(List<String>) onSelectionChanged,
  }) {
    final List<String> tempSelection = List.from(selectedMissions);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Seleccionar Misiones'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('missions').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final missions = snapshot.data?.docs ?? [];
                if (missions.isEmpty) {
                  return const Center(child: Text('No hay misiones disponibles'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: missions.length,
                  itemBuilder: (context, index) {
                    final mission = missions[index];
                    final missionId = mission.id;
                    final missionName = mission.get('name') as String? ?? 'Misión sin nombre';
                    final isSelected = tempSelection.contains(missionId);
                    return CheckboxListTile(
                      title: Text(missionName),
                      subtitle: Text('ID: $missionId'),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!tempSelection.contains(missionId)) {
                              tempSelection.add(missionId);
                            }
                          } else {
                            tempSelection.remove(missionId);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                onSelectionChanged(tempSelection);
                Navigator.pop(context);
              },
              child: const Text('SELECCIONAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectRewardDialog({
    required String selectedRewardId,
    required Function(String) onSelectionChanged,
  }) {
    String tempSelection = selectedRewardId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Seleccionar Recompensa'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<Reward>>(
              stream: _rewardService.getRewards(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final rewards = snapshot.data ?? [];
                if (rewards.isEmpty) {
                  return const Center(child: Text('No hay recompensas disponibles'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    return RadioListTile<String>(
                      title: Text(reward.name),
                      subtitle: Text('${_getRewardTypeName(reward.type)} - ${reward.description}'),
                      value: reward.id,
                      groupValue: tempSelection,
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            tempSelection = value;
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                onSelectionChanged(tempSelection);
                Navigator.pop(context);
              },
              child: const Text('SELECCIONAR'),
            ),
          ],
        ),
      ),
    );
  }
}

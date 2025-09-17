import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../services/mission_service.dart';
import '../../services/user_service.dart'; // Importar UserService
import '../../services/auth_service.dart'; // Importar AuthService
import 'mission_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el usuario actual

/// Pantalla que muestra todas las misiones disponibles
class MissionListScreen extends StatefulWidget {
  final GlobalKey? missionListKey;
  final GlobalKey? filterButtonKey;

  const MissionListScreen({
    super.key,
    this.missionListKey,
    this.filterButtonKey,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MissionListScreenState createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  final MissionService _missionService = MissionService();
  final UserService _userService = UserService(); // Instancia de UserService
  final AuthService _authService = AuthService(); // Instancia de AuthService

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;
  
  // Estados para el filtro
  String _filterType = 'all'; // 'all', 'completed', 'available', 'locked'
  String _levelFilter = 'all'; // 'all', 'beginner', 'intermediate', 'advanced'

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      // Usar Future.microtask en lugar de addPostFrameCallback para evitar bucles infinitos
      Future.microtask(() {
        if (mounted) {
          _loadCurrentUserAndData();
        }
      });
    }
  }

  Future<void> _loadCurrentUserAndData() async {
    setState(() {
      _isLoadingUser = true;
    });
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _userData = await _userService.getUserData(_currentUser!.uid);
    }
    if (mounted) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  bool _isMissionUnlocked(
    MissionModel mission,
    Map<String, dynamic>? userData,
  ) {
    if (userData == null) {
      return false; // Si no hay datos de usuario, bloquear por defecto
    }

    final int userLevel = userData['level'] ?? 1;
    final List<String> completedMissions = List<String>.from(
      userData['completedMissions'] ?? [],
    );

    if (userLevel < mission.levelRequired) {
      return false;
    }

    if (mission.requirements?.completedMissionId != null &&
        mission.requirements!.completedMissionId!.isNotEmpty &&
        !completedMissions.contains(
          mission.requirements!.completedMissionId!,
        )) {
      return false;
    }
    // Aquí se podrían añadir otras comprobaciones de requisitos si existen en mission.requirements

    return true;
  }

  String _getLockReason(MissionModel mission, Map<String, dynamic>? userData) {
    if (userData == null) return "Cargando datos del usuario...";

    final int userLevel = userData['level'] ?? 1;
    final List<String> completedMissions = List<String>.from(
      userData['completedMissions'] ?? [],
    );

    if (userLevel < mission.levelRequired) {
      return "Nivel requerido: ${mission.levelRequired}";
    }

    if (mission.requirements?.completedMissionId != null &&
        mission.requirements!.completedMissionId!.isNotEmpty &&
        !completedMissions.contains(
          mission.requirements!.completedMissionId!,
        )) {
      // Para obtener el nombre de la misión prerrequisito, necesitaríamos cargarla.
      // Por simplicidad, solo mostramos el ID o un mensaje genérico.
      // Si tienes acceso a todas las misiones aquí, podrías buscarla por ID.
      return "Requiere completar la misión: ${mission.requirements!.completedMissionId!}";
    }
    return "Requisitos no cumplidos";
  }



  List<MissionModel> _applyFilters(List<MissionModel> missions) {
    return missions.where((mission) {
      final bool isUnlocked = _isMissionUnlocked(mission, _userData);
      final List<String> completedMissions = List<String>.from(
        _userData?['completedMissions'] ?? [],
      );
      final bool isCompleted = completedMissions.contains(mission.missionId);

      // Filtro por estado
      if (_filterType != 'all') {
        switch (_filterType) {
          case 'completed':
            if (!isCompleted) return false;
            break;
          case 'available':
            if (!isUnlocked || isCompleted) return false;
            break;
          case 'locked':
            if (isUnlocked) return false;
            break;
        }
      }

      // Filtro por nivel
      if (_levelFilter != 'all') {
        switch (_levelFilter) {
          case 'beginner':
            if (mission.levelRequired > 3) return false;
            break;
          case 'intermediate':
            if (mission.levelRequired <= 3 || mission.levelRequired > 6) return false;
            break;
          case 'advanced':
            if (mission.levelRequired <= 6) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildModernRadioOption(String title, String value, String groupValue, ValueChanged<String> onChanged) {
    final isSelected = value == groupValue;
    
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtrar Misiones'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estado de completado:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildModernRadioOption('Todas', 'all', _filterType, (value) => setDialogState(() => _filterType = value)),
                  _buildModernRadioOption('Completadas', 'completed', _filterType, (value) => setDialogState(() => _filterType = value)),
                  _buildModernRadioOption('Disponibles', 'available', _filterType, (value) => setDialogState(() => _filterType = value)),
                  _buildModernRadioOption('Bloqueadas', 'locked', _filterType, (value) => setDialogState(() => _filterType = value)),
                  const SizedBox(height: 16),
                  const Text('Nivel de dificultad:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildModernRadioOption('Todos los niveles', 'all', _levelFilter, (value) => setDialogState(() => _levelFilter = value)),
                  _buildModernRadioOption('Principiante (1-3)', 'beginner', _levelFilter, (value) => setDialogState(() => _levelFilter = value)),
                  _buildModernRadioOption('Intermedio (4-6)', 'intermediate', _levelFilter, (value) => setDialogState(() => _levelFilter = value)),
                  _buildModernRadioOption('Avanzado (7+)', 'advanced', _levelFilter, (value) => setDialogState(() => _levelFilter = value)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _filterType = 'all';
                      _levelFilter = 'all';
                    });
                  },
                  child: const Text('Limpiar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Los filtros ya están actualizados
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.currentUser == null) {
      return const Center(
        child: Text('Por favor, inicia sesión para ver las misiones.'),
      );
    }
    if (_isLoadingUser) {
      return const Center(
        child: CircularProgressIndicator(key: Key('loading_user_data')),
      );
    }
    return StreamBuilder<List<MissionModel>>(
      stream:
          _missionService
              .getMissions(), // Corregido: getMissions y MissionModel
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar misiones: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final missions = snapshot.data;

        if (missions == null || missions.isEmpty) {
          return const Center(child: Text('No hay misiones disponibles.'));
        }

        // Aplicar filtros
        final filteredMissions = _applyFilters(missions);

        return Column(
          children: [
            // Botón de filtro
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                key: widget.filterButtonKey,
                onPressed: () {
                  _showFilterDialog();
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Filtrar Misiones'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            // Lista de misiones
            Expanded(
              child: ListView.separated(
                key: widget.missionListKey,
                // Mostrar misiones filtradas + 1 casilla fija al final
                itemCount: filteredMissions.length + 1,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
            // Entrada final fija
            if (index == filteredMissions.length) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.grey[300],
                child: const ListTile(
                  leading: Icon(Icons.upcoming, color: Colors.black45),
                  title: Text(
                    'Más misiones en camino...',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            final mission = filteredMissions[index];
            final bool isUnlocked = _isMissionUnlocked(mission, _userData);
            final List<String> completedMissions = List<String>.from(
              _userData?['completedMissions'] ?? [],
            );
            final bool isCompleted = completedMissions.contains(
              mission.missionId,
            );

            String subtitleText =
                '${mission.description}\nZona: ${mission.zone} - Nivel Requerido: ${mission.levelRequired}';
            if (!isUnlocked) {
              subtitleText +=
                  '\nBloqueada: ${_getLockReason(mission, _userData)}';
            } else if (isCompleted) {
              subtitleText += '\n✅ ¡Completada!';
            }

            Color? cardColor;
            if (isCompleted) {
              cardColor =
                  Colors.green[100]; // Verde claro para misiones completadas
            } else if (!isUnlocked) {
              cardColor = Colors.grey[350]; // Gris para misiones bloqueadas
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: cardColor,
              child: ListTile(
                leading: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : (isUnlocked ? Icons.explore : Icons.lock),
                  color:
                      isCompleted
                          ? Colors.green
                          : (isUnlocked
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey),
                ),
                title: Text(
                  mission.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isCompleted
                            ? Colors.green[800]
                            : (isUnlocked ? null : Colors.black54),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  subtitleText,
                  style: TextStyle(
                    color:
                        isCompleted
                            ? Colors.green[700]
                            : (isUnlocked ? null : Colors.black54),
                  ),
                ),
                trailing:
                    isCompleted
                        ? null // Eliminar el icono duplicado para misiones completadas
                        : (isUnlocked
                            ? const Icon(Icons.arrow_forward_ios)
                            : null),
                onTap:
                    (isUnlocked || isCompleted)
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MissionDetailScreen(
                                    missionId: mission.missionId,
                                  ),
                            ),
                          );
                        }
                        : null, // Deshabilitar onTap solo si está bloqueada y no completada
              ),
            );
          },
        ),
      ),
    ],
  );
      },
    );
  }
}

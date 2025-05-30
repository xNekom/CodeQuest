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

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndData();
  }

  Future<void> _loadCurrentUserAndData() async {
    setState(() { _isLoadingUser = true; });
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _userData = await _userService.getUserData(_currentUser!.uid);
    }
    if (mounted) {
      setState(() { _isLoadingUser = false; });
    }
  }

  bool _isMissionUnlocked(MissionModel mission, Map<String, dynamic>? userData) {
    if (userData == null) return false; // Si no hay datos de usuario, bloquear por defecto

    final int userLevel = userData['level'] ?? 1;
    final List<String> completedMissions = List<String>.from(userData['completedMissions'] ?? []);

    if (userLevel < mission.levelRequired) {
      return false;
    }

    if (mission.requirements?.completedMissionId != null &&
        mission.requirements!.completedMissionId!.isNotEmpty &&
        !completedMissions.contains(mission.requirements!.completedMissionId!)) {
      return false;
    }
    // Aquí se podrían añadir otras comprobaciones de requisitos si existen en mission.requirements

    return true;
  }

  String _getLockReason(MissionModel mission, Map<String, dynamic>? userData) {
    if (userData == null) return "Cargando datos del usuario...";

    final int userLevel = userData['level'] ?? 1;
    final List<String> completedMissions = List<String>.from(userData['completedMissions'] ?? []);

    if (userLevel < mission.levelRequired) {
      return "Nivel requerido: ${mission.levelRequired}";
    }

    if (mission.requirements?.completedMissionId != null &&
        mission.requirements!.completedMissionId!.isNotEmpty &&
        !completedMissions.contains(mission.requirements!.completedMissionId!)) {
      // Para obtener el nombre de la misión prerrequisito, necesitaríamos cargarla.
      // Por simplicidad, solo mostramos el ID o un mensaje genérico.
      // Si tienes acceso a todas las misiones aquí, podrías buscarla por ID.
      return "Requiere completar la misión: ${mission.requirements!.completedMissionId!}";
    }
    return "Requisitos no cumplidos";
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.currentUser == null) {
      return const Center(child: Text('Por favor, inicia sesión para ver las misiones.'));
    }
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator(key: Key('loading_user_data')));
    }
    return StreamBuilder<List<MissionModel>>(
      stream: _missionService.getMissions(), // Corregido: getMissions y MissionModel
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar misiones: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final missions = snapshot.data;

        if (missions == null || missions.isEmpty) {
          return const Center(child: Text('No hay misiones disponibles.'));
        }

                return ListView.separated(
          key: widget.missionListKey,
          // Mostrar misiones + 1 casilla fija al final
          itemCount: missions.length + 1,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            // Entrada final fija
            if (index == missions.length) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.grey[300],
                child: const ListTile(
                  leading: Icon(Icons.upcoming, color: Colors.black45),
                  title: Text('Más misiones en camino...', style: TextStyle(color: Colors.black54)),
                ),
              );
            }
            final mission = missions[index];
            final bool isUnlocked = _isMissionUnlocked(mission, _userData);
            String subtitleText = '${mission.description}\nZona: ${mission.zone} - Nivel Requerido: ${mission.levelRequired}';
            if (!isUnlocked) {
              subtitleText += '\nBloqueada: ${_getLockReason(mission, _userData)}';
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: isUnlocked ? null : Colors.grey[350], // Color de fondo si está bloqueada
              child: ListTile(
                key: index == 0 ? widget.filterButtonKey : null, // Usar filterButtonKey para la primera misión como ejemplo
                leading: Icon(
                  isUnlocked ? Icons.explore : Icons.lock, // Icono de candado si está bloqueada
                  color: isUnlocked ? Theme.of(context).colorScheme.secondary : Colors.grey,
                ),
                title: Text(mission.name, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? null : Colors.black54)),
                subtitle: Text(subtitleText, style: TextStyle(color: isUnlocked ? null : Colors.black54)),
                trailing: isUnlocked ? const Icon(Icons.arrow_forward_ios) : null,
                onTap: isUnlocked
                    ? () {
                        Navigator.push(
                          context,
                          // Reemplaza FadePageRoute con MaterialPageRoute si FadePageRoute no está definido o causa problemas
                          MaterialPageRoute(
                            builder: (context) => MissionDetailScreen(missionId: mission.missionId),
                          ),
                        );
                      }
                    : null, // Deshabilitar onTap si está bloqueada
              ),
            );
          },
        );
      },
    );
  }
}

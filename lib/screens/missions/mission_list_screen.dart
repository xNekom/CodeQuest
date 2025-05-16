import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../services/mission_service.dart';
import '../../services/user_service.dart'; // Importar UserService
import '../../services/auth_service.dart'; // Importar AuthService
import 'mission_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el usuario actual

/// Pantalla que muestra todas las misiones disponibles
class MissionListScreen extends StatefulWidget {
  const MissionListScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndData();
  }

  Future<void> _loadCurrentUserAndData() async {
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _userData = await _userService.getUserData(_currentUser!.uid);
    }
    if (mounted) {
      setState(() {});
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
    if (_currentUser == null && _authService.currentUser == null) {
      // Aún no se ha intentado cargar o no hay usuario. Podrías mostrar un login o un mensaje.
      // Si AuthService.currentUser es null persistentemente, indica que nadie ha iniciado sesión.
      return const Center(child: Text("Por favor, inicia sesión para ver las misiones."));
    }
    if (_currentUser != null && _userData == null) {
      // Usuario cargado, pero datos pendientes
      return const Center(child: CircularProgressIndicator());
    }
    // Si _currentUser es null pero _authService.currentUser no lo es, significa que initState está en proceso o falló al setear _currentUser
    // Esta condición es para el caso en que _loadCurrentUserAndData no haya completado la asignación de _userData aún.
    if (_authService.currentUser != null && _userData == null) {
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
          itemCount: missions.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
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

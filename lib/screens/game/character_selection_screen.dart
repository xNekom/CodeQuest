import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../services/tutorial_service.dart';
import '../../widgets/character_asset.dart';
import '../../widgets/tutorial_floating_button.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  bool _isLoading = true;
  bool _isEditing = false; // Nueva variable de estado
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  int _selectedCharacterIndex = 0;
  String _selectedProgrammingRole = 'Desarrollador Full Stack';

  final List<String> _programmingRoles = [
    'Desarrollador Full Stack',
    'Desarrollador Frontend',
    'Desarrollador Backend',
    'DevOps Engineer',
    'Data Scientist',
    'Mobile Developer',
    'Game Developer',
    'UI/UX Designer',
    'QA Engineer',
    'Cybersecurity Specialist',
    'Machine Learning Engineer',
    'Cloud Architect',
  ];
  final UserService _userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _characterPreviewKey = GlobalKey();
  final GlobalKey _customizationKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _checkAndStartTutorial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      // Usar Future.microtask en lugar de addPostFrameCallback para evitar bucles infinitos
      Future.microtask(() {
        if (mounted) {
          _loadExistingData();
        }
      });
    }
  }

  /// Inicia el tutorial si es necesario
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      TutorialService.startTutorialIfNeeded(
        context,
        TutorialService.characterSelectionTutorial,
        TutorialService.getCharacterSelectionTutorial(
          characterPreviewKey: _characterPreviewKey,
          customizationKey: _customizationKey,
          saveButtonKey: _saveButtonKey,
        ),
      );
    }
  }

  Future<void> _loadExistingData() async {
    if (user != null) {
      final data = await _userService.getUserData(user!.uid);
      if (data != null) {
        // Usar el username como nombre del héroe y hacerlo no editable
        _nameCtrl.text = data['username'] as String? ?? '';

        if (data['characterSelected'] as bool? ?? false) {
          _selectedCharacterIndex = data['characterAssetIndex'] as int? ?? 0;
          _selectedProgrammingRole =
              data['programmingRole'] as String? ?? 'Desarrollador Full Stack';
          _isEditing = true;
        }
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Editar Selección de Personaje'
              : 'Selección de Personaje',
        ),
      ), // Título dinámico
      floatingActionButton: TutorialFloatingButton(
        tutorialKey: TutorialService.characterSelectionTutorial,
        tutorialSteps: TutorialService.getCharacterSelectionTutorial(
          characterPreviewKey: _characterPreviewKey,
          customizationKey: _customizationKey,
          saveButtonKey: _saveButtonKey,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = constraints.maxWidth < 600;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isPortrait ? 8 : 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vista previa del personaje con navegación
                    SizedBox(
                      key: _characterPreviewKey,
                      height: isPortrait ? 260 : 280,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.brown.shade700,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              onPressed:
                                  () => setState(() {
                                    _selectedCharacterIndex =
                                        _selectedCharacterIndex > 0
                                            ? _selectedCharacterIndex - 1
                                            : 8; // Volver al último asset (índice 8)
                                  }),
                              icon: const Icon(Icons.keyboard_arrow_left),
                              iconSize: 32,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CharacterAsset(
                                    assetIndex: _selectedCharacterIndex,
                                    size: isPortrait ? 200 : 220,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    CharacterAsset
                                        .characterNames[_selectedCharacterIndex],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.brown.shade700,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              onPressed:
                                  () => setState(() {
                                    _selectedCharacterIndex =
                                        _selectedCharacterIndex < 8
                                            ? _selectedCharacterIndex + 1
                                            : 0; // Volver al primer asset (índice 0)
                                  }),
                              icon: const Icon(Icons.keyboard_arrow_right),
                              iconSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isPortrait ? 8 : 16),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de tu héroe (Nick)',
                      ), // Etiqueta actualizada
                      readOnly: true, // Hacer el campo no editable
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'El nombre del héroe no puede estar vacío'
                                  : null,
                    ),
                    SizedBox(height: isPortrait ? 8 : 12),
                    DropdownButtonFormField<String>(
                      key: _customizationKey,
                      value: _selectedProgrammingRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol de Programación',
                        helperText:
                            'Selecciona tu especialidad en programación',
                      ),
                      items:
                          _programmingRoles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedProgrammingRole = v);
                        }
                      },
                    ),
                    SizedBox(height: isPortrait ? 8 : 16),
                    ElevatedButton(
                      key: _saveButtonKey,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // Guardar los nuevos datos del personaje
                          await _userService.updateUserData(user.uid, {
                            'characterName': _nameCtrl.text,
                            'characterAssetIndex': _selectedCharacterIndex,
                            'programmingRole': _selectedProgrammingRole,
                            'characterSelected': true,
                          });
                          if (!context.mounted) return;
                          // Feedback visual dinámico
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isEditing
                                    ? '¡Personaje actualizado!'
                                    : '¡Personaje seleccionado!',
                              ),
                            ),
                          );
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      child: Text(
                        _isEditing ? 'Guardar Cambios' : 'Comenzar aventura',
                      ), // Texto del botón dinámico
                    ),
                    if (!isPortrait) const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

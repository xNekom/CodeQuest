import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../services/tutorial_service.dart';
import '../../widgets/character_pixelart.dart';
import '../../widgets/tutorial_floating_button.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  bool _isLoading = true;
  bool _isEditing = false; // Nueva variable de estado
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _selectedClass = 'Warrior';
  String _selectedSkinTone = 'Claro';
  String _selectedHairStyle = 'Corto';
  String _selectedOutfit = 'Aventurero';
  final UserService _userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  // GlobalKeys para el sistema de tutoriales
  final GlobalKey _characterPreviewKey = GlobalKey();
  final GlobalKey _classSelectionKey = GlobalKey();
  final GlobalKey _customizationKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _checkAndStartTutorial();
  }

  /// Inicia el tutorial si es necesario
  Future<void> _checkAndStartTutorial() async {
    // Esperar a que la UI se construya completamente
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      TutorialService.startTutorialIfNeeded(
        context,
        TutorialService.characterCreationTutorial,
        TutorialService.getCharacterCreationTutorial(
          characterPreviewKey: _characterPreviewKey,
          classSelectionKey: _classSelectionKey,
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
        
        if (data['characterCreated'] as bool? ?? false) {
          _selectedClass = data['characterClass'] as String? ?? _selectedClass;
          _selectedSkinTone = data['skinTone'] as String? ?? _selectedSkinTone;
          _selectedHairStyle = data['hairStyle'] as String? ?? _selectedHairStyle;
          _selectedOutfit = data['outfit'] as String? ?? _selectedOutfit;
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar tu Héroe' : 'Crear Tu Héroe')), // Título dinámico
      floatingActionButton: TutorialFloatingButton(
        tutorialKey: TutorialService.characterCreationTutorial,
        tutorialSteps: TutorialService.getCharacterCreationTutorial(
          characterPreviewKey: _characterPreviewKey,
          classSelectionKey: _classSelectionKey,
          customizationKey: _customizationKey,
          saveButtonKey: _saveButtonKey,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxWidth < 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [                  // Vista previa del personaje pixel art
                  Center(
                    key: _characterPreviewKey,
                    child: CharacterPixelArt(
                      skinTone: _selectedSkinTone,
                      hairStyle: _selectedHairStyle,
                      outfit: _selectedOutfit,
                      size: 120,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre de tu héroe (Nick)'), // Etiqueta actualizada
                    readOnly: true, // Hacer el campo no editable
                    validator: (v) => v == null || v.isEmpty ? 'El nombre del héroe no puede estar vacío' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: _classSelectionKey,
                    value: _selectedClass,
                    decoration: const InputDecoration(labelText: 'Clase'),
                    items: const [
                      DropdownMenuItem(value: 'Warrior', child: Text('Guerrero')),
                      DropdownMenuItem(value: 'Mage', child: Text('Mago')),
                      DropdownMenuItem(value: 'Rogue', child: Text('Pícaro')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedClass = v);
                    },
                  ),
                  const SizedBox(height: 16),                  DropdownButtonFormField<String>(
                    value: _selectedSkinTone,
                    decoration: const InputDecoration(labelText: 'Tono de piel'),
                    items: const [
                      DropdownMenuItem(value: 'Claro', child: Text('Claro')),
                      DropdownMenuItem(value: 'Medio', child: Text('Medio')),
                      DropdownMenuItem(value: 'Oscuro', child: Text('Oscuro')),
                    ],
                    onChanged: (v) { if (v != null) setState(() => _selectedSkinTone = v); },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: _customizationKey,
                    value: _selectedHairStyle,
                    decoration: const InputDecoration(labelText: 'Peinado'),
                    items: const [
                      DropdownMenuItem(value: 'Corto', child: Text('Corto')),
                      DropdownMenuItem(value: 'Largo', child: Text('Largo')),
                      DropdownMenuItem(value: 'Moño', child: Text('Moño')),
                    ],
                    onChanged: (v) { if (v != null) setState(() => _selectedHairStyle = v); },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedOutfit,
                    decoration: const InputDecoration(labelText: 'Ropa'),
                    items: const [
                      DropdownMenuItem(value: 'Aventurero', child: Text('Aventurero')),
                      DropdownMenuItem(value: 'Mago', child: Text('Mago')),
                      DropdownMenuItem(value: 'Sigiloso', child: Text('Sigiloso')),
                    ],
                    onChanged: (v) { if (v != null) setState(() => _selectedOutfit = v); },
                  ),                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: _saveButtonKey,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // Asegurarse de que el username (que está en _nameCtrl) se guarde como characterName
                        await _userService.updateUserData(user.uid, {
                          'characterName': _nameCtrl.text, // _nameCtrl.text contendrá el username
                          'characterClass': _selectedClass,
                          'skinTone': _selectedSkinTone,
                          'hairStyle': _selectedHairStyle,
                          'outfit': _selectedOutfit,
                          'characterCreated': true,
                        });
                        if (!context.mounted) return;
                        // Feedback visual dinámico
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? '¡Personaje actualizado!' : '¡Personaje creado!')));
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: Text(_isEditing ? 'Guardar Cambios' : 'Comenzar aventura'), // Texto del botón dinámico
                  ),
                  if (!isPortrait) const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../widgets/character_pixelart.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _selectedClass = 'Warrior';
  String _selectedSkinTone = 'Claro';
  String _selectedHairStyle = 'Corto';
  String _selectedOutfit = 'Aventurero';
  final UserService _userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    if (user != null) {
      final data = await _userService.getUserData(user!.uid);
      if (data != null && (data['characterCreated'] as bool? ?? false)) {
        _nameCtrl.text = data['characterName'] as String? ?? '';
        _selectedClass = data['characterClass'] as String? ?? _selectedClass;
        _selectedSkinTone = data['skinTone'] as String? ?? _selectedSkinTone;
        _selectedHairStyle = data['hairStyle'] as String? ?? _selectedHairStyle;
        _selectedOutfit = data['outfit'] as String? ?? _selectedOutfit;
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
      appBar: AppBar(title: const Text('Crear Tu Héroe')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxWidth < 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vista previa del personaje pixel art
                  Center(
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
                    decoration: const InputDecoration(labelText: 'Nombre de tu héroe'),
                    validator: (v) => v == null || v.isEmpty ? 'Ingresa un nombre' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
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
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await _userService.updateUserData(user.uid, {
                          'characterName': _nameCtrl.text,
                          'characterClass': _selectedClass,
                          'skinTone': _selectedSkinTone,
                          'hairStyle': _selectedHairStyle,
                          'outfit': _selectedOutfit,
                          'characterCreated': true,
                        });
                        if (!context.mounted) return;
                        // Feedback visual
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personaje creado!')));
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: const Text('Comenzar aventura'),
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

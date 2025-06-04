import 'package:flutter/material.dart';

class CharacterAsset extends StatelessWidget {
  final int assetIndex;
  final double size;

  const CharacterAsset({super.key, required this.assetIndex, this.size = 150});

  // Lista de nombres creativos para cada personaje
  static const List<String> characterNames = [
    'Alex CodeMaster',
    'Luna ByteWizard',
    'Max PixelHero',
    'Zara DataQueen',
    'Neo CyberKnight',
    'Aria ScriptSage',
    'Kai LogicLord',
    'Nova TechStar',
    'Rex BugHunter',
  ];

  String get characterName {
    if (assetIndex < characterNames.length) {
      return characterNames[assetIndex];
    }
    return 'Héroe ${assetIndex + 1}';
  }

  String get characterImagePath {
    return 'assets/images/characters/character_${assetIndex + 1}.png';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        characterImagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: size * 0.7,
            color: Colors.grey.shade600,
          );
        },
      ),
    );
  }
}

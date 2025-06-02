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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              characterImagePath,
              width: size * 0.9,
              height: size * 0.9,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: size * 0.7,
                  color: Colors.grey.shade600,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

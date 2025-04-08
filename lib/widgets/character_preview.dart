import 'package:flutter/material.dart';

class CharacterPreview extends StatelessWidget {
  final String skinTone;
  final String hairStyle;
  final String outfit;
  final double size;

  const CharacterPreview({
    super.key,
    required this.skinTone,
    required this.hairStyle,
    required this.outfit,
    this.size = 150,
  });

  Color _toneColor() {
    switch (skinTone) {
      case 'Claro': return Colors.brown.shade200;
      case 'Medio': return Colors.brown.shade400;
      case 'Oscuro': return Colors.brown;
      default: return Colors.grey;
    }
  }

  IconData _hairIcon() {
    switch (hairStyle) {
      case 'Corto': return Icons.person;
      case 'Largo': return Icons.person_outline;
      case 'Moño': return Icons.face;
      default: return Icons.person;
    }
  }

  IconData _outfitIcon() {
    switch (outfit) {
      case 'Aventurero': return Icons.backpack;
      case 'Mago': return Icons.auto_fix_high;
      case 'Sigiloso': return Icons.nightlight_round;
      default: return Icons.checkroom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Skin background
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _toneColor(),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          // Outfit layer
          Icon(
            _outfitIcon(),
            size: size * 0.6,
            color: Colors.blueGrey,
          ),
          // Hair layer
          Positioned(
            top: size * 0.2,
            child: Icon(
              _hairIcon(),
              size: size * 0.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CharacterPixelArt extends StatelessWidget {
  final String skinTone;
  final String hairStyle;
  final String outfit;
  final double size;

  const CharacterPixelArt({
    super.key,
    required this.skinTone,
    required this.hairStyle,
    required this.outfit,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _PixelArtPainter(skinTone, hairStyle, outfit),
      ),
    );
  }
}

class _PixelArtPainter extends CustomPainter {
  final String skinTone;
  final String hairStyle;
  final String outfit;
  _PixelArtPainter(this.skinTone, this.hairStyle, this.outfit);

  Color _getSkinColor() {
    switch (skinTone) {
      case 'Claro': return const Color(0xFFF5CBA7);
      case 'Medio': return const Color(0xFFD2B48C);
      case 'Oscuro': return const Color(0xFF8D5524);
      default: return Colors.grey;
    }
  }

  Color _getHairColor() {
    return Colors.black;
  }

  Color _getOutfitColor() {
    switch (outfit) {
      case 'Aventurero': return Colors.green;
      case 'Mago': return Colors.purple;
      case 'Sigiloso': return Colors.brown;
      default: return Colors.blueGrey;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final int grid = 10;
    final double cell = size.width / grid;

    // Dibujar piel: cabeza 4x4 en centro superior
    paint.color = _getSkinColor();
    for (int x = 3; x < 7; x++) {
      for (int y = 2; y < 6; y++) {
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
      }
    }

    // Dibujar pelo según estilo
    paint.color = _getHairColor();
    if (hairStyle == 'Corto') {
      for (int x = 3; x < 7; x++) {
        canvas.drawRect(Rect.fromLTWH(x * cell, 1 * cell, cell, cell), paint);
      }
    } else if (hairStyle == 'Largo') {
      for (int x = 3; x < 7; x++) {
        for (int y = 1; y < 4; y++) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    } else if (hairStyle == 'Moño') {
      // moño arriba centro
      canvas.drawRect(Rect.fromLTWH(4 * cell, 0 * cell, cell, cell), paint);
      canvas.drawRect(Rect.fromLTWH(5 * cell, 0 * cell, cell, cell), paint);
    }

    // Dibujar cuerpo/ropa: rectángulo 4x4 debajo de cabeza
    paint.color = _getOutfitColor();
    for (int x = 3; x < 7; x++) {
      for (int y = 6; y < 10; y++) {
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelArtPainter old) {
    return old.skinTone != skinTone || old.hairStyle != hairStyle || old.outfit != outfit;
  }
}

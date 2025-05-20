import 'package:flutter/material.dart';

class PixelArtBackground extends StatelessWidget {
  final Widget child;
  const PixelArtBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: reemplazar con Image.asset de tu fondo pixel art
      color: Colors.black,
      child: child,
    );
  }
}
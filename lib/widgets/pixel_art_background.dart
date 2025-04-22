import 'package:flutter/material.dart';

class PixelArtBackground extends StatelessWidget {
  final Widget child;
  const PixelArtBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: reemplazar con Image.asset de tu fondo pixel art
      color: Colors.black,
      child: child,
    );
  }
}
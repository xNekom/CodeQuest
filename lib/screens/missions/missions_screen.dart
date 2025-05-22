import 'package:flutter/material.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Misiones'),
      ),
      body: const Center(
        child: Text('Pantalla de Misiones'),
      ),
    );
  }
}

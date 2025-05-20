import 'package:flutter/material.dart';
import 'mission_list_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MISIÓN',
          style: TextStyle(fontFamily: 'PixelFont', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Leading por defecto para volver atrás
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: const MissionListScreen(),
        ),
      ),
    );
  }
}

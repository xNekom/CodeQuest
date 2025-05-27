import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../main.dart' show scaffoldMessengerKey;

/// Widget para probar diferentes tipos de errores
/// Se usa durante el desarrollo para verificar el funcionamiento del manejador de errores
class TestErrorWidget extends StatelessWidget {
  const TestErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.bug_report, color: Colors.grey),
      tooltip: 'Generar errores de prueba (solo dev)',
      onSelected: (value) => _generateTestError(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'sync',
          child: Text('Error Síncrono'),
        ),
        const PopupMenuItem(
          value: 'async',
          child: Text('Error Asíncrono'),
        ),
        const PopupMenuItem(
          value: 'firebase',
          child: Text('Error Firebase'),
        ),
        const PopupMenuItem(
          value: 'critical',
          child: Text('Error Crítico'),
        ),
        const PopupMenuItem(
          value: 'show_logs',
          child: Text('Ver Logs'),
        ),
      ],
    );
  }

  void _generateTestError(BuildContext context, String type) {
    switch (type) {
      case 'sync':
        try {
          // Generar un error síncrono
          final list = <String>[];
          // ignore: unused_local_variable
          final crash = list[5]; // Accediendo a un índice fuera de límites
        } catch (e, stack) {
          // Usar directamente el ScaffoldMessenger global
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: const Text('Error de prueba síncrono generado'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.fixed,
            ),
          );
          ErrorHandler.logError(e, stack);
        }
        break;
        
      case 'async':
        // Programar un error asíncrono
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            throw Exception('Este es un error asíncrono de prueba');
          } catch (e, stack) {
            // Usar directamente el ScaffoldMessenger global
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: const Text('Error asíncrono generado'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.fixed,
              ),
            );
            ErrorHandler.logError(e, stack);
          }
        });
        break;
        
      case 'firebase':
        try {
          // Simular un error de Firebase Auth
          throw FirebaseExceptionMock(
            code: 'permission-denied',
            message: 'Error de Firebase simulado para pruebas',
          );
        } catch (e, stack) {
          final message = ErrorHandler.handleError(e);
          ErrorHandler.showErrorDialog(
            context,
            'Error de Firebase',
            message,
          );
          ErrorHandler.logError(e, stack);
        }
        break;
        
      case 'critical':
        try {
          // Simular un error crítico
          throw Exception('Error crítico simulado para pruebas');
        } catch (e, stack) {
          ErrorHandler.handleCriticalError(context, e, stack);
        }
        break;
        
      case 'show_logs':
        Navigator.of(context).pushNamed('/error-logs');
        break;
    }
  }
}

/// Clase mock para simular errores de Firebase
class FirebaseExceptionMock implements Exception {
  final String code;
  final String? message;
  
  FirebaseExceptionMock({required this.code, this.message});
  
  @override
  String toString() => 'FirebaseException($code): $message';
}

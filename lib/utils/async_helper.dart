import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/error_handler.dart';

/// Ayudante para operaciones asíncronas que pueden fallar
/// Proporciona manejo de errores y estados de carga consistentes
class AsyncHelper {
  /// Ejecuta una operación asíncrona con manejo de estados de carga y errores
  static Future<T?> run<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String loadingMessage = 'Cargando...',
    String successMessage = '',
    bool showLoadingIndicator = true,
    bool showSuccessMessage = false,
    Function(T result)? onSuccess,
  }) async {
    try {
      // Mostrar indicador de carga si es necesario
      if (showLoadingIndicator) {
        _showLoadingDialog(context, loadingMessage);
      }
      
      // Ejecutar la operación
      final result = await operation();
      
      // Ocultar indicador de carga
      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Mostrar mensaje de éxito si es necesario
      if (showSuccessMessage && successMessage.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
      
      // Ejecutar callback de éxito si existe
      if (onSuccess != null) {
        onSuccess(result);
      }
      
      return result;
    } catch (e, stack) {
      // Ocultar indicador de carga si está visible
      if (showLoadingIndicator && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Manejar el error
      if (context.mounted) {
        final errorMessage = ErrorHandler.handleError(e);
        ErrorHandler.showError(context, errorMessage);
        ErrorHandler.logError(e, stack);
      }
      
      return null;
    }
  }
  
  /// Muestra un diálogo de carga
  static void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }
  /// Intenta una operación varias veces con manejo de errores
  static Future<T?> retry<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delayBetweenAttempts = const Duration(seconds: 1),
    bool rethrowError = false,
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        attempts++;
        return await operation();
      } catch (e, stack) {
        ErrorHandler.logError(e, stack);
        
        if (attempts >= maxAttempts) {
          if (context.mounted) {
            final errorMessage = ErrorHandler.handleError(e);
            ErrorHandler.showError(
              context,
              'Error después de $maxAttempts intentos: $errorMessage',
            );
          }
          
          if (rethrowError) {
            rethrow; // Propagar el error después de agotar los intentos
          }
          return null;
        }
        
        // Esperar antes del siguiente intento
        await Future.delayed(delayBetweenAttempts);
      }
    }
    return null;
  }
}

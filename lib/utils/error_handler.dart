import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../widgets/error_widgets.dart';
import '../screens/error_screen.dart';
import 'error_logger.dart';
import 'web_platform_handler.dart';
import '../main.dart' show scaffoldMessengerKey;

/// Clase que maneja los errores de forma global en la aplicación.
/// Proporciona métodos para mostrar mensajes de error de forma consistente
/// y para traducir errores específicos a mensajes amigables para el usuario.
class ErrorHandler {
  /// Muestra un SnackBar con un mensaje de error
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    try {
      // Intentar usar el ScaffoldMessenger del contexto actual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    } catch (e) {
      // Si falla, intentar con el contexto del Navigator root
      try {
        final navigatorContext = Navigator.of(context, rootNavigator: true).context;
        if (navigatorContext.mounted) {
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(navigatorContext).colorScheme.error,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.fixed,
            ),
          );
        }
      } catch (e2) {
         // Intentar con el ScaffoldMessenger global como último recurso
         try {
           scaffoldMessengerKey.currentState?.showSnackBar(
             SnackBar(
               content: Text(message),
               backgroundColor: Colors.red,
               duration: const Duration(seconds: 3),
               behavior: SnackBarBehavior.fixed,
             ),
           );
         } catch (e3) {
           // Como último recurso, mostrar un diálogo simple
           debugPrint('Error mostrando SnackBar: $e2');
           debugPrint('Error con ScaffoldMessenger global: $e3');
           debugPrint('Mensaje de error original: $message');
           showErrorDialog(context, 'Error', message);
         }
       }
    }
  }
  /// Muestra un diálogo con información detallada sobre un error
  static Future<void> showErrorDialog(BuildContext context, String title, String message) async {
    if (!context.mounted) return;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: PixelErrorMessage(
          message: message,
          showIcon: true,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
    // Variable estática para prevenir múltiples páginas de error simultáneas
  static bool _isShowingErrorPage = false;
  
  /// Muestra una página completa de error, útil cuando falla algo crítico
  static void showErrorPage(
    BuildContext context, {
    required String message, 
    String title = 'Error', 
    VoidCallback? onRetry, 
    VoidCallback? onBack,
    String? buttonText,
    String? backButtonText,
    IconData icon = Icons.error_outline,
  }) {
    if (!context.mounted) return;
    
    // Prevenir múltiples páginas de error simultáneas
    if (_isShowingErrorPage) {
      debugPrint('Previniendo múltiples páginas de error simultáneas');
      return;
    }
    
    _isShowingErrorPage = true;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ErrorScreen(
            message: message,
            title: title,
            onBack: onBack ?? () {
              Navigator.of(context).pop();
              // Resetear el flag cuando se cierra la página de error
              _isShowingErrorPage = false;
            },
            backButtonText: backButtonText,
            icon: icon,
          ),
        ),
      ).then((_) {
        // Resetear el flag cuando se cierra la página de error
        _isShowingErrorPage = false;
      });
    } catch (e) {
      debugPrint('Error al mostrar página de error: $e');
      _isShowingErrorPage = false;
    }
  }
  /// Procesa un error y devuelve un mensaje amigable para el usuario
  static String handleError(dynamic error) {
    // Registrar el error para depuración
    debugPrint('Error capturado: $error');
    
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else if (error.toString().contains('SocketException') || 
               error.toString().contains('TimeoutException')) {
      return _handleNetworkError(error);
    } else if (error is Exception) {
      return _handleCustomException(error);
    } else {
      return 'Ocurrió un error inesperado. Por favor intenta nuevamente.';
    }
  }

  /// Maneja excepciones personalizadas de la aplicación
  static String _handleCustomException(Exception error) {
    final errorMessage = error.toString();
    
    // Remover el prefijo 'Exception: ' si existe
    final cleanMessage = errorMessage.startsWith('Exception: ') 
        ? errorMessage.substring(11) 
        : errorMessage;
    
    // Verificar errores específicos conocidos
    if (cleanMessage.contains('El nombre de usuario ya está en uso')) {
      return 'Este nombre de usuario ya está registrado. Por favor elige otro nombre de usuario.';
    } else if (cleanMessage.contains('username') && cleanMessage.contains('already')) {
      return 'Este nombre de usuario ya está registrado. Por favor elige otro nombre de usuario.';
    } else if (cleanMessage.contains('email') && cleanMessage.contains('already')) {
      return 'Este correo electrónico ya está registrado. ¿Ya tienes una cuenta?';
    } else {
      // Para otros errores personalizados, devolver el mensaje limpio
      return cleanMessage.isNotEmpty ? cleanMessage : 'Ocurrió un error inesperado. Por favor intenta nuevamente.';
    }
  }

  /// Maneja errores específicos de Firebase Authentication
  static String _handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'La contraseña es incorrecta';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido desactivada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo más tarde';
      case 'operation-not-allowed':
        return 'El inicio de sesión con correo y contraseña no está habilitado';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'network-request-failed':
        return 'Error de red. Comprueba tu conexión a internet';
      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos';
      default:
        return 'Error de autenticación: ${error.message ?? 'Credenciales incorrectas'}';
    }
  }
  /// Maneja errores generales de Firebase
  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'No tienes permisos para realizar esta acción';
      case 'unavailable':
        return 'El servicio no está disponible. Verifica tu conexión';
      case 'internal':
        return 'Error interno del servidor. Intenta más tarde';
      default:
        return 'Error en Firebase: ${error.message ?? error.code}';
    }
  }
  
  /// Maneja errores de red y conectividad
  static String _handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No hay conexión a internet. Verifica tu red Wi-Fi o datos móviles.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'La conexión ha tardado demasiado tiempo. Verifica tu red e intenta nuevamente.';
    } else if (error.toString().contains('NetworkException') || 
               error.toString().contains('Connection refused')) {
      return 'Error de red. Verifica tu conexión a internet.';
    } else {
      return 'Error de conectividad. Verifica tu conexión e intenta nuevamente.';
    }
  }
  
  /// Registra un error en el sistema de registro
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    // Usar el nuevo sistema de registro en archivo
    ErrorLogger.log(
      'ERROR DETECTADO',
      error: error,
      stackTrace: stackTrace,
    );
    
    // También mantener el log en consola para debugging
    debugPrint('====== ERROR ======');
    debugPrint(error.toString());
    if (stackTrace != null) {
      debugPrint('------ Stack Trace ------');
      debugPrint(stackTrace.toString());
    }
    debugPrint('=====================');
  }  /// Configura manejadores globales de errores para toda la aplicación.
  /// Se debe llamar en el main() antes de runApp().
  static Future<void> setupGlobalErrorHandling() async {
    // Inicializar el sistema de logs
    await ErrorLogger.init();
    
    // Registrar inicio de la aplicación
    ErrorLogger.log('Aplicación iniciada');
    
    // Captura errores Flutter no manejados
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logError(details.exception, details.stack);
      
      // Registrar detalles adicionales que podrían ser útiles
      final errorMessage = details.exceptionAsString();
      final library = details.library ?? 'desconocida';
      ErrorLogger.log(
        'Error de Flutter en biblioteca $library',
        error: errorMessage,
        stackTrace: details.stack,
      );
    };
    
    // Captura errores asíncronos no manejados
    PlatformDispatcher.instance.onError = (error, stack) {
      // Verificar si es un error conocido de plataforma web
      if (kIsWeb && error.toString().contains('Unsupported operation: Platform._version')) {
        debugPrint('Ignorando error conocido de Platform en Web: $error');
        return true; // Ignorar este error específico
      }
      
      logError(error, stack);
      ErrorLogger.log('Error asíncrono no manejado', error: error, stackTrace: stack);
      // Retornando true para evitar que Flutter muestre su propio diálogo de error
      return true;
    };
  }
    // Variable estática para prevenir bucles infinitos en errores críticos
  static bool _isHandlingCriticalError = false;
  
  /// Analiza un error y decide si se debe mostrar al usuario
  static void handleCriticalError(
    BuildContext? context, 
    dynamic error, 
    StackTrace? stackTrace, {
    bool showToUser = true,
  }) {
    // Prevenir bucles infinitos
    if (_isHandlingCriticalError) {
      debugPrint('Previniendo bucle infinito en handleCriticalError: $error');
      return;
    }
    
    _isHandlingCriticalError = true;
    
    try {
      // Verificar si es un error web que podemos ignorar
      if (kIsWeb && WebPlatformHandler.shouldIgnoreWebError(error)) {
        debugPrint('Ignorando error web en handleCriticalError: $error');
        return;
      }
      
      // Registrar el error de forma segura
      try {
        logError(error, stackTrace);
      } catch (e) {
        debugPrint('Error al registrar error crítico: $e');
        debugPrint('Error original: $error');
      }
      
      // Mostrar al usuario si se requiere y si tenemos un contexto
      if (showToUser && context != null && context.mounted) {
        // Determinar el mensaje apropiado para el usuario
        final message = handleError(error);
        
        // Para errores críticos, muestra una página completa
        showErrorPage(
          context,
          message: message,
          title: 'Error inesperado',
          onRetry: () {
            // Usar Future.microtask para evitar bucles infinitos
            Future.microtask(() {
              if (!context.mounted) return;
              // Aquí puedes implementar una acción de reintentar específica
              // Por ejemplo, reiniciar la página actual
              Navigator.of(context).pop();
            });
          },
          onBack: () {
            // Usar Future.microtask para evitar bucles infinitos en la navegación
            Future.microtask(() {
              if (!context.mounted) return;
              
              // Para errores críticos, verificar si ya estamos en home para evitar bucles
              final currentRoute = ModalRoute.of(context)?.settings.name;
              
              if (currentRoute == '/home') {
                // Si ya estamos en home, solo hacer pop para cerrar la página de error
                Navigator.of(context).pop();
              } else {
                // Si no estamos en home, navegar al inicio
                try {
                  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                    '/home',
                    (route) => false,
                  );
                } catch (e) {
                  // Si falla la navegación, intentar con el contexto normal
                  debugPrint('Error en navegación con rootNavigator, intentando navegación normal: $e');
                  try {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                  } catch (e2) {
                    debugPrint('Error en navegación normal: $e2');
                    // Como último recurso, hacer pop
                    Navigator.of(context).pop();
                  }
                }
              }
            });
          },
          backButtonText: 'Volver al inicio',
        );
      }
    } finally {
      // Resetear el flag después de un breve delay para permitir que se complete el manejo
      Future.delayed(const Duration(milliseconds: 500), () {
        _isHandlingCriticalError = false;
      });
    }
  }
}

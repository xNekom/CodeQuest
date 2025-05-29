import 'package:flutter/foundation.dart';

/// Clase para manejar comportamientos específicos de la plataforma web
class WebPlatformHandler {
  /// Verifica si un error debe ser ignorado en plataforma web
  static bool shouldIgnoreWebError(dynamic error) {
    if (!kIsWeb) return false;
    
    final errorStr = error.toString().toLowerCase();
    
    // Lista de errores comunes en web que podemos ignorar
    final webSpecificErrors = [
      'unsupported operation: platform._version',
      'unsupported operation: httpclient',
      'platform is not available',
      'file system is not available',
      'socket is not available',
      'httpsclient is not available',
      'platformdispatcher'
    ];
    
    for (final knownError in webSpecificErrors) {
      if (errorStr.contains(knownError)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Obtiene un mensaje de error amigable para la web
  static String getWebFriendlyMessage(dynamic error) {
    if (!kIsWeb) return error.toString();
    
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('platform') || errorStr.contains('httpclient')) {
      return 'Esta función no está disponible en la versión web.';
    } else if (errorStr.contains('file')) {
      return 'El acceso al sistema de archivos no está disponible en la web.';
    } else if (errorStr.contains('socket') || errorStr.contains('connection')) {
      return 'Error de red. Algunas funcionalidades son limitadas en la web.';
    }
    
    return error.toString();
  }
}
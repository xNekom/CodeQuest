import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'error_logger_io.dart' if (dart.library.html) 'error_logger_web.dart' as platform;

/// Clase para gestionar el registro de errores multiplataforma
class ErrorLogger {
  /// Inicializa el sistema de logs
  static Future<void> init() async {
    await platform.PlatformErrorLogger.init();
  }

  /// Escribe un mensaje de error en el log
  static Future<void> log(String message, {dynamic error, StackTrace? stackTrace}) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final logMessage = '[$timestamp] $message\n';
    final errorDetails = error != null ? 'ERROR: $error\n' : '';
    final stackDetails = stackTrace != null ? 'STACK: $stackTrace\n' : '';
    final separator = '----------------------------------------\n';
    final fullLog = logMessage + errorDetails + stackDetails + separator;
    
    // Imprimir en consola en modo debug
    if (kDebugMode) {
      debugPrint(fullLog);
    }
    
    // Escribir usando la implementación específica de plataforma
    await platform.PlatformErrorLogger.writeLog(fullLog);
  }
  
  /// Obtiene el contenido completo del archivo de log
  static Future<String> getLogContent() async {
    return await platform.PlatformErrorLogger.getLogContent();
  }
  
  /// Limpia el archivo de log
  static Future<void> clearLogs() async {
    await platform.PlatformErrorLogger.clearLogs();
  }
}
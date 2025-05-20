import 'package:flutter/foundation.dart';

/// Implementación del logger para plataforma web (solo memoria)
class PlatformErrorLogger {
  static final List<String> _memoryLogs = []; // Buffer para la plataforma web

  /// Inicializa el sistema de logs (no hace nada en web)
  static Future<void> init() async {
    debugPrint('Inicializando logger en modo web (solo memoria)');
  }

  /// Escribe un mensaje en memoria
  static Future<void> writeLog(String fullLog) async {
    // Almacenar en memoria para web
    _memoryLogs.add(fullLog);
    // Limitar tamaño del buffer
    if (_memoryLogs.length > 1000) {
      _memoryLogs.removeAt(0);
    }
  }
  
  /// Obtiene el contenido completo de los logs en memoria
  static Future<String> getLogContent() async {
    if (_memoryLogs.isEmpty) {
      return 'No hay registros disponibles';
    }
    return _memoryLogs.join('');
  }
  
  /// Limpia los logs en memoria
  static Future<void> clearLogs() async {
    _memoryLogs.clear();
  }
}

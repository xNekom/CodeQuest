import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Implementación del logger para plataformas que soportan dart:io
class PlatformErrorLogger {
  static const String _logFileName = 'codequest_errors.log';
  static File? _logFile;

  /// Inicializa el sistema de logs
  static Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');
      
      // Comprobar si el archivo necesita rotación (> 10MB)
      if (await _logFile!.exists()) {
        final stats = await _logFile!.stat();
        if (stats.size > 10 * 1024 * 1024) { // 10MB
          final now = DateTime.now();
          final backupName = '${directory.path}/${_logFileName}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.bak';
          await _logFile!.copy(backupName);
          await _logFile!.writeAsString(''); // Limpiar archivo
        }
      }
    } catch (e) {
      debugPrint('Error al inicializar el logger: $e');
    }
  }

  /// Escribe un mensaje en el archivo de log
  static Future<void> writeLog(String fullLog) async {
    if (_logFile == null) {
      await init();
    }
    
    if (_logFile != null) {
      try {
        await _logFile!.writeAsString(
          fullLog,
          mode: FileMode.append,
        );
      } catch (e) {
        debugPrint('Error al escribir en el log: $e');
      }
    }
  }
  
  /// Obtiene el contenido completo del archivo de log
  static Future<String> getLogContent() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No hay registros disponibles';
    }
    
    try {
      return await _logFile!.readAsString();
    } catch (e) {
      return 'Error al leer logs: $e';
    }
  }
  
  /// Limpia el archivo de log
  static Future<void> clearLogs() async {
    if (_logFile == null) return;
    
    try {
      if (await _logFile!.exists()) {
        await _logFile!.writeAsString('');
      }
    } catch (e) {
      debugPrint('Error al limpiar logs: $e');
    }
  }
}

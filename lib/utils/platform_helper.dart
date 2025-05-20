import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper para operaciones específicas de plataforma
class PlatformHelper {
  /// Cliente HTTP para realizar peticiones de red
  static HttpClient? _client;
  
  /// Obtiene o crea un cliente HTTP
  static HttpClient get client {
    _client ??= HttpClient();
    return _client!;
  }
  
  /// Inicializa el helper de plataforma
  static void init() {
    if (!kIsWeb) {
      _client = HttpClient();
      _client!.connectionTimeout = const Duration(seconds: 30);
    }
  }
  
  /// Limpia recursos del helper
  static void dispose() {
    _client?.close();
    _client = null;
  }
  
  /// Verifica si la plataforma soporta HttpClient
  static bool get supportsHttpClient => !kIsWeb;
}
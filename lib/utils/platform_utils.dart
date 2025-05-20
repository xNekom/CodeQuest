import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

/// Utilidades específicas de plataforma para manejo de errores y compatibilidad
class PlatformUtils {
  /// Verifica si la aplicación se está ejecutando en una plataforma web
  static bool get isWeb => kIsWeb;

  /// Verifica si la aplicación se está ejecutando en Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Verifica si la aplicación se está ejecutando en iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Verifica si la aplicación se está ejecutando en una plataforma móvil
  static bool get isMobile => isAndroid || isIOS;

  /// Verifica si la aplicación se está ejecutando en Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Verifica si la aplicación se está ejecutando en macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Verifica si la aplicación se está ejecutando en Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Verifica si la aplicación se está ejecutando en una plataforma de escritorio
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Obtiene el nombre de la plataforma actual
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Obtiene la versión del sistema operativo (solo para plataformas nativas)
  static String get operatingSystemVersion {
    if (kIsWeb) return 'N/A';
    return Platform.operatingSystemVersion;
  }

  /// Verifica si la plataforma soporta almacenamiento de archivos
  static bool get supportsFileStorage => !kIsWeb;

  /// Verifica si la plataforma soporta notificaciones push
  static bool get supportsPushNotifications => isMobile;

  /// Verifica si la plataforma soporta acceso a cámara
  static bool get supportsCameraAccess => isMobile;

  /// Verifica si la plataforma soporta vibración
  static bool get supportsVibration => isMobile;

  /// Verifica si la plataforma soporta almacenamiento seguro
  static bool get supportsSecureStorage => !kIsWeb;

  /// Verifica si la plataforma soporta biometría
  static bool get supportsBiometrics => isMobile;

  /// Obtiene el separador de rutas de archivo para la plataforma actual
  static String get pathSeparator {
    if (kIsWeb) return '/';
    return Platform.pathSeparator;
  }

  /// Verifica si la plataforma tiene limitaciones de memoria conocidas
  static bool get hasMemoryLimitations => isWeb || isMobile;

  /// Obtiene el número de procesadores disponibles (solo para plataformas nativas)
  static int get numberOfProcessors {
    if (kIsWeb) return 1; // Asumimos un solo hilo para web
    return Platform.numberOfProcessors;
  }

  /// Verifica si la plataforma soporta HttpClient
  static bool get supportsHttpClient => !kIsWeb;

  /// Obtiene el directorio temporal predeterminado según la plataforma
  static String? get defaultTempDirectory {
    if (kIsWeb) return null;
    return Platform.environment['TEMP'] ?? 
           Platform.environment['TMPDIR'] ?? 
           '/tmp';
  }

  /// Verifica si la plataforma soporta logs de sistema
  static bool get supportsSystemLogs => !kIsWeb;

  /// Obtiene información del entorno de la plataforma
  static Map<String, String> get environmentInfo {
    final info = <String, String>{
      'platform': platformName,
      'isWeb': isWeb.toString(),
      'isMobile': isMobile.toString(),
      'isDesktop': isDesktop.toString(),
      'supportsFileStorage': supportsFileStorage.toString(),
      'supportsHttpClient': supportsHttpClient.toString(),
    };

    if (!kIsWeb) {
      info.addAll({
        'operatingSystemVersion': operatingSystemVersion,
        'numberOfProcessors': numberOfProcessors.toString(),
        'pathSeparator': pathSeparator,
      });
    }

    return info;
  }

  /// Ejecuta una función solo si la plataforma lo soporta
  static T? runIfSupported<T>(
    bool Function() platformCheck,
    T Function() action,
  ) {
    if (platformCheck()) {
      try {
        return action();
      } catch (e) {
        // Silenciosamente falla si la plataforma no soporta la operación
        return null;
      }
    }
    return null;
  }

  /// Ejecuta una función de manera asíncrona solo si la plataforma lo soporta
  static Future<T?> runIfSupportedAsync<T>(
    bool Function() platformCheck,
    Future<T> Function() action,
  ) async {
    if (platformCheck()) {
      try {
        return await action();
      } catch (e) {
        // Silenciosamente falla si la plataforma no soporta la operación
        return null;
      }
    }
    return null;
  }  /// Obtiene el espacio de almacenamiento disponible (solo para plataformas nativas)
  static Future<int?> getAvailableStorageSpace() async {
    if (!supportsFileStorage) return null;
    
    try {
      // Esta es una implementación básica
      // En una aplicación real, usarías un plugin como disk_space
      return null; // Retornamos null ya que es una implementación básica
    } catch (e) {
      return null;
    }
  }

  /// Verifica si hay conectividad de red disponible
  static Future<bool> hasNetworkConnectivity() async {
    try {
      // Esta es una implementación básica
      // En una aplicación real, usarías un plugin como connectivity_plus
      if (kIsWeb) {
        return true; // Asumimos conectividad en web
      }
      return true; // Implementación básica
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información detallada del dispositivo para logs de error
  static Map<String, dynamic> getDeviceInfo() {
    final deviceInfo = <String, dynamic>{
      'platform': platformName,
      'timestamp': DateTime.now().toIso8601String(),
      'isWeb': isWeb,
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'capabilities': {
        'fileStorage': supportsFileStorage,
        'httpClient': supportsHttpClient,
        'pushNotifications': supportsPushNotifications,
        'secureStorage': supportsSecureStorage,
        'biometrics': supportsBiometrics,
        'vibration': supportsVibration,
        'cameraAccess': supportsCameraAccess,
      },
    };

    if (!kIsWeb) {
      deviceInfo.addAll({
        'operatingSystemVersion': operatingSystemVersion,
        'numberOfProcessors': numberOfProcessors,
        'memoryLimitations': hasMemoryLimitations,
      });
    }

    return deviceInfo;
  }

  /// Sanitiza rutas de archivo para la plataforma actual
  static String sanitizePath(String path) {
    if (kIsWeb) {
      // Para web, usar barras normales
      return path.replaceAll('\\', '/');
    }
    
    // Para plataformas nativas, usar el separador correcto
    if (Platform.isWindows) {
      return path.replaceAll('/', '\\');
    } else {
      return path.replaceAll('\\', '/');
    }
  }

  /// Verifica si una característica específica está disponible
  static bool isFeatureAvailable(String feature) {
    switch (feature.toLowerCase()) {
      case 'file_storage':
        return supportsFileStorage;
      case 'http_client':
        return supportsHttpClient;
      case 'push_notifications':
        return supportsPushNotifications;
      case 'secure_storage':
        return supportsSecureStorage;
      case 'biometrics':
        return supportsBiometrics;
      case 'vibration':
        return supportsVibration;
      case 'camera':
        return supportsCameraAccess;
      case 'system_logs':
        return supportsSystemLogs;
      default:
        return false;
    }
  }

  /// Configura ajustes específicos de la plataforma
  static void configurePlatform() {
    // Configuraciones específicas de plataforma para optimizar rendimiento
    if (isWeb) {
      debugPrint('Configurando plataforma web...');
      // Configuraciones específicas para web
    } else if (isMobile) {
      debugPrint('Configurando plataforma móvil...');
      // Configuraciones específicas para móvil
    } else if (isDesktop) {
      debugPrint('Configurando plataforma de escritorio...');
      // Configuraciones específicas para escritorio
    }
  }
}
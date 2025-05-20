import 'package:flutter/material.dart';
import 'error_handler.dart';
import 'error_logger.dart';

/// Un observador de navegador que captura errores durante la navegación
class ErrorHandlingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _handleRoute(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _handleRoute(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _handleRoute(previousRoute);
    super.didPop(route, previousRoute);
  }
  void _handleRoute(Route<dynamic> route) {
    try {
      // Registrar navegación para depuración y análisis
      final routeName = route.settings.name ?? 'desconocido';
      final routeArguments = route.settings.arguments != null ? ' con argumentos' : ' sin argumentos';
      ErrorLogger.log('Navegación a ruta: $routeName$routeArguments');
    } catch (error, stack) {
      ErrorHandler.logError(error, stack);
    }
  }
}

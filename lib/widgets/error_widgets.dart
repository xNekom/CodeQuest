import 'package:flutter/material.dart';

/// Widget para mostrar mensajes de error en la aplicación con estilo pixel art.
class PixelErrorMessage extends StatelessWidget {
  /// El mensaje de error a mostrar.
  final String message;
  
  /// El título del error (opcional).
  final String? title;
  
  /// Callback para cuando se presiona el botón de reintentar.
  final VoidCallback? onRetry;
  
  /// Si debe mostrar un botón de reintentar.
  final bool showRetry;
  
  /// Si debe mostrar un icono de error.
  final bool showIcon;
  
  /// Constructor para el widget PixelErrorMessage.
  const PixelErrorMessage({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.showRetry = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 12),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRetry && onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar una página de error completa.
class PixelErrorPage extends StatelessWidget {
  /// El mensaje de error a mostrar.
  final String message;
  
  /// El título del error.
  final String title;
  
  /// Callback para cuando se presiona el botón de reintentar.
  final VoidCallback? onRetry;
  
  /// Callback para cuando se presiona el botón de volver.
  final VoidCallback? onBack;
  
  /// Constructor para el widget PixelErrorPage.
  const PixelErrorPage({
    super.key,
    required this.message,
    this.title = 'Error',
    this.onRetry,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onBack != null) ...[
                    ElevatedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

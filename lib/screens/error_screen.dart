import 'package:flutter/material.dart';
import '../widgets/error_widgets.dart';

/// Pantalla que se muestra cuando ocurre un error crítico
class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String? buttonText;
  final String? backButtonText;
  final IconData icon;

  const ErrorScreen({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.onBack,
    this.buttonText = 'Reintentar',
    this.backButtonText = 'Volver',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(        decoration: BoxDecoration(
          // Usa el fondo de pixel art para mantener la consistencia visual
          image: const DecorationImage(
            image: AssetImage('assets/backgrounds/pixel_background.png'),
            fit: BoxFit.cover,
          ),
          color: theme.colorScheme.surface,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 4,
              ),              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de error estilizado
                PixelIcon(
                  icon: icon,
                  size: 80,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                
                // Título del error
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Mensaje de error
                PixelErrorMessage(
                  message: message,
                  showIcon: false,
                ),
                const SizedBox(height: 24),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onBack != null)
                      Expanded(
                        child: PixelButton(
                          onPressed: onBack!,
                          label: backButtonText!,
                          variant: PixelButtonVariant.secondary,
                        ),
                      ),
                    if (onBack != null && onRetry != null)
                      const SizedBox(width: 16),
                    if (onRetry != null)
                      Expanded(
                        child: PixelButton(
                          onPressed: onRetry!,
                          label: buttonText!,
                          variant: PixelButtonVariant.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de botón con estilo pixel art
class PixelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final PixelButtonVariant variant;

  const PixelButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = PixelButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Definir colores basados en la variante
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    switch (variant) {
      case PixelButtonVariant.primary:
        backgroundColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimary;
        borderColor = theme.colorScheme.primary.darker(20);
        break;
      case PixelButtonVariant.secondary:
        backgroundColor = theme.colorScheme.secondary;
        textColor = theme.colorScheme.onSecondary;
        borderColor = theme.colorScheme.secondary.darker(20);
        break;
      case PixelButtonVariant.error:
        backgroundColor = theme.colorScheme.error;
        textColor = theme.colorScheme.onError;
        borderColor = theme.colorScheme.error.darker(20);
        break;
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// Widget de icono con estilo pixel art
class PixelIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const PixelIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size / 4),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary).withAlpha(51),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: color ?? Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: size / 2,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Extensión para manipular colores
extension ColorExtension on Color {  Color darker(int percent) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      a.toInt(),
      (r * value).round(),
      (g * value).round(),
      (b * value).round(),
    );
  }
}

/// Enumeración para las variantes de botón
enum PixelButtonVariant {
  primary,
  secondary,
  error,
}

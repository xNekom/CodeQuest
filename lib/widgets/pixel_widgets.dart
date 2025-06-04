import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

/// Botón personalizado con estilo pixel art
class PixelButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isSecondary;
  final double? width;
  final double? height;
  final Color? color;
  final bool isSmall;

  const PixelButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isSecondary = false,
    this.width,
    this.height,
    this.color,
    this.isSmall = false,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() {
      _isPressed = false;
    });
    // widget.onPressed?.call(); // Removed
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.width ?? 0.0,
            minHeight: widget.height ?? (widget.isSmall ? 44.0 : 56.0),
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed, // Changed to directly use widget.onPressed
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSecondary
                  ? Theme.of(context).colorScheme.surface
                  : widget.color ?? Theme.of(context).colorScheme.primary,
              foregroundColor: widget.isSecondary
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              side: widget.isSecondary ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ) : null,
              padding: const EdgeInsets.symmetric(
                horizontal: PixelTheme.spacingMedium, 
                vertical: PixelTheme.spacingSmall
              ),
              elevation: widget.isSecondary ? 0 : 3,
              shadowColor: widget.isSecondary ? null : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PixelTheme.borderRadiusMedium),
              ),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Campo de texto personalizado con estilo pixel art
class PixelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Icon? prefixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PixelTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(PixelTheme.borderRadiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(PixelTheme.borderRadiusMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(PixelTheme.borderRadiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(
           horizontal: PixelTheme.spacingMedium,
           vertical: PixelTheme.spacingMedium,
         ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      enableInteractiveSelection: true, // Hacer el texto seleccionable
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

/// Tarjeta personalizada con estilo pixel art
class PixelCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final double? width;
  final double? height;

  const PixelCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PixelTheme.borderRadiusMedium),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), 
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Diálogo personalizado con estilo pixel art
class PixelDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const PixelDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(128), width: 2), // Replaced withOpacity
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51), // Reemplazado .withOpacity(0.2)
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: content,
          ),
          if (actions != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Icono de pixel art con estilo personalizado
class PixelIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;

  const PixelIcon(
    this.icon, {
    super.key,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Icon(
      icon,
      color: iconColor,
      size: size,
    );
  }
}

/// Avatar de usuario con estilo pixel art
class PixelAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? name;

  const PixelAvatar({
    super.key,
    this.imageUrl,
    this.size = 50,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(context),
            )
          : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: name != null && name!.isNotEmpty
            ? Text(
                name!.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                color: Colors.white,
                size: size * 0.6,
              ),
      ),
    );
  }
}

/// Barra de progreso con estilo pixel art
class PixelProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  final String? label;

  const PixelProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 16.0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              label!,
              style: theme.textTheme.bodySmall,
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return Row(
                children: [
                  Container(
                    width: maxWidth * value.clamp(0.0, 1.0),
                    color: barColor,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
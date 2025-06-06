import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppBar personalizado con estilo pixel art uniforme
class PixelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final IconThemeData? iconTheme;
  final double? titleFontSize;
  final PreferredSizeWidget? bottom;

  const PixelAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.iconTheme,
    this.titleFontSize = 14,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title.toUpperCase(),
        style: GoogleFonts.pressStart2p(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      iconTheme: iconTheme ?? IconThemeData(
        color: foregroundColor ?? Colors.white,
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

/// Variante del PixelAppBar para pantallas administrativas
class PixelAdminAppBar extends PixelAppBar {
  const PixelAdminAppBar({
    super.key,
    required super.title,
    super.actions,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.centerTitle = true,
    super.elevation = 0,
    super.titleFontSize = 14,
    super.bottom,
  }) : super(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
import 'package:flutter/material.dart';

/// Utilidades para prevenir overflows en la aplicación
class OverflowUtils {
  /// Wrapper para Row que previene overflows
  static Widget safeRow({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    required List<Widget> children,
  }) {
    return IntrinsicHeight(
      child: Row(
        key: key,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: children,
      ),
    );
  }

  /// Wrapper para Column que previene overflows
  static Widget safeColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    required List<Widget> children,
  }) {
    return IntrinsicWidth(
      child: Column(
        key: key,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: children,
      ),
    );
  }

  /// Widget de texto seguro que previene overflows
  static Widget safeText(
    String text, {
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap = true,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextScaler? textScaler,
    int? maxLines = 2,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return Text(
      text,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  /// Widget flexible que envuelve texto de manera segura
  static Widget flexibleText(
    String text, {
    Key? key,
    int flex = 1,
    FlexFit fit = FlexFit.loose,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    int? maxLines = 2,
    bool softWrap = true,
  }) {
    return Flexible(
      key: key,
      flex: flex,
      fit: fit,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
      ),
    );
  }

  /// Widget expandido que envuelve texto de manera segura
  static Widget expandedText(
    String text, {
    Key? key,
    int flex = 1,
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    int? maxLines = 2,
    bool softWrap = true,
  }) {
    return Expanded(
      key: key,
      flex: flex,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
      ),
    );
  }

  /// Contenedor con restricciones seguras
  static Widget constrainedContainer({
    Key? key,
    required Widget child,
    double? maxWidth,
    double? maxHeight,
    double? minWidth,
    double? minHeight,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
  }) {
    return Container(
      key: key,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
          minWidth: minWidth ?? 0.0,
          minHeight: minHeight ?? 0.0,
        ),
        child: child,
      ),
    );
  }

  /// Lista de conceptos segura para evitar overflows
  static Widget safeConceptsList(
    List<String> concepts, {
    Key? key,
    TextStyle? style,
    String separator = ', ',
    int maxLines = 2,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return safeText(
      concepts.join(separator),
      key: key,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
    );
  }

  /// Row con información de estadísticas segura
  static Widget safeStatsRow({
    Key? key,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceBetween,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return IntrinsicHeight(
      child: Row(
        key: key,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children:
            children.map((child) {
              if (child is! Expanded && child is! Flexible) {
                return Flexible(child: child);
              }
              return child;
            }).toList(),
      ),
    );
  }

  /// Scaffold seguro que previene overflows en el body
  static Widget safeScaffold({
    Key? key,
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? drawer,
    Widget? endDrawer,
    Widget? bottomNavigationBar,
    Widget? bottomSheet,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
  }) {
    return Scaffold(
      key: key,
      appBar: appBar,
      body: body != null
          ? SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(
                        NavigationService.navigatorKey.currentContext!).size.height -
                        (appBar?.preferredSize.height ?? 0) -
                        MediaQuery.of(
                            NavigationService.navigatorKey.currentContext!).padding.top -
                        MediaQuery.of(
                            NavigationService.navigatorKey.currentContext!).padding.bottom,
                  ),
                  child: body,
                ),
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  /// ListView seguro que previene overflows
  static Widget safeListView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = true,
    EdgeInsetsGeometry? padding,
    required List<Widget> children,
  }) {
    return ListView(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics ?? const ClampingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding,
      children: children,
    );
  }

  /// GridView seguro que previene overflows
  static Widget safeGridView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = true,
    EdgeInsetsGeometry? padding,
    required SliverGridDelegate gridDelegate,
    required List<Widget> children,
  }) {
    return GridView(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics ?? const ClampingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding,
      gridDelegate: gridDelegate,
      children: children,
    );
  }

  /// Card segura con contenido que previene overflows
  static Widget safeCard({
    Key? key,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    bool borderOnForeground = true,
    EdgeInsetsGeometry? margin,
    Clip? clipBehavior,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      key: key,
      color: color,
      elevation: elevation,
      shape: shape,
      borderOnForeground: borderOnForeground,
      margin: margin,
      clipBehavior: clipBehavior,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  /// Wrapper para información de usuario que previene overflows
  static Widget safeUserInfo({
    Key? key,
    required String username,
    required String level,
    required String coins,
    TextStyle? usernameStyle,
    TextStyle? infoStyle,
    VoidCallback? onChangePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        safeText(
          username,
          key: key,
          style: usernameStyle,
          maxLines: 1,
        ),
        const SizedBox(height: 8),
        safeRow(
          children: [
            const Icon(Icons.star, size: 18),
            const SizedBox(width: 8),
            flexibleText(
              'Nivel: $level',
              style: infoStyle,
              maxLines: 1,
            ),
          ],
        ),
        const SizedBox(height: 4),
        safeRow(
          children: [
            const Icon(Icons.monetization_on, size: 18, color: Colors.amber),
            const SizedBox(width: 8),
            flexibleText(
              '$coins monedas',
              style: infoStyle,
              maxLines: 1,
            ),
          ],
        ),
        if (onChangePassword != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.lock_reset),
            label: flexibleText(
              'Cambiar Contraseña',
              maxLines: 2,
            ),
            onPressed: onChangePassword,
          ),
        ],
      ],
    );
  }

  /// Wrapper para elementos de leaderboard que previene overflows
  static Widget safeLeaderboardItem({
    Key? key,
    required String username,
    required String score,
    required int position,
    bool isCurrentUser = false,
    Widget? leadingWidget,
    Widget? trailingWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: safeRow(
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 30,
            child: safeText(
              '#$position',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.blue : null,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          expandedText(
            username,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? Colors.blue : null,
            ),
            maxLines: 1,
          ),
          const SizedBox(width: 12),
          safeText(
            score,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 12),
            trailingWidget,
          ],
        ],
      ),
    );
  }

  /// Wrapper para botones de navegación que previene overflows
  static Widget safeNavigationButton({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isSecondary = false,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : null,
          foregroundColor: isSecondary ? Colors.black : null,
        ),
        child: safeRow(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            flexibleText(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Servicio de navegación para acceder al contexto global
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

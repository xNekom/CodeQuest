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
    double? textScaleFactor,
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
      textScaleFactor: textScaleFactor,
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
}

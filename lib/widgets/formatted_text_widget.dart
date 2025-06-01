import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

class FormattedTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const FormattedTextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormattedText(context);
  }

  Widget _buildFormattedText(BuildContext context) {
    // Buscar bloques de código entre backticks
    final codeBlockRegex = RegExp(r'`([^`]+)`');
    final matches = codeBlockRegex.allMatches(text);

    if (matches.isEmpty) {
      // No hay código, mostrar texto normal
      return Text(
        text,
        style: style ?? Theme.of(context).textTheme.headlineSmall,
        textAlign: textAlign,
      );
    }

    List<Widget> widgets = [];
    int lastEnd = 0;

    for (final match in matches) {
      // Agregar texto antes del código
      if (match.start > lastEnd) {
        final beforeText = text.substring(lastEnd, match.start);
        if (beforeText.isNotEmpty) {
          widgets.add(
            Text(
              beforeText,
              style: style ?? Theme.of(context).textTheme.headlineSmall,
              textAlign: textAlign,
            ),
          );
        }
      }

      // Agregar el bloque de código formateado
      final rawCodeText = match.group(1) ?? '';
      final formattedCodeText = _formatJavaCode(rawCodeText);

      widgets.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
          ),
          child: HighlightView(
            formattedCodeText,
            language: 'java',
            theme: githubTheme,
            padding: const EdgeInsets.all(8.0),
            textStyle: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 15.0,
              height: 1.4,
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    // Agregar texto después del último código
    if (lastEnd < text.length) {
      final afterText = text.substring(lastEnd);
      if (afterText.isNotEmpty) {
        widgets.add(
          Text(
            afterText,
            style: style ?? Theme.of(context).textTheme.headlineSmall,
            textAlign: textAlign,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment:
          textAlign == TextAlign.center
              ? CrossAxisAlignment.center
              : textAlign == TextAlign.left
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
      children: widgets,
    );
  }

  String _formatJavaCode(String code) {
    // Limpiar el código de espacios extra
    String cleanCode = code.trim();

    // Agregar espacios alrededor de operadores y llaves
    cleanCode = cleanCode
        .replaceAll(RegExp(r'\{'), ' {\n    ')
        .replaceAll(RegExp(r'\}'), '\n}')
        .replaceAll(RegExp(r';'), ';\n')
        .replaceAll(RegExp(r'='), ' = ')
        .replaceAll(RegExp(r'\('), '(')
        .replaceAll(RegExp(r'\)'), ') ')
        .replaceAll(RegExp(r','), ', ');

    // Limpiar múltiples espacios y saltos de línea
    cleanCode = cleanCode
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*\{\s*'), ' {\n    ')
        .replaceAll(RegExp(r'\s*\}\s*'), '\n}')
        .replaceAll(RegExp(r';\s*'), ';\n')
        .replaceAll(RegExp(r'\n\s*\n'), '\n');

    // Formatear declaraciones específicas de Java
    cleanCode = cleanCode
        .replaceAll(RegExp(r'public\s+class'), 'public class')
        .replaceAll(
          RegExp(r'public\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('),
          'public \$1(',
        )
        .replaceAll(RegExp(r'String\s+([A-Za-z_][A-Za-z0-9_]*)'), 'String \$1')
        .replaceAll(RegExp(r'=\s*new\s+'), ' = new ');

    return cleanCode.trim();
  }
}

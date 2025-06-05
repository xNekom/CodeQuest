import 'package:flutter/material.dart';
import '../utils/error_logger.dart';
import '../widgets/pixel_app_bar.dart';

/// Pantalla para visualizar los logs de errores de la aplicación
class ErrorLogScreen extends StatefulWidget {
  const ErrorLogScreen({super.key});

  @override
  State<ErrorLogScreen> createState() => _ErrorLogScreenState();
}

class _ErrorLogScreenState extends State<ErrorLogScreen> {
  String _logContent = 'Cargando logs...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos solo cuando la ruta se vuelve activa
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      // Usar Future.microtask en lugar de addPostFrameCallback para evitar bucles infinitos
      Future.microtask(() {
        if (mounted) {
          _loadLogs();
        }
      });
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final content = await ErrorLogger.getLogContent();
      setState(() {
        _logContent = content.isEmpty ? 'No hay logs disponibles' : content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _logContent = 'Error al cargar logs: $e';
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PixelAppBar(
        title: 'Registro de Errores',
        backgroundColor: Colors.red[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título e información
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registro de Errores',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí puedes ver los errores registrados por la aplicación. '
                    'Esta información es útil para diagnóstico y depuración.',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contenido de los logs
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          child: SelectableText(
                            _logContent,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Generar un error de prueba para ver cómo funciona el sistema
          try {
            throw Exception('Error de prueba para verificar el sistema');
          } catch (e, stack) {
            ErrorLogger.log(
              'Error de prueba generado manualmente',
              error: e,
              stackTrace: stack,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error de prueba generado')),
              );
              _loadLogs();
            }
          }
        },
        tooltip: 'Generar error de prueba',
        child: const Icon(Icons.bug_report),
      ),
    );
  }
}

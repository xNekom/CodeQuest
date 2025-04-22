import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/pixel_widgets.dart'; // Asumiendo que quieres usar tus widgets personalizados

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _sendRecoveryEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _authService.sendPasswordResetEmail(email: _emailController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Si tu correo está registrado, recibirás un enlace para restablecer tu contraseña.')),
          );
          Navigator.pop(context); // Volver a la pantalla de login
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error al enviar el correo: ${e.toString()}';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Recupera tu Contraseña',
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onBackground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withAlpha(150)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                PixelTextField(
                  controller: _emailController,
                  hintText: 'Correo Electrónico',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email, color: theme.colorScheme.onSurfaceVariant),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Ingresa un correo válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  PixelButton(
                    onPressed: _sendRecoveryEmail,
                    color: theme.colorScheme.primary,
                    child: Text('Enviar Enlace', style: TextStyle(color: theme.colorScheme.onPrimary)),
                  ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Volver a la pantalla de login
                  },
                  child: Text(
                    'Volver a Iniciar Sesión',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

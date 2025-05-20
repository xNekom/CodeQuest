import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

// Tipo público para usar en API pública
typedef ToggleViewCallback = void Function();

class RegisterScreen extends StatefulWidget {
  final ToggleViewCallback? toggleView;
  
  const RegisterScreen({super.key, this.toggleView});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto para los campos del formulario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  // Usando setState para manejar el estado de error
  String _error = '';
  bool _isLoading = false;

  // Método para manejar el registro
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Verificar que las contraseñas coincidan
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _error = 'Las contraseñas no coinciden';
        });
        return;
      }
      
      setState(() {
        _isLoading = true;
        _error = ''; // Limpiar errores anteriores
      });
      
      try {
        // Crear el usuario con email y contraseña
        await _authService.registerWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(), // Añadir el parámetro username requerido
        );
        
        // Actualizar el perfil con el nombre de usuario
        User? user = _authService.currentUser;
        if (user != null) {
          await user.updateDisplayName(_usernameController.text.trim());
          // También podemos actualizar la foto de perfil si lo deseamos
          // await user.updatePhotoURL("https://url-de-la-imagen");
        }
        
        if (mounted) {
          // Redirigir a la pantalla de creación de personaje en lugar de /home
          Navigator.pushReplacementNamed(context, '/character'); 
        }
      } catch (e) {
        if (!mounted) return;
        
        String errorMessage;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'weak-password':
              errorMessage = 'La contraseña proporcionada es demasiado débil';
              break;
            case 'email-already-in-use':
              errorMessage = 'Ya existe una cuenta con este correo electrónico';
              break;
            case 'invalid-email':
              errorMessage = 'El formato del correo electrónico no es válido';
              break;
            default:
              errorMessage = 'Error al registrar: ${e.message}';
          }
        } else {
          errorMessage = 'Ocurrió un error inesperado. Por favor intenta nuevamente.';
        }
        
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'REGISTRO',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (val) => val!.isEmpty ? 'Ingresa un correo electrónico' : null,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (val) => val!.length < 6 ? 'Ingresa una contraseña de al menos 6 caracteres' : null,
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                validator: (val) => val!.length < 6 ? 'Ingresa una contraseña de al menos 6 caracteres' : null,
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                validator: (val) => val!.isEmpty ? 'Ingresa un nombre de usuario' : null,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Registrarse'),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _error,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes cuenta? '),
                  GestureDetector(
                    onTap: () {
                      widget.toggleView?.call();
                    },
                    child: Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
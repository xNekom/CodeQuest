import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/pixel_widgets.dart';

class SignUpScreen extends StatefulWidget {
  final Function? toggleView;
  
  const SignUpScreen({super.key, this.toggleView});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto para los campos del formulario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  String _error = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Método para manejar el registro
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await _authService.registerWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
        );
        // Verificamos si el widget sigue montado antes de usar context
        if (!mounted) return;
        
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Este correo ya está registrado';
            break;
          case 'invalid-email':
            errorMessage = 'Correo electrónico inválido';
            break;
          case 'weak-password':
            errorMessage = 'La contraseña es demasiado débil';
            break;
          default:
            errorMessage = 'Error en el registro: ${e.message}';
        }
        
        if (!mounted) return;
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = 'Error en el registro: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    PixelCard(
                      child: Column(
                        children: [
                          Text(
                            'CREA TU CUENTA',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30.0),
                          
                          Icon(
                            Icons.sports_esports,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          
                          const SizedBox(height: 24.0),
                          
                          PixelTextField(
                            controller: _usernameController,
                            hintText: 'Nombre de usuario',
                            prefixIcon: const Icon(Icons.person),
                            validator: (val) => val!.isEmpty ? 'Ingresa un nombre de usuario' : null,
                          ),
                          
                          const SizedBox(height: 16.0),
                          
                          PixelTextField(
                            controller: _emailController,
                            hintText: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                            validator: (val) => val!.isEmpty ? 'Ingresa un correo electrónico' : null,
                          ),
                          
                          const SizedBox(height: 16.0),
                          
                          PixelTextField(
                            controller: _passwordController,
                            hintText: 'Contraseña',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock),
                            validator: (val) => val!.length < 6 ? 'La contraseña debe tener al menos 6 caracteres' : null,
                          ),
                          
                          const SizedBox(height: 24.0),
                          
                          if (_error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _error,
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          
                          _isLoading
                            ? const CircularProgressIndicator()
                            : PixelButton(
                                onPressed: _handleSignUp,
                                child: const Text('REGISTRARSE'),
                              ),
                          
                          const SizedBox(height: 16.0),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿Ya tienes cuenta? '),
                              GestureDetector(
                                onTap: () {
                                  widget.toggleView?.call();
                                },
                                child: Text(
                                  'Iniciar Sesión',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
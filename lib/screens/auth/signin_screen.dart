import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/pixel_widgets.dart';

class SignInScreen extends StatefulWidget {
  final Function? toggleView;
  
  const SignInScreen({super.key, this.toggleView});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto para los campos del formulario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _error = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método para manejar el inicio de sesión
  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = ''; // Limpiar errores anteriores
      });
      
      try {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // Verificamos si el widget sigue montado antes de usar context
        if (!mounted) return;
        
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (!mounted) return;
        
        String errorMessage;
        debugPrint('Error completo: $e');
        
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No existe una cuenta con este correo electrónico';
              break;
            case 'wrong-password':
              errorMessage = 'La contraseña es incorrecta';
              break;
            case 'invalid-email':
              errorMessage = 'El formato del correo electrónico no es válido';
              break;
            case 'user-disabled':
              errorMessage = 'Esta cuenta ha sido desactivada';
              break;
            case 'too-many-requests':
              errorMessage = 'Demasiados intentos fallidos. Inténtalo más tarde';
              break;
            case 'operation-not-allowed':
              errorMessage = 'El inicio de sesión con correo y contraseña no está habilitado';
              break;
            case 'network-request-failed':
              errorMessage = 'Error de red. Comprueba tu conexión a internet';
              break;
            case 'invalid-credential':
              errorMessage = 'El correo o la contraseña son incorrectos';
              break;
            default:
              errorMessage = 'Error de autenticación: Credenciales incorrectas';
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
                            'INICIAR SESIÓN',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30.0),
                          
                          Icon(
                            Icons.code,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          
                          const SizedBox(height: 24.0),
                          
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
                                onPressed: _handleSignIn,
                                child: const Text('ENTRAR'),
                              ),
                          
                          const SizedBox(height: 16.0),
                          
                          PixelButton(
                            isSecondary: true,
                            onPressed: () {
                              // Implementar recuperación de contraseña
                            },
                            child: const Text('OLVIDÉ MI CONTRASEÑA'),
                          ),
                          
                          const SizedBox(height: 16.0),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿No tienes cuenta? '),
                              GestureDetector(
                                onTap: () {
                                  widget.toggleView?.call();
                                },
                                child: Text(
                                  'Regístrate',
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
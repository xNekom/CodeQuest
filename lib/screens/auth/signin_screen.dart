import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../widgets/pixel_widgets.dart';
import '../../utils/error_handler.dart';

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
  bool _rememberCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Cargar credenciales guardadas
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    final rememberMe = prefs.getBool('remember_credentials') ?? false;
    
    if (rememberMe && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberCredentials = rememberMe;
      });
    }
  }

  // Guardar credenciales si está marcado el checkbox
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_rememberCredentials) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_credentials', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_credentials', false);
    }
  }
  // Método para manejar el inicio de sesión
  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = ''; // Limpiar errores anteriores
      });
      
      try {
        // Guardar credenciales antes del login
        await _saveCredentials();
        
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // Verificamos si el widget sigue montado antes de usar context
        if (!mounted) return;
        
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (!mounted) return;
        
        // Registrar el error para análisis
        ErrorHandler.logError(e, StackTrace.current);
        
        // Obtener un mensaje amigable para el usuario
        final errorMessage = ErrorHandler.handleError(e);
        
        // Mostrar el error en la interfaz
        ErrorHandler.showError(context, errorMessage);
        
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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/background.png'),
            fit: BoxFit.cover,
          ),
        ),
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
                          
                          Image.asset(
                            'assets/images/logo/logo_no_background.png',
                            height: 120,
                            width: 120,
                          ),
                          
                          const SizedBox(height: 24.0),
                          
                          PixelTextField(
                            controller: _emailController,
                            hintText: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                            validator: (val) => val!.isEmpty ? 'Ingresa un correo electrónico' : null,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          ),
                          
                          const SizedBox(height: 16.0),
                          
                          PixelTextField(
                            controller: _passwordController,
                            hintText: 'Contraseña',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock),
                            validator: (val) => val!.length < 6 ? 'La contraseña debe tener al menos 6 caracteres' : null,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleSignIn(),
                          ),
                          
                          const SizedBox(height: 16.0),
                          
                          // Checkbox para recordar credenciales
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberCredentials,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberCredentials = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'Recordar correo y contraseña',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24.0),
                          
                          if (_error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                _error,  textAlign: TextAlign.center,
                                style: TextStyle(color: Theme.of(context).colorScheme.error),    ),
                            ),
                          
                          _isLoading
                            ? const CircularProgressIndicator()
                            : PixelButton(
                                onPressed: _handleSignIn,
                                child: const Text('ENTRAR'),
                              ),
                          
                          const SizedBox(height: 16.0),
                          
                          // Texto para olvidar contraseña
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/password-recovery');
                            },
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 16.0),
                          
                          // Botón para registrarse
                          PixelButton(
                            isSecondary: true,
                            onPressed: () {
                              widget.toggleView?.call();
                            },
                            child: const Text('REGISTRARSE'),
                          ),
                          
                          const SizedBox(height: 8.0),
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
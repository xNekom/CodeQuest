import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:flutter/services.dart';

// Tipo público para usar en API pública
typedef ToggleViewCallback = void Function();

class LoginScreen extends StatefulWidget {
  final ToggleViewCallback? toggleView;
  
  // Usar super parámetro
  const LoginScreen({super.key, this.toggleView});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  String _error = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Solicitar foco al teclado una vez se construya el frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(_keyboardFocusNode);
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() { _isLoading = true; _error = ''; });
    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RawKeyboardListener(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKey: (event) {
            if (event is RawKeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
              _login();
              return;
            }
          },
          child: Form(
           key: _formKey,
           child: Column(
             children: [
                  Text(
                    'INICIAR SESIÓN',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (val) => val==null||val.isEmpty ? 'Ingresa tu email' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    onEditingComplete: _login,
                    validator: (val) => val==null||val.length<6 ? 'Al menos 6 caracteres' : null,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
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
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/password-recovery');
                    },
                    child: Text(
                      'OLVIDÉ MI CONTRASEÑA',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
        ),
     ),
   );
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
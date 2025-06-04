import 'package:flutter/material.dart';
import '../../widgets/pixel_app_bar.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PixelAppBar(
        title: 'Iniciar Sesión',
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/background_login_auth.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'INICIAR SESIÓN',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
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
    );
  }

  void _login() {
    // Implement login logic
  }
}
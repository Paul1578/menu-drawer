import 'package:flutter/material.dart';
import 'package:menubar/src/app_bar.dart';
import 'package:menubar/src/pages/auth/register.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String _mensaje = "";

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isAnimationReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().whenComplete(() {
      setState(() {
        _isAnimationReady = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() async {
  String user = _userController.text.trim();
  String pass = _passController.text.trim();

  if (user.isNotEmpty && pass.isNotEmpty) {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: user, password: pass);

      if (userCredential.user != null) {
        // Inicio de sesión exitoso, navegar a la página principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ManuTabBAR()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No se encontró ningún usuario con este correo electrónico.';
          break;
        case 'wrong-password':
          errorMessage = 'La contraseña es incorrecta.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido.';
          break;
        default:
          errorMessage = 'Ocurrió un error al iniciar sesión: ${e.message}';
      }
      setState(() {
        _mensaje = "❌ $errorMessage";
      });
    }
  } else {
    setState(() {
      _mensaje = "❌ Por favor ingresa tu usuario y contraseña.";
    });
  }
}

  void _goToRegister() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const RegisterPage()),
  );

  if (result == 'success') {
    setState(() {
      _mensaje = "✅ Usuario registrado correctamente. Ahora puedes iniciar sesión.";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Iniciar sesión',
          style: TextStyle(
            fontFamily: 'RussoOne',
            fontSize: 24,
            color: Color(0xFF66BB6A),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF66FF66)),
            tooltip: 'Inicio',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inicio')),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              children: [
                Hero(
                  tag: 'logo',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                     "images/logo1.jpg",
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _userController,
                  decoration: _inputDecoration("Usuario"),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: _inputDecoration("Contraseña"),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: _buttonStyle(),
                  child: const Text(
                    "Ingresar",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _mensaje,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _goToRegister,
                  child: const Text(
                    "¿No tienes cuenta? Regístrate",
                    style: TextStyle(
                      color: Color(0xFF66FF66),
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF66FF66)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF66FF66)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF66FF66), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF66FF66),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 8,
    );
  }
}

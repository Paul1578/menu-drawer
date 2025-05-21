import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isAnimationReady = false;
  String _mensajeError = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
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
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email ?? '',
        'username': user.email?.split('@')[0] ?? 'UsuarioNuevo',
        'level': 1,
      });
    } catch (e) {
      print('Error al guardar la información del usuario en Firestore: $e');
      setState(() {
        _mensajeError = "❌ Error al guardar la información del usuario.";
      });

      await user.delete();
      throw e;
    }
  }

  void _register() async {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    setState(() {
      _mensajeError = "";
    });

    if (!user.contains('@') || !user.contains('.')) {
      setState(() {
        _mensajeError = "❌ Ingresa un correo electrónico válido.";
      });
      return;
    }

    if (pass.length < 6) {
      setState(() {
        _mensajeError = "❌ La contraseña debe tener al menos 6 caracteres.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: user, password: pass);

      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!);
        Navigator.pop(context, 'success');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _mensajeError = "❌ ${e.message}";
      });
    } catch (e) {
      setState(() {
        _mensajeError = "❌ Error inesperado: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF66FF66))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Registro',
          style: TextStyle(
            fontFamily: 'RussoOne',
            fontSize: 24,
            color: Color(0xFF66FF66),
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
        iconTheme: const IconThemeData(color: Color(0xFF66FF66)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'logo',
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/logo1.jpg',
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: TextField(
                    controller: _userController,
                    decoration: _inputDecoration("Correo electrónico"),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 25),
                FadeInDown(
                  delay: const Duration(milliseconds: 400),
                  child: TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: _inputDecoration("Contraseña"),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                if (_mensajeError.isNotEmpty)
                  FadeIn(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      _mensajeError,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 30),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: _buttonStyle(),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Registrar",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF66FF66), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF66FF66),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 8,
      shadowColor: Colors.black26,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:menubar/src/pages/auth/login.dart';
import 'package:menubar/src/pages/editarPerfil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io'; // Importa dart:io para File

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? _userData;
  bool _isLoading = true;
  String? _profileImagePath; // Agrega esta variable para la ruta de la imagen

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _userData = null;
    });
    if (user != null) {
      try {
        final DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        setState(() {
          _userData = snapshot;
          _isLoading = false;
          _profileImagePath = snapshot['profileImagePath']; // Carga la ruta de la imagen
        });
      } catch (e) {
        print('Error al cargar la información del usuario: $e');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al cargar la información del perfil')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileProvider;
    if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
      // Si hay una ruta de imagen, usa FileImage para cargarla
      profileProvider = FileImage(File(_profileImagePath!));
    } else {
      // Si no hay ruta, usa la imagen de asset por defecto
      profileProvider =
          const AssetImage('images/default_profile_image.jpg'); // Asegúrate de que esta ruta sea correcta
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("No hay usuario autenticado."))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileProvider, // Usa el ImageProvider
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Usuario: ${_userData?['username'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Correo: ${_userData?['email'] ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Nivel de exploración: ${_userData?['level'] ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_userData != null) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarPerfilPage(
                                    usuario: _userData!['username'] ?? '',
                                    nivel: _userData!['level'] ?? 1,
                                  ),
                                ),
                              );
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                _loadUserData();
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No se pudo cargar la información del perfil')),
                              );
                            }
                          },
                          child: const Text("Editar Perfil"),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((_) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error al cerrar sesión: $error')),
                              );
                            });
                          },
                          child: const Text("Cerrar sesión"),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}


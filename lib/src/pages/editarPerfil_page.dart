import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditarPerfilPage extends StatefulWidget {
  final String usuario;
  final int nivel;

  const EditarPerfilPage({
    super.key,
    required this.usuario,
    required this.nivel,
  });

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController _usuarioController;
  late TextEditingController _nivelController;
  String? _profileImagePath; // ahora ruta local
  final _formKey = GlobalKey<FormState>();
  bool _isUploading = false;
  String _errorMessage = '';

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _usuarioController = TextEditingController(text: widget.usuario);
    _nivelController = TextEditingController(text: widget.nivel.toString());
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      // Aquí esperamos que 'profileImagePath' sea la ruta local guardada, si no, queda nulo
      setState(() {
        _profileImagePath = doc['profileImagePath'] ?? ''; 
        if (_profileImagePath!.isEmpty) {
          _profileImagePath = null;
        }
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (pickedImage != null) {
      setState(() {
        _profileImagePath = pickedImage.path;
      });
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _nivelController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isUploading = true;
      _errorMessage = '';
    });

    try {
      // Guardamos usuario y nivel
      Map<String, dynamic> updateData = {
        'username': _usuarioController.text.trim(),
        'level': int.parse(_nivelController.text.trim()),
      };

      // Guardar la ruta local de la imagen (ojo: esto solo funciona si la app controla la imagen local y está accesible)
      if (_profileImagePath != null) {
        updateData['profileImagePath'] = _profileImagePath;
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
      );
      Navigator.pop(context, {'updated': true});
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar los cambios: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileProvider;
    if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
      profileProvider = FileImage(File(_profileImagePath!));
    } else {
      profileProvider = const AssetImage('images/default_profile_image.jpg');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isUploading ? null : _guardarCambios,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              ListView(
                children: <Widget>[
                  GestureDetector(
                    onTap: _seleccionarImagen,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de Usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre de usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nivelController,
                    decoration: const InputDecoration(
                      labelText: 'Nivel de Exploración',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nivel de exploración';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Por favor, ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              if (_isUploading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:menubar/src/pages/acerca_page.dart';
import 'package:menubar/src/pages/configuracion_page.dart';
import 'package:menubar/src/pages/favoritos_page.dart';
import 'package:menubar/src/pages/home_page.dart';
import 'package:menubar/src/pages/perfil_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManuTabBAR extends StatefulWidget {
  const ManuTabBAR({super.key});

  @override
  State<ManuTabBAR> createState() => _ManuTabBARState();
}

class _ManuTabBARState extends State<ManuTabBAR> {
  int _selectedIndex = 0;
  final _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static final List<Widget> _bottomTabPages = <Widget>[
    const HomePage(),
    const FavoritosPage(),
    const PerfilPage()
  ];

  // ignore: unused_element
  void _openDrawerPage(String title) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text("Aquí irá el contenido de $title."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarFeedback() async {
    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference feedbackRef =
            FirebaseFirestore.instance.collection('feedback');
        await feedbackRef.add({
          'comentario': _feedbackController.text,
          'fecha': DateTime.now(),
        });
        _mostrarMensaje("¡Gracias por tu feedback!");
        _feedbackController.clear();
        Navigator.pop(context);
      } catch (e) {
        _mostrarMensaje("Error al enviar el feedback: $e");
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Museos',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF66BB6A),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo1.jpg',
                    height: 100,
                    width: 200,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            ListTile(
              leading:
                  const Icon(Icons.info, color: Color(0xFF66BB6A)),
              title:
                  const Text('Acerca de', style: TextStyle(color: Color(0xFF66BB6A))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AcercaDePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback,
                  color: Color(0xFF66BB6A)),
              title: const Text('Feedback',
                  style: TextStyle(color: Color(0xFF66BB6A)),),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoFeedback(
                    context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.settings, color: Color(0xFF66BB6A)),
              title: const Text('Configuración',
                  style: TextStyle(color: Color(0xFF66BB6A))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ConfiguracionPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _bottomTabPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF212121),
        selectedItemColor: const Color(0xFF66BB6A),
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enviar Feedback'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escribe tu feedback aquí...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa tu comentario';
                }
                return null;
              },
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
            ElevatedButton(
              onPressed: _enviarFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}


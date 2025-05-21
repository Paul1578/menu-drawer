import 'package:flutter/material.dart';
import 'package:menubar/src/pages/museoDetail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<bool> _isFavorito(String museoId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentReference favDocRef =
          FirebaseFirestore.instance.collection('favoritos').doc(userId);
      final DocumentSnapshot favDoc = await favDocRef.get();
      if (favDoc.exists && favDoc.data() != null) {
        List<dynamic> favoritos =
            (favDoc.data() as Map<String, dynamic>)['museos'] ?? [];
        return favoritos.contains(museoId);
      }
    }
    return false;
  }

  Future<void> _toggleFavorito(String museoNombre, String museoId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentReference favDocRef =
          FirebaseFirestore.instance.collection('favoritos').doc(userId);

      final DocumentSnapshot favDoc = await favDocRef.get();

      if (favDoc.exists && favDoc.data() != null) {
        List<dynamic> favoritos =
            (favDoc.data() as Map<String, dynamic>)['museos'] ?? [];
        if (favoritos.contains(museoId)) {
          await favDocRef.update({
            'museos': FieldValue.arrayRemove([museoId]),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$museoNombre eliminado de favoritos')),
          );
        } else {
          await favDocRef.update({
            'museos': FieldValue.arrayUnion([museoId]),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$museoNombre añadido a favoritos')),
          );
        }
      } else {
        await favDocRef.set({
          'museos': [museoId],
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$museoNombre añadido a favoritos')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para añadir a favoritos')),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Museos de Ecuador')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('museos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Algo salió mal al cargar los museos.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay museos disponibles.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot doc = snapshot.data!.docs[index];
              final Map<String, dynamic> museo =
                  doc.data() as Map<String, dynamic>;
              final String museoId = doc.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MuseoDetailPage(museo: museo, museoId: museoId),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          image: DecorationImage(
                            image: AssetImage(museo['imagen']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(museo['nombre']),
                        subtitle: Text(
                            '⭐ ${museo['rating']?.toStringAsFixed(1) ?? 'N/A'}'),
                        trailing: FutureBuilder<bool>(
                          future: _isFavorito(museoId),
                          builder: (context, snapshot) {
                            final isFav = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _toggleFavorito(museo['nombre'], museoId),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

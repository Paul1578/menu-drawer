import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menubar/src/pages/museoDetail_page.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
      ),
      body: user == null
          ? const Center(
              child: Text('Debes iniciar sesión para ver tus favoritos.'),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('favoritos')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Algo salió mal al cargar los favoritos.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    !snapshot.data!.exists ||
                    snapshot.data!.data() == null) {
                  return const Center(
                      child: Text(
                          'No has añadido ningún museo a tus favoritos.'));
                }

                final favoritosData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> museoIdsFavoritos =
                    favoritosData['museos'] ?? [];

                if (museoIdsFavoritos.isEmpty) {
                  return const Center(
                      child: Text(
                          'No has añadido ningún museo a tus favoritos.'));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('museos')
                      .where(FieldPath.documentId,
                          whereIn:
                              museoIdsFavoritos) 
                      .snapshots(),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.hasError) {
                      return const Center(
                          child: Text(
                              'Algo salió mal al cargar la información de los museos.'));
                    }

                    if (futureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final List<QueryDocumentSnapshot> museosFavoritosDocs =
                        futureSnapshot.data?.docs ?? [];
                    final List<Map<String, dynamic>> museosFavoritos =
                        museosFavoritosDocs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                    if (museosFavoritos.isEmpty) {
                      return const Center(
                          child: Text(
                              'No se encontraron los museos favoritos.'));
                    }

                    return ListView.builder(
                      itemCount: museosFavoritos.length,
                      itemBuilder: (context, index) {
                        final museo = museosFavoritos[index];
                        final String museoId =
                            museosFavoritosDocs[index].id; 
                        return Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 4,
                          child: ListTile(
                            leading: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                museo['imagen'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                            title: Text(museo['nombre']),
                            subtitle: Text(
                                '⭐ ${museo['rating']?.toStringAsFixed(1) ?? 'N/A'}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MuseoDetailPage(
                                    museo: museo,
                                    museoId:
                                        museoId, 
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}


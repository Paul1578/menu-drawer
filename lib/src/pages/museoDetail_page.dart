import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MuseoDetailPage extends StatefulWidget {
  final Map<String, dynamic> museo;
  final String museoId; 

  const MuseoDetailPage({
    super.key,
    required this.museo,
    required this.museoId, 
  });

  @override
  State<MuseoDetailPage> createState() => _MuseoDetailPageState();
}

class _MuseoDetailPageState extends State<MuseoDetailPage> {
  late VideoPlayerController _videoController;
  bool _hasError = false;
  double? _userRating;
  bool _isFavorito = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _checkIfFavorito();
    _userRating = widget.museo['rating']?.toDouble();
  }

  Future<void> _loadVideo() async {
    final videoPath = widget.museo['video'] ?? '';
    _videoController = VideoPlayerController.asset(videoPath);
    try {
      await _videoController.initialize();
      if (mounted) {
        setState(() {});
        _videoController
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      }
    } catch (error) {
      print("❌ Error al cargar el video: $error");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  Future<void> _checkIfFavorito() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentReference favDocRef =
          FirebaseFirestore.instance.collection('favoritos').doc(userId);
      final DocumentSnapshot favDoc = await favDocRef.get();
      if (favDoc.exists && favDoc.data() != null) {
        List<dynamic> favoritos =
            (favDoc.data() as Map<String, dynamic>)['museos'] ?? [];
        setState(() {
          _isFavorito = favoritos.contains(widget.museoId);
        });
      }
    }
  }

  Future<void> _toggleFavorito() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentReference favDocRef =
          FirebaseFirestore.instance.collection('favoritos').doc(userId);

      final DocumentSnapshot favDoc = await favDocRef.get();

      if (favDoc.exists && favDoc.data() != null) {
        List<dynamic> favoritos =
            (favDoc.data() as Map<String, dynamic>)['museos'] ?? [];
        if (favoritos.contains(widget.museoId)) {
          await favDocRef.update({
            'museos': FieldValue.arrayRemove([widget.museoId]),
          });
          setState(() {
            _isFavorito = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eliminado de favoritos')),
          );
        } else {
          await favDocRef.update({
            'museos': FieldValue.arrayUnion([widget.museoId]),
          });
          setState(() {
            _isFavorito = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Añadido a favoritos')),
          );
        }
      } else {
        await favDocRef.set({
          'museos': [widget.museoId],
        });
        setState(() {
          _isFavorito = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Añadido a favoritos')),
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

  Future<void> _updateRating(double rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('museos')
          .doc(widget.museoId) 
          .update({'rating': rating});
      setState(() {
        _userRating = rating; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gracias por tu valoración')),
      );
    } catch (e) {
      print('Error al actualizar la valoración: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar tu valoración')),
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final museo = widget.museo;

    return Scaffold(
      body: _hasError
          ? const Center(
              child: Text(
                'Error al cargar el video.',
                style: TextStyle(color: Colors.red),
              ),
            )
          : !_videoController.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250,
                      pinned: true,
                      backgroundColor: Colors.black87,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(museo['nombre']),
                        background: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController.value.size.width,
                            height: _videoController.value.size.height,
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            _isFavorito ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: _toggleFavorito,
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoHeader(museo, context),
                            const SizedBox(height: 20),
                            _buildExpansionSection(
                                'Tipología', museo['tipologia'], context),
                            _buildExpansionSection(
                                'Horario', museo['horario'], context),
                            _buildExpansionSection(
                                'Entrada', museo['entrada'], context),
                            _buildExpansionSection(
                                'Descripción', museo['descripcion'], context),
                            _buildExpansionSection(
                                'Ubicación', museo['ubicacion'], context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoHeader(Map<String, dynamic> museo, BuildContext context) {
    final textColor = Theme.of(context).textTheme.titleLarge?.color;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              museo['imagen'],
              height: 180,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  museo['nombre'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating:
                          _userRating ?? (museo['rating']?.toDouble() ?? 0),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 28,
                      itemPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        _updateRating(
                            rating); 
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      (_userRating ?? museo['rating']).toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionSection(
      String title, dynamic content, BuildContext context) {
    if (content == null || content.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    final contentColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          if (title == 'Ubicación' && content is Map<String, dynamic>)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content['direccion'] ?? 'Dirección no disponible',
                  style: TextStyle(fontSize: 15, color: contentColor),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(content['lat'], content['lng']),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('museo'),
                        position: LatLng(content['lat'], content['lng']),
                        infoWindow:
                            const InfoWindow(title: 'Ubicación del museo'),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final lat = content['lat'];
                    final lng = content['lng'];
                    final googleMapsUrl =
                        Uri.parse('geo:$lat,$lng?q=${content['direccion']}');

                    if (await canLaunchUrl(googleMapsUrl)) {
                      await launchUrl(googleMapsUrl,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No se pudo abrir Google Maps')),
                      );
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Ver en Google Maps'),
                ),
              ],
            )
          else
            Text(
              content.toString(),
              style: TextStyle(fontSize: 15, color: contentColor),
            ),
        ],
      ),
    );
  }
}


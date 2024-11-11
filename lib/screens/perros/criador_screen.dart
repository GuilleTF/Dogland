// screens/perros/criador_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/widgets/image_carousel.dart';
import 'package:dogland/widgets/contact_info.dart';
import 'package:dogland/widgets/action_icons.dart';
import 'package:dogland/widgets/map_view.dart';
import 'package:dogland/widgets/share_options.dart';
import 'package:dogland/services/favorites_service.dart';
import 'package:dogland/screens/mensajes/chat_screen.dart';
import 'package:dogland/services/chat_service.dart';
import 'package:dogland/widgets/perro_card.dart';
import 'package:dogland/screens/perros/perro_screen.dart';

class CriadorScreen extends StatefulWidget {
  final String criadorId;
  final String nombre;
  final String descripcion;
  final List<String> imagenes;
  final String telefono;
  final String correo;
  final LatLng ubicacion;
  final String perfilImagenUrl;
  final Function(Map<String, dynamic>) onPerroSelected;

  CriadorScreen({
    required this.criadorId,
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
    required this.telefono,
    required this.correo,
    required this.ubicacion,
    required this.perfilImagenUrl,
    required this.onPerroSelected,
  });

  @override
  _CriadorScreenState createState() => _CriadorScreenState();
}

class _CriadorScreenState extends State<CriadorScreen> {
  final favoritesService = FavoritesService();
  final ChatService _chatService = ChatService();
  bool isFavorite = false;
  List<Map<String, dynamic>> _perros = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadPerros(); // Cargar los perros del criador
  }

  Future<void> _loadFavoriteStatus() async {
    final favoriteStatus = await favoritesService.isFavorite(widget.criadorId);
    setState(() {
      isFavorite = favoriteStatus;
    });
  }

  void _toggleFavorite() async {
    await favoritesService.toggleFavorite(widget.criadorId, 'criador');
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _loadPerros() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('perros')
        .where('userId', isEqualTo: widget.criadorId)
        .get();

    setState(() {
      _perros = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Asigna el ID al mapa de datos del perro
        return data;
      }).toList();
    });
  }

  void _openPerroScreen(Map<String, dynamic> perroData) {
    widget.onPerroSelected(perroData);
  }

  @override
  Widget build(BuildContext context) {
    final String criadorUrl = 'https://dogland.com/criador/${widget.nombre.replaceAll(' ', '_')}';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImageCarousel(images: widget.imagenes),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: widget.perfilImagenUrl.isNotEmpty
                                ? NetworkImage(widget.perfilImagenUrl)
                                : null,
                            child: widget.perfilImagenUrl.isEmpty
                                ? Icon(Icons.person, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.nombre,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.descripcion,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildPerrosList(), // Mostrar la lista de perros
            const SizedBox(height: 20),
            ActionIcons(
              onShare: () => _showShareOptions(context, criadorUrl),
              onChat: () async {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                final chatId = await _chatService.getOrCreateChat(userId, widget.criadorId);
                if (chatId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        userId: userId,
                        recipientId: widget.criadorId,
                      ),
                    ),
                  );
                }
              },
              isFavorite: isFavorite,
              onFavoriteToggle: _toggleFavorite,
            ),
            const SizedBox(height: 20),
            ContactInfo(telefono: widget.telefono, correo: widget.correo),
            const SizedBox(height: 20),
            MapView(location: widget.ubicacion, markerId: 'ubicacionCriador'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Método para construir la lista de perros
  Widget _buildPerrosList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Perros Disponibles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              itemCount: _perros.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var perroData = _perros[index];
                return PerroCard(
                  perro: perroData,
                  onTap: () {
                    _openPerroScreen(perroData);
                  },
                  showActions: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, String criadorUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ShareOptions(
          shareText: 'Visita al criador ${widget.nombre} en',
          url: criadorUrl,
        );
      },
    );
  }
}

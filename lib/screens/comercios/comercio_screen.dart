// screens/comercios/comercio_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dogland/widgets/image_carousel.dart';
import 'package:dogland/widgets/contact_info.dart';
import 'package:dogland/widgets/action_icons.dart';
import 'package:dogland/widgets/map_view.dart';
import 'package:dogland/widgets/share_options.dart';
import 'package:dogland/services/favorites_service.dart';
import 'package:dogland/screens/mensajes/chat_screen.dart';
import 'package:dogland/services/chat_service.dart';

class ComercioScreen extends StatefulWidget {
  final String comercioId;
  final String nombre;
  final String descripcion;
  final List<String> imagenes;
  final String telefono;
  final String correo;
  final LatLng ubicacion;
  final String perfilImagenUrl;

  final ChatService _chatService = ChatService();

  ComercioScreen({
    required this.comercioId,
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
    required this.telefono,
    required this.correo,
    required this.ubicacion,
    required this.perfilImagenUrl,
  });

  @override
  _ComercioScreenState createState() => _ComercioScreenState();
}

class _ComercioScreenState extends State<ComercioScreen> {
  final favoritesService = FavoritesService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.comercioId.isEmpty) {
      print("Advertencia: comercioId está vacío al iniciar ComercioScreen");
    }
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favoriteStatus = await favoritesService.isFavorite(widget.comercioId);
    setState(() {
      isFavorite = favoriteStatus;
    });
  }

void _toggleFavorite() async {
    if (widget.comercioId.isNotEmpty) {
      await favoritesService.toggleFavorite(widget.comercioId, 'comercio');
      setState(() {
        isFavorite = !isFavorite;
      });
    } else {
      print("Error: comercioId está vacío y no se puede añadir a favoritos.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String comercioUrl = 'https://dogland.com/comercio/${widget.nombre.replaceAll(' ', '_')}';

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
                                ? Icon(Icons.store, size: 30)
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
            const SizedBox(height: 20),
            ActionIcons(
              onShare: () => _showShareOptions(context, comercioUrl),
              onChat: () async {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                
                try {
                  final chatId = await widget._chatService.getOrCreateChat(userId, widget.comercioId);

                  // Verifica si chatId no es nulo antes de navegar
                  if (chatId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          userId: userId,
                          recipientId: widget.comercioId,
                        ),
                      ),
                    );
                  } else {
                    print("Error: chatId es nulo.");
                    // Muestra un mensaje de error o toma alguna acción
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No se pudo iniciar el chat. Intenta de nuevo.")),
                    );
                  }
                } catch (e) {
                  print("Error al obtener el chat: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Hubo un problema al obtener el chat. Intenta de nuevo.")),
                  );
                }
              },
              isFavorite: isFavorite,
              onFavoriteToggle: _toggleFavorite,
            ),
            const SizedBox(height: 20),
            ContactInfo(telefono: widget.telefono, correo: widget.correo),
            const SizedBox(height: 20),
            MapView(location: widget.ubicacion, markerId: 'ubicacionComercio'),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, String comercioUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ShareOptions(
          shareText: 'Visita el comercio ${widget.nombre} en',
          url: comercioUrl,
        );
      },
    );
  }
}
